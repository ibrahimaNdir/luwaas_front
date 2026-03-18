import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:luwaas/presentation/commun/notif_screen.dart';
import 'package:luwaas/presentation/commun/onboarding_screen.dart';
import 'package:luwaas/presentation/locataire/details_baux_screen.dart';
import 'package:luwaas/presentation/locataire/payment_history_screen.dart';
import 'package:luwaas/presentation/locataire/profile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

// --- MODELS ---
import 'package:luwaas/data/model/bails.dart';

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
import 'package:luwaas/data/source/paiement_data_source.dart'; // Bailleur

// ✅ PAIEMENTS LOCATAIRE - CORRIGÉ
import 'package:luwaas/presentation/provider/PaiementProvider.dart';
import 'package:luwaas/data/repositories/PaiementRepository.dart';
import 'package:luwaas/data/source/PaiementSource.dart' as PaiementLoc; // ✅ ALIAS pour éviter conflit

/// 🔹 Handler des messages FCM en background / app fermée
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("📩 Message reçu en arrière-plan : ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Init locale fr_FR (NumberFormat, DateFormat)
  await initializeDateFormatting('fr_FR', null);

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
        // ══════════════════════════════════════════════════════════
        // 1. AUTH (doit être en premier)
        // ══════════════════════════════════════════════════════════
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          lazy: false,
        ),

        // ══════════════════════════════════════════════════════════
        // 2. NOTIFICATIONS
        // ══════════════════════════════════════════════════════════
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),

        // ══════════════════════════════════════════════════════════
        // 3. DEMANDES
        // ══════════════════════════════════════════════════════════
        ChangeNotifierProvider(
          create: (context) {
            debugPrint("🔧 Initialisation DemandeProvider");
            return DemandeProvider(
              repository: DemandeRepository(
                dataSource: DemandeDataSource(),
              ),
            );
          },
          lazy: false,
        ),

        // ══════════════════════════════════════════════════════════
        // 4. BAUX
        // ══════════════════════════════════════════════════════════
        ChangeNotifierProvider(
          create: (context) => BailProvider(
            repository: BailRepository(
              dataSource: BailDataSource(),
            ),
          ),
        ),

        // ══════════════════════════════════════════════════════════
        // 5. PROPRIÉTÉS
        // ══════════════════════════════════════════════════════════
        ChangeNotifierProvider(
          create: (context) => PropertyProvider(
            repository: PropertyRepository(
              remoteSource: PropertyRemoteSource(),
            ),
          ),
        ),

        // ══════════════════════════════════════════════════════════
        // 6. LOGEMENTS
        // ══════════════════════════════════════════════════════════
        ChangeNotifierProvider(
          create: (context) => LogementProvider(
            repository: LogementRepository(
              remoteSource: LogementRemoteDataSource(),
            ),
          ),
        ),

        // ══════════════════════════════════════════════════════════
        // 7. PAIEMENTS BAILLEUR
        // ══════════════════════════════════════════════════════════
        ChangeNotifierProvider(
          create: (context) => PaiementBailleurProvider(
            PaiementBailleurRepository(
              dataSource: PaiementDataSource(), // De paiement_data_source.dart
            ),
          ),
        ),

        // ══════════════════════════════════════════════════════════
        // ✅ 8. PAIEMENTS LOCATAIRE - CORRIGÉ AVEC ALIAS
        // ══════════════════════════════════════════════════════════
        ChangeNotifierProvider(
          create: (context) {
            debugPrint("🔧 Initialisation PaiementProvider (Locataire)");
            return PaiementProvider(
              repository: PaiementRepository(
                dataSource: PaiementLoc.PaiementDataSource(), // ✅ Utilise l'alias
              ),
            );
          },
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

      // ══════════════════════════════════════════════════════════
      // ROUTES SIMPLES (sans arguments)
      // ══════════════════════════════════════════════════════════
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/role': (context) => const RoleScreen(),
        '/main_bailleur': (context) => const MainScreenBailleur(),
        '/main_client': (context) => const ClientHomeScreen(),
        '/client_home': (context) => const ClientHomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notif': (context) => const NotifScreen(),
      },

      // ══════════════════════════════════════════════════════════
      // ROUTES AVEC ARGUMENTS
      // ══════════════════════════════════════════════════════════
      onGenerateRoute: (settings) {
        // ═══════════════════════════════════════════════════════
        // ROUTE /register
        // ═══════════════════════════════════════════════════════
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

        // ═══════════════════════════════════════════════════════
        // ROUTE /detail_bail_locataire
        // ═══════════════════════════════════════════════════════
        if (settings.name == '/detail_bail_locataire') {
          final bail = settings.arguments as Bail?;

          if (bail == null) {
            debugPrint("⚠️ /detail_bail_locataire appelé sans argument Bail");
            return MaterialPageRoute(
              builder: (context) => const ClientHomeScreen(),
            );
          }

          return MaterialPageRoute(
            builder: (context) => DetailBailLocataireScreen(bail: bail),
          );
        }

        // ═══════════════════════════════════════════════════════
        // ROUTE /payment_history
        // ═══════════════════════════════════════════════════════
        if (settings.name == '/payment_history') {
          final bail = settings.arguments as Bail?;

          if (bail == null) {
            debugPrint("⚠️ /payment_history appelé sans argument Bail");
            return MaterialPageRoute(
              builder: (context) => const ClientHomeScreen(),
            );
          }

          return MaterialPageRoute(
            builder: (context) => PaymentHistoryScreen(bail: bail),
          );
        }

        // ═══════════════════════════════════════════════════════
        // ROUTE /notifications
        // ═══════════════════════════════════════════════════════
        if (settings.name == '/notifications') {
          return MaterialPageRoute(
            builder: (context) => const NotifScreen(),
          );
        }

        // ═══════════════════════════════════════════════════════
        // Route non trouvée
        // ═══════════════════════════════════════════════════════
        debugPrint("⚠️ Route non trouvée : ${settings.name}");
        return null;
      },
    );
  }
}