import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../models/job_match.dart';
import '../../services/api_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _loading = false;
  JobMatch? _result;
  String? _error;
  int? _cvAnalysisId;
  List<JobMatch> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      _cvAnalysisId = args['cvAnalysisId'] as int?;
    }
  }

  Future<void> _loadHistory() async {
    try {
      final list = await ApiService().getMatchHistory();
      setState(() => _history = list);
    } catch (_) {}
  }

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final match = await ApiService().analyzeMatch(
        jobTitle: _titleCtrl.text.trim(),
        company: _companyCtrl.text.trim(),
        jobDescription: _descCtrl.text.trim(),
        cvAnalysisId: _cvAnalysisId,
      );
      setState(() {
        _result = match;
        _history.insert(0, match);
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
            const Text('Matching Emploi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(
              _cvAnalysisId != null ? 'Basé sur ton CV analysé' : 'Analyse une offre',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF7DB3D8)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _result != null ? _buildResults() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_cvAnalysisId != null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text('CV analysé lié — matching précis',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.success)),
                ],
              ),
            ),

          AppTextField(
            label: 'Titre du poste',
            hint: 'ex: Data Scientist Senior',
            controller: _titleCtrl,
            validator: (v) => v!.isEmpty ? 'Requis' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Entreprise (optionnel)',
            hint: 'ex: BNP Paribas',
            controller: _companyCtrl,
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Description du poste',
            hint: 'Colle la description complète de l\'offre...',
            controller: _descCtrl,
            maxLines: 8,
            validator: (v) => v!.length < 50 ? 'Minimum 50 caractères' : null,
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
                  Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12))),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Analyser la compatibilité →',
            loading: _loading,
            onPressed: _analyze,
          ),

          if (_history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Analyses récentes',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 8),
            ..._history.take(5).map((m) => _HistoryCard(
                  match: m,
                  onTap: () => setState(() => _result = m),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildResults() {
    final m = _result!;
    final scoreColor = m.matchScore >= 80
        ? AppColors.success
        : m.matchScore >= 60
            ? AppColors.warning
            : AppColors.error;
    final scoreBg = m.matchScore >= 80
        ? AppColors.successBg
        : m.matchScore >= 60
            ? AppColors.warningBg
            : AppColors.errorBg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.jobTitle,
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    if (m.company != null && m.company!.isNotEmpty)
                      Text(m.company!,
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF7DB3D8))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: scoreBg, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  '${m.matchScore.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                      fontSize: 22, fontWeight: FontWeight.w700, color: scoreColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Strong vs missing
        Row(
          children: [
            Expanded(
              child: _SectionCard(
                title: 'Points forts ✅',
                titleColor: AppColors.success,
                child: Column(
                  children: m.strongSkills
                      .map((s) => _SkillChip(label: s, color: AppColors.success, bg: AppColors.successBg))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SectionCard(
                title: 'À améliorer ❌',
                titleColor: AppColors.error,
                child: Column(
                  children: m.missingSkills
                      .map((s) => _SkillChip(label: s, color: AppColors.error, bg: AppColors.errorBg))
                      .toList(),
                ),
              ),
            ),
          ],
        ),

        if (m.certifications.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Certifications recommandées',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          ...m.certifications.map((c) => _CertCard(cert: c)),
        ],

        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _result = null;
            _titleCtrl.clear();
            _companyCtrl.clear();
            _descCtrl.clear();
          }),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Analyser une autre offre'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            side: const BorderSide(color: AppColors.inputBorder),
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final JobMatch match;
  final VoidCallback onTap;
  const _HistoryCard({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scoreColor = match.matchScore >= 80
        ? AppColors.success
        : match.matchScore >= 60
            ? AppColors.warning
            : AppColors.error;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(match.jobTitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (match.company != null && match.company!.isNotEmpty)
                    Text(match.company!,
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ),
            Text('${match.matchScore.toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700, color: scoreColor)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Widget child;
  const _SectionCard({required this.title, required this.titleColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                  fontSize: 10, fontWeight: FontWeight.w600, color: titleColor)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _SkillChip({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _CertCard extends StatelessWidget {
  final CertificationItem cert;
  const _CertCard({required this.cert});

  @override
  Widget build(BuildContext context) {
    final priorityColor = cert.priority == 'high'
        ? AppColors.error
        : cert.priority == 'medium'
            ? AppColors.warning
            : AppColors.success;
    final priorityBg = cert.priority == 'high'
        ? AppColors.errorBg
        : cert.priority == 'medium'
            ? AppColors.warningBg
            : AppColors.successBg;
    final emoji = cert.priority == 'high' ? '⚡' : cert.priority == 'medium' ? '📘' : '🎓';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: priorityBg, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cert.title,
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text('${cert.platform} · ${cert.duration} · ${cert.price}',
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight)),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: priorityBg, borderRadius: BorderRadius.circular(20)),
                      child: Text('Priorité ${cert.priority}',
                          style: TextStyle(
                              fontSize: 9, color: priorityColor, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(cert.reason,
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
