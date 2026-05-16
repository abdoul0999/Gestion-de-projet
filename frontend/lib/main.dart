import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile/profile_setup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/cv/cv_screen.dart';
import 'screens/matching/matching_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const AscendiaApp(),
    ),
  );
}

class AscendiaApp extends StatelessWidget {
  const AscendiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AscendIA',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/profile-setup': (_) => const ProfileSetupScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/cv': (_) => const CVScreen(),
        '/matching': (_) => const MatchingScreen(),
        '/chatbot': (_) => const ChatbotScreen(),
      },
    );
  }
}
