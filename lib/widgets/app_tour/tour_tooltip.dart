import 'package:flutter/material.dart';

enum ArrowDirection { up, topRight, down, none }

class TourTooltip extends StatelessWidget {
  final int stepIndex; // 0-indexed
  final int totalSteps;
  final String title;
  final String description;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLastStep;
  final ArrowDirection arrowDirection;

  const TourTooltip({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.description,
    required this.onNext,
    required this.onSkip,
    this.isLastStep = false,
    this.arrowDirection = ArrowDirection.up,
  });

  @override
  Widget build(BuildContext context) {
    final currentStepNum = stepIndex + 1;
    const tooltipBgColor = Color(0xFA1E1611); // Warm dark charcoal-brown
    const borderColor = Color(0x4DE5A65D); // Subtle gold accent border

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: _getCrossAxisAlignmentForArrow(),
      children: [
        // Arrow pointing UP
        if (arrowDirection == ArrowDirection.up ||
            arrowDirection == ArrowDirection.topRight)
          Padding(
            padding: EdgeInsets.only(
              left: arrowDirection == ArrowDirection.topRight ? 0 : 0,
              right: arrowDirection == ArrowDirection.topRight ? 24 : 0,
            ),
            child: CustomPaint(
              size: const Size(16, 9),
              painter: _TrianglePainter(color: tooltipBgColor, isUp: true),
            ),
          ),

        // Main Tooltip Box
        Container(
          constraints: const BoxConstraints(maxWidth: 290),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            color: tooltipBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFFF8EE), // Warm ivory
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 6),

              // Description
              Text(
                description,
                style: TextStyle(
                  color: const Color(0xFFEAD8C3).withOpacity(0.88),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 14),

              // Bottom Footer: Muted "1 of 5" & Compact Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Muted Progress Text
                  Text(
                    '$currentStepNum of $totalSteps',
                    style: TextStyle(
                      color: const Color(0xFFFDB851).withOpacity(0.65),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),

                  // Actions (Skip / Next or Finish)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isLastStep)
                        GestureDetector(
                          onTap: onSkip,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                      GestureDetector(
                        onTap: onNext,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFE5A65D),
                                Color(0xFFDD7D3B),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDD7D3B).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLastStep ? 'Finish' : 'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isLastStep
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Arrow pointing DOWN
        if (arrowDirection == ArrowDirection.down)
          CustomPaint(
            size: const Size(16, 9),
            painter: _TrianglePainter(color: tooltipBgColor, isUp: false),
          ),
      ],
    );
  }

  CrossAxisAlignment _getCrossAxisAlignmentForArrow() {
    if (arrowDirection == ArrowDirection.topRight) {
      return CrossAxisAlignment.end;
    }
    return CrossAxisAlignment.center;
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool isUp;

  _TrianglePainter({required this.color, required this.isUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (isUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
