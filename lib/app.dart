import 'package:flutter/material.dart';
import 'screens/namjap_screen.dart';

class NamJapApp extends StatelessWidget {
  const NamJapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "JapAura - Daily Jap Companion",
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const NamJapScreen(),
    );
  }
}
