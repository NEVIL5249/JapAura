import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(NamJapApp());
}

class NamJapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Radha Nam Jap",
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NamJapScreen(),
    );
  }
}

class DailyProgress {
  final String date;
  final int malas;
  final int totalCount;

  DailyProgress({
    required this.date,
    required this.malas,
    required this.totalCount,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'malas': malas,
    'totalCount': totalCount,
  };

  factory DailyProgress.fromJson(Map<String, dynamic> json) => DailyProgress(
    date: json['date'],
    malas: json['malas'],
    totalCount: json['totalCount'],
  );
}

class NamJapScreen extends StatefulWidget {
  @override
  _NamJapScreenState createState() => _NamJapScreenState();
}

class _NamJapScreenState extends State<NamJapScreen>
    with TickerProviderStateMixin {
  int count = 0;
  int mala = 0;
  int todayTotalCount = 0;
  List<DailyProgress> dailyProgress = [];
  final player = AudioPlayer();
  late AnimationController _pulseController;
  late AnimationController _malaController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _malaAnimation;
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _malaController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    _malaAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _malaController, curve: Curves.elasticOut),
    );
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      count = prefs.getInt('count_$today') ?? 0;
      mala = prefs.getInt('mala_$today') ?? 0;
      todayTotalCount = prefs.getInt('total_count_$today') ?? 0;
    });

    // Load historical data
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith('mala_'))
        .toList();
    List<DailyProgress> progress = [];

    for (String key in keys) {
      String date = key.substring(5); // Remove 'mala_' prefix
      int malas = prefs.getInt('mala_$date') ?? 0;
      int totalCount = prefs.getInt('total_count_$date') ?? 0;

      if (malas > 0 || totalCount > 0) {
        progress.add(
          DailyProgress(date: date, malas: malas, totalCount: totalCount),
        );
      }
    }

    progress.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      dailyProgress = progress;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count_$today', count);
    await prefs.setInt('mala_$today', mala);
    await prefs.setInt('total_count_$today', todayTotalCount);
  }

  void _increment() async {
    _pulseController.forward().then((_) => _pulseController.reverse());

    setState(() {
      count++;
      todayTotalCount++;
      if (count >= 108) {
        mala++;
        count = 0;
        _notifyMalaComplete();
      }
    });

    await _saveData();

    // Update daily progress list
    int existingIndex = dailyProgress.indexWhere((p) => p.date == today);
    if (existingIndex != -1) {
      dailyProgress[existingIndex] = DailyProgress(
        date: today,
        malas: mala,
        totalCount: todayTotalCount,
      );
    } else {
      dailyProgress.insert(
        0,
        DailyProgress(date: today, malas: mala, totalCount: todayTotalCount),
      );
    }
  }

  void _notifyMalaComplete() async {
    _malaController.forward().then((_) => _malaController.reverse());

    // Vibration
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }

    // Play bell sound
    try {
      await player.play(AssetSource('audio/bell.mp3'));
    } catch (e) {
      // Handle audio file not found
      print('Audio file not found: $e');
    }

    // Show congratulations dialog
    _showMalaCompleteDialog();
  }

  void _showMalaCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.celebration, color: Colors.orange),
              SizedBox(width: 8),
              Text('Mala Complete!', style: TextStyle(color: Colors.orange)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉 Congratulations! 🎉'),
              SizedBox(height: 8),
              Text('You have completed $mala mala(s) today!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Reset Today\'s Progress?'),
          content: Text(
            'This will reset today\'s count and mala progress. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  count = 0;
                  mala = 0;
                  todayTotalCount = 0;
                });
                _saveData();
                Navigator.of(context).pop();
              },
              child: Text('Reset', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showProgressHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => ProgressHistorySheet(
          dailyProgress: dailyProgress,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _malaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = count / 108;

    return GestureDetector(
      onTap: _increment,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              "assets/images/radha.png",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.pink.shade200, Colors.orange.shade300],
                    ),
                  ),
                );
              },
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Top Stats Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Today',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '$todayTotalCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Streak',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '${_calculateStreak()}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showProgressHistory,
                      child: Icon(Icons.history, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
            ),
            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Text(
                          "Radhe Radhe 🙏",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black54,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 50),

                  // Progress Circle
                  Container(
                    width: 200,
                    height: 200,
                    child: Stack(
                      children: [
                        // Background circle
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                        ),
                        // Progress circle
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.yellowAccent,
                          ),
                        ),
                        // Count text
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$count",
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(blurRadius: 5, color: Colors.black),
                                  ],
                                ),
                              ),
                              Text(
                                "/ 108",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Mala count
                  AnimatedBuilder(
                    animation: _malaAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _malaAnimation.value,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.lightGreenAccent,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            "Mala Completed: $mala",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 30),

                  // Tap instruction
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Tap anywhere to count",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _reset,
          icon: Icon(Icons.refresh, color: Colors.white),
          label: Text('Reset', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.pink.shade600,
          elevation: 8,
        ),
      ),
    );
  }

  int _calculateStreak() {
    if (dailyProgress.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < dailyProgress.length; i++) {
      String expectedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(currentDate.subtract(Duration(days: i)));

      if (i < dailyProgress.length && dailyProgress[i].date == expectedDate) {
        if (dailyProgress[i].malas > 0 || dailyProgress[i].totalCount > 0) {
          streak++;
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return streak;
  }
}

// Custom Circular Progress Painter
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProgressHistorySheet extends StatelessWidget {
  final List<DailyProgress> dailyProgress;
  final ScrollController scrollController;

  const ProgressHistorySheet({
    Key? key,
    required this.dailyProgress,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.pink),
                SizedBox(width: 8),
                Text(
                  'Progress History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: dailyProgress.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No progress yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          'Start your jap journey today!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: dailyProgress.length,
                    itemBuilder: (context, index) {
                      final progress = dailyProgress[index];
                      final date = DateTime.parse(progress.date);
                      final isToday =
                          progress.date ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now());

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.pink.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: isToday
                              ? Border.all(color: Colors.pink.shade200)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? Colors.pink
                                    : Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'EEEE, MMM dd, yyyy',
                                    ).format(date),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  if (isToday)
                                    Text(
                                      'Today',
                                      style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${progress.malas} Malas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                                Text(
                                  '${progress.totalCount} Total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
