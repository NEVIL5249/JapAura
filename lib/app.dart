import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'services/onboarding_service.dart';
import 'screens/namjap_screen.dart';
import 'screens/onboarding/welcome_screen.dart';

class NamJapApp extends StatelessWidget {
  const NamJapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      blurValue: 1,
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "JapAura - Daily Jap Companion",
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder<bool>(
          future: OnboardingService.hasCompletedOnboarding(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF140D09),
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE5A65D)),
                  ),
                ),
              );
            }

            final hasCompleted = snapshot.data ?? false;
            if (!hasCompleted) {
              return const WelcomeScreen();
            }

            return const NamJapScreen(startTourOnLaunch: false);
          },
        ),
      ),
    );
  }
}
