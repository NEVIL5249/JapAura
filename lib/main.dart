import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(NamJapApp());
}

class NamJapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Radha Nam Jap",
      theme: ThemeData(primarySwatch: Colors.pink),
      home: NamJapScreen(),
    );
  }
}

class NamJapScreen extends StatefulWidget {
  @override
  _NamJapScreenState createState() => _NamJapScreenState();
}

class _NamJapScreenState extends State<NamJapScreen> {
  int count = 0;
  int mala = 0;
  final player = AudioPlayer();

  void _increment() async {
    setState(() {
      count++;
      if (count >= 108) {
        mala++;
        count = 0;
        _notifyMalaComplete();
      }
    });
  }

  void _notifyMalaComplete() async {
    // Vibration
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
    // Play bell sound (add bell.mp3 inside assets/audio/)
    await player.play(AssetSource('audio/bell.mp3'));
  }

  void _reset() {
    setState(() {
      count = 0;
      mala = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _increment,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset("assets/images/radha.png", fit: BoxFit.cover),
            // Transparent dark overlay for readability
            Container(color: Colors.black.withOpacity(0.3)),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Radhe Radhe 🙏",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    "Count: $count",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Mala Completed: $mala",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.lightGreenAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _reset,
          child: Icon(Icons.refresh, color: Colors.white),
          backgroundColor: Colors.pink,
        ),
      ),
    );
  }
}
