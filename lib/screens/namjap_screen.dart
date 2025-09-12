import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:intl/intl.dart';

import '../models/mantra.dart';
import '../models/mantra_data.dart';
import '../models/daily_progress.dart';
import '../widgets/mantra_selection_sheet.dart';
import '../widgets/progress_history_sheet.dart';
import '../widgets/circular_progress_painter.dart';

class NamJapScreen extends StatefulWidget {
  const NamJapScreen({super.key});

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

  // Current selected mantra
  Mantra selectedMantra = MantraData.mantras[0];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadSelectedMantra();
    _loadData();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _malaController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  Future<void> _loadSelectedMantra() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMantraId = prefs.getString('selected_mantra') ?? 'radhe_radhe';
    setState(() {
      selectedMantra = MantraData.getMantraById(savedMantraId);
    });
  }

  Future<void> _saveSelectedMantra(String mantraId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_mantra', mantraId);
  }

  String _getMantraKey(String key) => '${selectedMantra.id}_${key}_$today';
  String _getMantraHistoryKey(String key, String date) =>
      '${selectedMantra.id}_${key}_$date';

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      count = prefs.getInt(_getMantraKey('count')) ?? 0;
      mala = prefs.getInt(_getMantraKey('mala')) ?? 0;
      todayTotalCount = prefs.getInt(_getMantraKey('total_count')) ?? 0;
    });

    // Load historical data
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith('${selectedMantra.id}_mala_'))
        .toList();
    List<DailyProgress> progress = [];

    for (String key in keys) {
      String date = key.substring('${selectedMantra.id}_mala_'.length);
      int malas = prefs.getInt('${selectedMantra.id}_mala_$date') ?? 0;
      int totalCount =
          prefs.getInt('${selectedMantra.id}_total_count_$date') ?? 0;

      if (malas > 0 || totalCount > 0) {
        progress.add(
          DailyProgress(
            date: date,
            malas: malas,
            totalCount: totalCount,
            mantraId: selectedMantra.id,
          ),
        );
      }
    }

    progress.sort((a, b) => b.date.compareTo(a.date));
    setState(() => dailyProgress = progress);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getMantraKey('count'), count);
    await prefs.setInt(_getMantraKey('mala'), mala);
    await prefs.setInt(_getMantraKey('total_count'), todayTotalCount);
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
        mantraId: selectedMantra.id,
      );
    } else {
      dailyProgress.insert(
        0,
        DailyProgress(
          date: today,
          malas: mala,
          totalCount: todayTotalCount,
          mantraId: selectedMantra.id,
        ),
      );
    }
  }

  void _notifyMalaComplete() async {
    _malaController.forward().then((_) => _malaController.reverse());

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 500);
    }

    try {
      await player.play(AssetSource('audio/bell.mp3'));
    } catch (e) {
      debugPrint('Audio file not found: $e');
    }

    _showMalaCompleteDialog();
  }

  void _showMalaCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selectedMantra.primaryColor.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration,
                color: selectedMantra.primaryColor.shade600,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mala Complete!',
              style: TextStyle(
                color: selectedMantra.primaryColor.shade700,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Congratulations!', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'You have completed $mala mala(s) of ${selectedMantra.name} today!',
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
                backgroundColor: selectedMantra.primaryColor.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMantraSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => MantraSelectionSheet(
        currentMantra: selectedMantra,
        onMantraSelected: (mantra) async {
          setState(() => selectedMantra = mantra);
          await _saveSelectedMantra(mantra.id);
          await _loadData();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.refresh, color: selectedMantra.primaryColor.shade600),
            const SizedBox(width: 8),
            const Text('Reset Progress?'),
          ],
        ),
        content: Text(
          'This will reset today\'s count and mala progress for ${selectedMantra.name}. Are you sure?',
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
              backgroundColor: selectedMantra.primaryColor.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showProgressHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
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
          mantra: selectedMantra,
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
            _buildBackground(),
            _buildOverlay(),
            _buildTopStats(),
            _buildMainContent(progress),
          ],
        ),
        floatingActionButton: (mala > 0 || todayTotalCount > 0)
            ? FloatingActionButton(
                onPressed: _reset,
                backgroundColor: selectedMantra.secondaryColor.shade300,
                elevation: 8,
                child: const Icon(Icons.refresh, color: Colors.white, size: 20),
              )
            : null,
      ),
    );
  }

  // 🔹 UI Helpers

  Widget _buildBackground() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          selectedMantra.primaryColor.shade400,
          selectedMantra.secondaryColor.shade300,
          selectedMantra.secondaryColor.shade400,
        ],
      ),
    ),
    child: Image.asset(
      selectedMantra.imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(),
    ),
  );

  Widget _buildOverlay() => Container(
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
  );

  Widget _buildTopStats() => Positioned(
    top: MediaQuery.of(context).padding.top + 15,
    left: 20,
    right: 20,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            selectedMantra.secondaryColor.shade300,
          ),
          Row(
            children: [
              _buildIconButton(
                Icons.format_list_bulleted,
                _showMantraSelection,
              ),
              const SizedBox(width: 8),
              _buildIconButton(Icons.history, _showProgressHistory),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildMainContent(double progress) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        _buildTitle(),
        const SizedBox(height: 60),
        _buildProgressCircle(progress),
        const SizedBox(height: 50),
        _buildMalaDisplay(),
        const SizedBox(height: 40),
        _buildTapInstruction(),
      ],
    ),
  );

  Widget _buildTitle() => AnimatedBuilder(
    animation: _pulseAnimation,
    builder: (context, child) => Transform.scale(
      scale: _pulseAnimation.value,
      child: Text(
        selectedMantra.name,
        style: TextStyle(
          fontSize: selectedMantra.name.length > 20 ? 28 : 36,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );

  Widget _buildProgressCircle(double progress) => Container(
    width: 240,
    height: 240,
    child: Stack(
      children: [
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: selectedMantra.secondaryColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
        ),
        CustomPaint(
          size: const Size(240, 240),
          painter: CircularProgressPainter(
            progress: progress,
            strokeWidth: 8,
            progressColor: selectedMantra.secondaryColor.shade300,
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
        ),
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
                      offset: const Offset(0, 2),
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
  );

  Widget _buildMalaDisplay() => AnimatedBuilder(
    animation: _malaAnimation,
    builder: (context, child) => Transform.scale(
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
          const SizedBox(height: 8),
          Text(
            "$mala",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: selectedMantra.secondaryColor.shade300,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildTapInstruction() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    ),
    child: const Text(
      "Tap anywhere to count",
      style: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _buildStatCard(String label, String value, Color valueColor) => Column(
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
      const SizedBox(height: 4),
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

  Widget _buildIconButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );

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
