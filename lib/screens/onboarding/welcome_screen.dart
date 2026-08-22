import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';
import '../namjap_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _startTour(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const NamJapScreen(startTourOnLaunch: true),
      ),
    );
  }

  void _skipOnboarding(BuildContext context) async {
    await OnboardingService.completeOnboarding();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const NamJapScreen(startTourOnLaunch: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Devotional Background Image
          Image.asset(
            'assets/images/radha.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF231710),
            ),
          ),

          // Dark Warm Translucent Overlay with Vignette
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.45),
                  Colors.black.withOpacity(0.70),
                  const Color(0xFF140D09).withOpacity(0.92),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Content Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // App Logo & Branding Mark
                  Container(
                    width: 180,
                    height: 180,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDD7D3B).withOpacity(0.3),
                          blurRadius: 28,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/japaura_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFFDB851),
                        size: 54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: 40,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5A65D).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Title
                  const Text(
                    'Welcome to JapAura',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFF8EE),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Subtitle
                  Text(
                    'A little time for devotion.\nA little time for yourself.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFEAD8C3).withOpacity(0.85),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Primary CTA Button: Take a Quick Tour
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _startTour(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE5A65D),
                              Color(0xFFDD7D3B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: const Color(0xFFDD7D3B).withOpacity(0.4),
                          //     blurRadius: 16,
                          //     offset: const Offset(0, 6),
                          //   ),
                          // ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.explore_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Take a Quick Tour',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Secondary Action: Maybe later
                  TextButton(
                    onPressed: () => _skipOnboarding(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Maybe later',
                      style: TextStyle(
                        color: const Color(0xFFEAD8C3).withOpacity(0.65),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
