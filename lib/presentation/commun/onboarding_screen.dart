import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luwaas/presentation/commun/role_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── 3 slides contexte sénégalais ─────────────────────────────────────────
  // 📸 Place tes photos dans assets/images/ et déclare-les dans pubspec.yaml :
  //
  //   flutter:
  //     assets:
  //       - assets/images/onboarding_bg1.jpg
  //       - assets/images/onboarding_bg2.jpg
  //       - assets/images/onboarding_bg3.jpg
  //
  //   onboarding_bg1.jpg → immeuble dakarois, maison au Plateau ou Almadies
  //   onboarding_bg2.jpg → main tenant smartphone avec Wave ou Orange Money ouvert
  //   onboarding_bg3.jpg → propriétaire & locataire, vue sur Dakar ou une rue sénégalaise

  static const _slides = [
    _OnboardingData(
      imagePath: 'assets/images/pi.jpg',
      gradientColors: [Color(0xFF0F2027), Color(0xFF1E3A5F), Color(0xFF2C5F8A)],
      tag: "Baux numériques",
      title: "Fini les baux\npapier perdus",
      subtitle:
      "Créez et signez vos contrats de location en ligne. Tout est conservé, sécurisé et accessible partout au Sénégal.",
    ),
    _OnboardingData(
      imagePath: 'assets/images/paiement.jpg',
      gradientColors: [Color(0xFF0D1F1A), Color(0xFF0D4A3A), Color(0xFF1A7A5E)],
      tag: "Paiements mobiles",
      title: "Encaissez et Payer votre Loyer via Mobile Money",
      subtitle:
      "Plus besoin de courir après les loyers. Recevez vos paiements directement sur mobile avec reçus automatiques.",
    ),
    _OnboardingData(
      imagePath: 'assets/images/unnamed.jpg',
      gradientColors: [Color(0xFF1A0F0A), Color(0xFF5C2A0F), Color(0xFF8B4513)],
      tag: "Fait pour le Sénégal",
      title: "Pour bailleurs et\nlocataires sénégalais",
      subtitle:
      "Conforme à la législation sénégalaise. Suivi complet des paiements, historique clair, zéro litige.",
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RoleScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── PageView avec swipe ───────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _OnboardingPage(data: _slides[index]);
            },
          ),

          // ── UI par-dessus ─────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Logo LUWAAS ──
                  const Text(
                    'Luwaas',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const Spacer(),

                  // ── Tag badge animé ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey('tag_$_currentPage'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _slides[_currentPage].tag,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Titre ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _slides[_currentPage].title,
                      key: ValueKey('title_$_currentPage'),
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.18,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Sous-titre ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _slides[_currentPage].subtitle,
                      key: ValueKey('sub_$_currentPage'),
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 15,
                        height: 1.55,
                        color: Colors.white.withOpacity(0.72),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Dots de progression ──
                  Row(
                    children: List.generate(
                      _slides.length,
                          (index) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _ProgressDot(active: index == _currentPage),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Boutons navigation ──
                  Row(
                    children: [
                      // Bouton retour — masqué sur le 1er écran
                      if (_currentPage > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            height: 56,
                            width: 56,
                            child: OutlinedButton(
                              onPressed: _previousPage,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.white.withOpacity(0.4)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Bouton principal Suivant / C'est parti
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: _nextPage,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1E40AF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Figtree',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(isLastPage ? "C'est parti !" : "Suivant"),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Lien connexion ──

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide individuel ──────────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Photo background (asset local)
        SizedBox.expand(
          child: Image.asset(
            data.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback gradient unique par slide si photo absente
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: data.gradientColors,
                  ),
                ),
              );
            },
          ),
        ),
        // Gradient overlay
        SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 0.65, 1.0],
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.transparent,
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.92),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Données d'un slide ────────────────────────────────────────────────────────
class _OnboardingData {
  final String imagePath;
  final List<Color> gradientColors;
  final String tag;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.imagePath,
    required this.gradientColors,
    required this.tag,
    required this.title,
    required this.subtitle,
  });
}

// ── Dot de progression animé ──────────────────────────────────────────────────
class _ProgressDot extends StatelessWidget {
  final bool active;
  const _ProgressDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}