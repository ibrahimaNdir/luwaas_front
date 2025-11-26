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
      title: 'Louwaas ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        fontFamily: 'Figtree',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/role': (context) => const RoleScreen(),
        '/register': (context) => RegisterScreen(userType: 'locataire'),
        '/main_bailleur': (context) => const MainScreenBailleur(),
        '/main_client': (context) => const MainScreenLocataire(),

        // Ajoute d'autres routes (ajout/modification) ici si nécessaire
      },
    );
  }
}