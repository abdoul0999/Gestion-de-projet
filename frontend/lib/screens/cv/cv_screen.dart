import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../config/theme.dart';
import '../../models/cv_analysis.dart';
import '../../services/api_service.dart';
import '../../widgets/primary_button.dart';

class CVScreen extends StatefulWidget {
  const CVScreen({super.key});

  @override
  State<CVScreen> createState() => _CVScreenState();
}

class _CVScreenState extends State<CVScreen> {
  PlatformFile? _pickedFile;
  bool _loading = false;
  CVAnalysis? _result;
  String? _error;
  List<CVAnalysis> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final list = await ApiService().getCVAnalyses();
      setState(() => _history = list);
    } catch (_) {}
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _result = null;
        _error = null;
      });
    }
  }

  Future<void> _analyze() async {
    if (_pickedFile == null || _pickedFile!.bytes == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final analysis = await ApiService().analyzeCV(
        fileBytes: _pickedFile!.bytes!,
        fileName: _pickedFile!.name,
      );
      setState(() {
        _result = analysis;
        _history.insert(0, analysis);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Analyse de CV', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(_result == null ? 'Étape 1 — Importe ton CV' : 'Résultats de l\'analyse',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF7DB3D8))),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _result != null ? _buildResults() : _buildUpload(),
      ),
    );
  }

  Widget _buildUpload() {
    return Column(
      children: [
        // Drop zone
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _pickedFile != null ? AppColors.primaryLight : const Color(0xFF90CAF9),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.upload_file_rounded,
                    size: 40,
                    color: _pickedFile != null ? AppColors.success : AppColors.primaryLight),
                const SizedBox(height: 10),
                Text(
                  _pickedFile != null ? _pickedFile!.name : 'Importe ton CV',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _pickedFile != null ? AppColors.success : AppColors.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _pickedFile != null
                      ? '${(_pickedFile!.size / 1024).toStringAsFixed(0)} Ko · Prêt à analyser'
                      : 'PDF, DOC, DOCX acceptés',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                ),
                if (_pickedFile == null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    child: const Text('Parcourir les fichiers'),
                  ),
                ],
              ],
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFCDD2))),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12))),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Lancer l\'analyse IA →',
          loading: _loading,
          onPressed: _pickedFile != null ? _analyze : null,
        ),

        if (_history.isNotEmpty) ...[
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Analyses précédentes',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(height: 8),
          ..._history.map((a) => _HistoryCard(
                analysis: a,
                onTap: () => setState(() => _result = a),
              )),
        ],
      ],
    );
  }

  Widget _buildResults() {
    final a = _result!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Score global CV',
                      style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF7DB3D8))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(a.score?.toStringAsFixed(0) ?? '--',
                          style: GoogleFonts.inter(
                              fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
                      Text('/100',
                          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF7DB3D8))),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: const Color(0xFF0F2D55), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Text(
                      a.score != null && a.score! >= 80
                          ? 'Excellent'
                          : a.score != null && a.score! >= 60
                              ? 'Bon niveau'
                              : 'À améliorer',
                      style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF90CAF9)),
                    ),
                    const SizedBox(height: 2),
                    Text(a.filename ?? 'CV',
                        style: GoogleFonts.inter(
                            fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Corrections
        _SectionCard(
          title: 'Règles vérifiées par l\'IA',
          child: Column(
            children: a.corrections
                .map((c) => _CorrectionRow(item: c))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),

        // Technical skills
        if (a.skills.isNotEmpty)
          _SectionCard(
            title: 'Compétences techniques',
            child: Column(
              children: a.skills.map((s) => _SkillRow(skill: s)).toList(),
            ),
          ),
        const SizedBox(height: 10),

        // Soft skills & languages
        Row(
          children: [
            if (a.softSkills.isNotEmpty)
              Expanded(
                child: _SectionCard(
                  title: 'Soft skills',
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: a.softSkills
                        .map((s) => _Tag(label: s, color: const Color(0xFF1565C0),
                            bg: const Color(0xFFE3F2FD)))
                        .toList(),
                  ),
                ),
              ),
            if (a.softSkills.isNotEmpty && a.languages.isNotEmpty) const SizedBox(width: 10),
            if (a.languages.isNotEmpty)
              Expanded(
                child: _SectionCard(
                  title: 'Langues',
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: a.languages
                        .map((l) => _Tag(label: l, color: AppColors.success,
                            bg: AppColors.successBg))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _result = null;
            _pickedFile = null;
          }),
          icon: const Icon(Icons.upload_file, size: 16),
          label: const Text('Analyser un autre CV'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            side: const BorderSide(color: AppColors.inputBorder),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/matching',
              arguments: {'cvAnalysisId': a.id}),
          icon: const Icon(Icons.compare_arrows, size: 16),
          label: const Text('Analyser une offre avec ce CV →'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CVAnalysis analysis;
  final VoidCallback onTap;
  const _HistoryCard({required this.analysis, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, color: AppColors.primaryLight, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(analysis.filename ?? 'CV',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('Score: ${analysis.score?.toStringAsFixed(0) ?? '--'}/100',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _CorrectionRow extends StatelessWidget {
  final CorrectionItem item;
  const _CorrectionRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (item.status) {
      'ok' => (Icons.check_circle, AppColors.success),
      'error' => (Icons.cancel, AppColors.error),
      _ => (Icons.warning_amber_rounded, AppColors.warning),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.suggestion != null && item.status != 'ok'
                  ? '${item.rule} → ${item.suggestion}'
                  : item.rule,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMid, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final SkillItem skill;
  const _SkillRow({required this.skill});

  @override
  Widget build(BuildContext context) {
    final color = skill.level == 0
        ? AppColors.error
        : skill.level >= 80
            ? AppColors.primaryDark
            : AppColors.primaryLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill.name,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: skill.level == 0 ? AppColors.error : AppColors.textMid)),
              Text(
                skill.level == 0 ? '0% — Manquant' : '${skill.level}%',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: skill.level == 0 ? AppColors.error : AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            lineHeight: 4,
            percent: skill.level / 100,
            backgroundColor: const Color(0xFFE3F2FD),
            progressColor: color,
            barRadius: const Radius.circular(2),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _Tag({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
