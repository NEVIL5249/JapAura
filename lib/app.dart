import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:showcaseview/showcaseview.dart';
import 'screens/namjap_screen.dart';
import 'screens/onboarding/welcome_screen.dart';

class NamJapApp extends StatefulWidget {
  final bool hasCompletedOnboarding;

  const NamJapApp({super.key, required this.hasCompletedOnboarding});

  @override
  State<NamJapApp> createState() => _NamJapAppState();
}

class _NamJapAppState extends State<NamJapApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

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
          scaffoldBackgroundColor: const Color(0xFFFF5C1D),
        ),
        home: widget.hasCompletedOnboarding
            ? const NamJapScreen(startTourOnLaunch: false)
            : const WelcomeScreen(),
      ),
    );
  }
}
