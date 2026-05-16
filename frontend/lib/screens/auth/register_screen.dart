import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/chip_selector.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _educationLevel;
  bool _loading = false;
  bool _showPassword = false;

  final _levels = ['Bac', 'Bac+2', 'Bac+3', 'Bac+5', 'Doctorat'];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    bool ok = false;
    try {
      ok = await auth.register(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        educationLevel: _educationLevel,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }

    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/profile-setup');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Erreur lors de l\'inscription'),
          backgroundColor: AppColors.error,
        ),
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
            const Text('Créer un compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Étape 1 / 2 — Informations personnelles',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF7DB3D8))),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0F2D55),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
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
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Prénom',
                      controller: _firstNameCtrl,
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Nom',
                      controller: _lastNameCtrl,
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Adresse email',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (!v.contains('@')) return 'Email invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Mot de passe',
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textLight, size: 20),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
                validator: (v) => v!.length < 6 ? 'Minimum 6 caractères' : null,
              ),
              const SizedBox(height: 20),
              Text(
                "NIVEAU D'ÉTUDES",
                style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                    letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              ChipSelector(
                options: _levels,
                selected: _educationLevel,
                onSelect: (v) => setState(() => _educationLevel = v),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Suivant →',
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
