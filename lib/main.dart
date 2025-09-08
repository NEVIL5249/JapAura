import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    _malaAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration,
                  color: Colors.orange.shade600,
                  size: 32,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Mala Complete!',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉 Congratulations! 🎉', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text(
                'You have completed $mala mala(s) today!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Continue', style: TextStyle(fontSize: 16)),
              ),
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
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.refresh, color: Colors.red.shade600),
              SizedBox(width: 8),
              Text('Reset Today\'s Progress?'),
            ],
          ),
          content: Text(
            'This will reset today\'s count and mala progress. Are you sure?',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  count = 0;
                  mala = 0;
                  todayTotalCount = 0;
                });
                _saveData();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Reset'),
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
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
            // Background Image with fallback
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.pink.shade300,
                    Colors.orange.shade400,
                  ],
                ),
              ),
              child: Image.asset(
                "assets/images/radha.png",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container();
                },
              ),
            ),

            // Professional gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),

            // Top Stats Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 15,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard('Today', '$todayTotalCount', Colors.white),
                    _buildStatCard(
                      'Streak',
                      '${_calculateStreak()}',
                      Colors.orange.shade300,
                    ),
                    GestureDetector(
                      onTap: _showProgressHistory,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
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
                  // Title with professional styling
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Radhe Radhe 🙏",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  blurRadius: 15,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 60),

                  // Professional Progress Circle
                  Container(
                    width: 240,
                    height: 240,
                    child: Stack(
                      children: [
                        // Outer glow effect
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // Background circle
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        // Custom Progress Circle
                        CustomPaint(
                          size: Size(240, 240),
                          painter: CircularProgressPainter(
                            progress: progress,
                            strokeWidth: 8,
                            progressColor: Colors.orange.shade300,
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        // Count text with professional styling
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$count",
                                style: TextStyle(
                                  fontSize: 58,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "/ 108",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 50),

                  // Professional Mala Display
                  AnimatedBuilder(
                    animation: _malaAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _malaAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              "Mala Completed",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "$mala",
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange.shade300,
                                shadows: [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black.withOpacity(0.4),
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 40),

                  // Tap instruction with modern styling
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      "Tap anywhere to count",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Conditional floating action button
        floatingActionButton: (mala > 0 || todayTotalCount > 0)
            ? FloatingActionButton(
                onPressed: _reset,
                backgroundColor: Colors.pink.withOpacity(0.9),
                elevation: 8,
                child: Icon(Icons.refresh, color: Colors.white, size: 20),
              )
            : null,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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

// Professional Custom Circular Progress Painter
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

    // Progress arc with gradient effect
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            progressColor.withOpacity(0.8),
            progressColor,
            progressColor.withOpacity(0.9),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
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

      // Add a glowing dot at the end of progress
      if (progress < 1.0) {
        final endAngle = -math.pi / 2 + sweepAngle;
        final dotX = center.dx + radius * math.cos(endAngle);
        final dotY = center.dy + radius * math.sin(endAngle);

        final dotPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2, dotPaint);
      }
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.pink.shade600,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Progress History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
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
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No progress yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start your jap journey today!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    itemCount: dailyProgress.length,
                    itemBuilder: (context, index) {
                      final progress = dailyProgress[index];
                      final date = DateTime.parse(progress.date);
                      final isToday =
                          progress.date ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now());

                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.pink.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: isToday
                              ? Border.all(
                                  color: Colors.pink.shade200,
                                  width: 1.5,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isToday
                                      ? [
                                          Colors.pink.shade400,
                                          Colors.pink.shade600,
                                        ]
                                      : [
                                          Colors.grey.shade400,
                                          Colors.grey.shade600,
                                        ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isToday ? Colors.pink : Colors.grey)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
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
                                    DateFormat('EEEE, MMM d, y').format(date),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isToday
                                          ? Colors.pink.shade400
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.all_inclusive,
                                        size: 16,
                                        color: Colors.grey.shade500,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Malas: ${progress.malas}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isToday
                                              ? Colors.pink.shade700
                                              : Colors.grey.shade800,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 16,
                                        color: Colors.grey.shade500,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Total: ${progress.totalCount}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isToday
                                              ? Colors.pink.shade700
                                              : Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
