import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:luwaas/presentation/commun/notif_screen.dart';
import 'package:luwaas/presentation/commun/onboarding_screen.dart'; // ✅ Nouveau fichier unique
import 'package:luwaas/presentation/locataire/profile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

// --- ECRANS ---
import 'package:luwaas/presentation/commun/login_screen.dart';
import 'package:luwaas/presentation/commun/register_screen.dart';
import 'package:luwaas/presentation/commun/role_screen.dart';
import 'package:luwaas/presentation/commun/splash_screen.dart';
import 'package:luwaas/presentation/bailleur/main_screen.dart';
import 'package:luwaas/presentation/locataire/home_screen.dart';

// --- AUTH ---
import 'package:luwaas/presentation/provider/auth_provider.dart';

// --- NOTIFICATIONS ---
import 'package:luwaas/presentation/provider/notification_provider.dart';

// --- DEMANDES ---
import 'package:luwaas/presentation/provider/DemandeProvider.dart';
import 'package:luwaas/data/repositories/DemandeRepository.dart';
import 'package:luwaas/data/source/DemandeSource.dart';

// --- BAUX ---
import 'package:luwaas/presentation/provider/BailProvider.dart';
import 'package:luwaas/data/repositories/bail_repository.dart';
import 'package:luwaas/data/source/BailSource.dart';

// --- PROPRIÉTÉS ---
import 'package:luwaas/presentation/provider/PropertyProvider.dart';
import 'package:luwaas/data/repositories/PropertyRepository.dart';
import 'package:luwaas/data/source/PropertyRemoteSource.dart';

// --- LOGEMENTS ---
import 'package:luwaas/presentation/provider/LogementProvider.dart';
import 'package:luwaas/data/repositories/LogementRepository.dart';
import 'package:luwaas/data/source/LogementRemoteSource.dart';

// --- PAIEMENTS BAILLEUR ---
import 'package:luwaas/presentation/provider/PaiementBailleursProvider.dart';
import 'package:luwaas/data/repositories/paiementBailleursRepository.dart';
import 'package:luwaas/data/source/paiement_data_source.dart';

/// 🔹 Handler des messages FCM en background / app fermée
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("📩 Message reçu en arrière-plan : ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Permissions de notifications (Android 13+ / iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 🔹 Handler pour messages en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 Initialiser automatiquement FCM au démarrage
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  runApp(
    MultiProvider(
      providers: [
        // 1. Auth — doit être en premier
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          lazy: false,
        ),

        // 2. Notification
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),

        // 3. Demande
        ChangeNotifierProvider(
          create: (context) {
            debugPrint("🔧 Initialisation DemandeProvider"); // ✅ debugPrint
            return DemandeProvider(
              repository: DemandeRepository(
                dataSource: DemandeDataSource(),
              ),
            );
          },
          lazy: false,
        ),

        // 4. Bail
        ChangeNotifierProvider(
          create: (context) => BailProvider(
            repository: BailRepository(
              dataSource: BailDataSource(),
            ),
          ),
        ),

        // 5. Propriétés
        ChangeNotifierProvider(
          create: (context) => PropertyProvider(
            repository: PropertyRepository(
              remoteSource: PropertyRemoteSource(),
            ),
          ),
        ),

        // 6. Logements
        ChangeNotifierProvider(
          create: (context) => LogementProvider(
            repository: LogementRepository(
              remoteSource: LogementRemoteDataSource(),
            ),
          ),
        ),

        // 7. Paiements Bailleur
        ChangeNotifierProvider(
          create: (context) => PaiementBailleurProvider(
            PaiementBailleurRepository(
              dataSource: PaiementDataSource(),
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luwaas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        fontFamily: 'Figtree',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(), // ✅ Fichier unique
        '/login': (context) => const LoginScreen(),
        '/role': (context) => const RoleScreen(),
        '/main_bailleur': (context) => const MainScreenBailleur(),
        '/main_client': (context) => const ClientHomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notif': (context) => const NotifScreen(),
      },
      onGenerateRoute: (settings) {
        // 🎯 ROUTE /register
        if (settings.name == '/register') {
          final args = settings.arguments;

          if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (context) => RegisterScreen(
                userType: args['role'] as String?,
              ),
              settings: RouteSettings(arguments: args),
            );
          } else if (args is String) {
            return MaterialPageRoute(
              builder: (context) => RegisterScreen(userType: args),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => const RoleScreen(),
            );
          }
        }

        // 🎯 ROUTE /notifications
        if (settings.name == '/notifications') {
          return MaterialPageRoute(
            builder: (context) => const NotifScreen(),
          );
        }

        return null;
      },
    );
  }
}