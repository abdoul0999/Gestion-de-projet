import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../widgets/ascendia_logo.dart';
import '../../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              const AscendiaLogo(size: 1.0),
              const SizedBox(height: 40),
              Text(
                'Ton copilote de carrière',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Analyse ton CV, trouve les meilleures offres\net prépare tes entretiens grâce à l\'IA.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textLight,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Créer un compte',
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Se connecter',
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
              const SizedBox(height: 20),
              Text(
                'En continuant tu acceptes nos CGU',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
