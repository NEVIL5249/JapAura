import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';

class CompletionDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const CompletionDialog({
    super.key,
    required this.onDismiss,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onDismiss}) async {
    await OnboardingService.completeOnboarding();
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CompletionDialog(onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF1E1712), // Deep warm brown charcoal
      elevation: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE5A65D).withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE5A65D).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE5A65D).withOpacity(0.35),
                ),
              ),
              child: const Icon(
                Icons.self_improvement_outlined,
                color: Color(0xFFFDB851),
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            // Branding text
            Text(
              'JapAura',
              style: TextStyle(
                color: const Color(0xFFE5A65D).withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),

            const SizedBox(height: 6),

            // Title
            const Text(
              "You're Ready",
              style: TextStyle(
                color: Color(0xFFFFF8EE),
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 10),

            // Subtitle
            Text(
              'Your Japa journey begins\nwith one tap.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFEAD8C3).withOpacity(0.85),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 28),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE5A65D),
                        Color(0xFFDD7D3B),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDD7D3B).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Begin Japa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
