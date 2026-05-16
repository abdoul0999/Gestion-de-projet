import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/chip_selector.dart';
import '../../widgets/primary_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  String? _contractType;
  bool _loading = false;

  final _contracts = ['CDI', 'Stage', 'Alternance', 'CDD', 'Freelance'];

  @override
  void dispose() {
    _jobCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_contractType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis un type de contrat')),
      );
      return;
    }
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final ok = await auth.setupProfile(
      targetJob: _jobCtrl.text.trim(),
      contractType: _contractType!,
      region: _regionCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Erreur'), backgroundColor: AppColors.error),
      );
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
            const Text('Configure ton profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Étape 2 / 2 — Objectifs professionnels',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF7DB3D8))),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFF0F2D55), borderRadius: BorderRadius.circular(3)),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.primaryLight, borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Métier cible',
                hint: 'ex: Data Scientist, Développeur Full Stack...',
                controller: _jobCtrl,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              Text('TYPE DE CONTRAT',
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              ChipSelector(
                  options: _contracts,
                  selected: _contractType,
                  onSelect: (v) => setState(() => _contractType = v)),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Région de recherche',
                hint: 'ex: Île-de-France, Lyon, Remote...',
                controller: _regionCtrl,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Accéder à l\'application →',
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
