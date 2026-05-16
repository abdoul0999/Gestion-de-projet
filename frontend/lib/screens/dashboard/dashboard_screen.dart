import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.primaryDark,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bonjour 👋',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF7DB3D8))),
                      const SizedBox(height: 2),
                      Text(user?.fullName ?? '...',
                          style: GoogleFonts.inter(
                              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                      if (user?.targetJob != null)
                        Text('${user!.targetJob} · ${user.contractType} · ${user.region}',
                            style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF7DB3D8))),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF0F2D55),
                  child: Text(
                    user?.initials ?? '?',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF90CAF9)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Score profil',
                                  style: GoogleFonts.inter(
                                      fontSize: 10, color: const Color(0xFF7DB3D8))),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('—',
                                      style: GoogleFonts.inter(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1)),
                                  const SizedBox(width: 4),
                                  Text('Analyse ton CV',
                                      style: GoogleFonts.inter(
                                          fontSize: 11, color: const Color(0xFF7DB3D8))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF0F2D55),
                                    borderRadius: BorderRadius.circular(3)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF0F2D55),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text('Bienvenue 🚀',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF90CAF9),
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Feature grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.3,
                    children: [
                      _FeatureCard(
                        emoji: '📄',
                        title: 'Analyse CV',
                        subtitle: 'Optimise ton CV',
                        onTap: () => Navigator.pushNamed(context, '/cv'),
                      ),
                      _FeatureCard(
                        emoji: '🎯',
                        title: 'Matching',
                        subtitle: 'Analyse une offre',
                        onTap: () => Navigator.pushNamed(context, '/matching'),
                      ),
                      _FeatureCard(
                        emoji: '🤖',
                        title: 'Chatbot IA',
                        subtitle: 'Pose tes questions',
                        onTap: () => Navigator.pushNamed(context, '/chatbot'),
                      ),
                      _FeatureCard(
                        emoji: '👤',
                        title: 'Mon profil',
                        subtitle: user?.targetJob ?? 'Configurer',
                        onTap: () => Navigator.pushNamed(context, '/profile-setup'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 3),
            Text(subtitle,
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
