import 'package:flutter/material.dart';
import 'package:luwaas/presentation/commun/login_screen.dart';
import 'package:luwaas/presentation/commun/register_screen.dart';
import 'package:luwaas/presentation/commun/role_screen.dart';
import 'package:luwaas/presentation/commun/splash_screen.dart';
import 'package:luwaas/presentation/bailleur/main_screen.dart';
import 'package:luwaas/presentation/locataire/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Louwaas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        fontFamily: 'Figtree',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),

      // Routes simples (sans arguments)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/role': (context) => const RoleScreen(),
        '/main_bailleur': (context) => const MainScreenBailleur(),
        '/main_client': (context) => const MainScreenLocataire(),
      },

      // ✅ Route avec arguments dynamiques
      onGenerateRoute: (settings) {
        // Route /register avec userType dynamique
        if (settings.name == '/register') {
          final userType = settings.arguments as String?;

          // Si pas de userType, redirige vers RoleScreen
          if (userType == null) {
            return MaterialPageRoute(
              builder: (context) => const RoleScreen(),
            );
          }

          // Sinon, affiche RegisterScreen avec le bon userType
          return MaterialPageRoute(
            builder: (context) => RegisterScreen(userType: userType),
          );
        }

        // Route par défaut si aucune route ne correspond
        return null;
      },
    );
  }
}