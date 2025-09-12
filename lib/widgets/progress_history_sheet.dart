import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_progress.dart';
import '../models/mantra.dart';

class ProgressHistorySheet extends StatelessWidget {
  final List<DailyProgress> dailyProgress;
  final ScrollController scrollController;
  final Mantra mantra;

  const ProgressHistorySheet({
    Key? key,
    required this.dailyProgress,
    required this.scrollController,
    required this.mantra,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHandleBar(),
          _buildHeader(),
          Expanded(
            child: dailyProgress.isEmpty
                ? _buildEmptyState()
                : _buildProgressList(),
          ),
        ],
      ),
    );
  }

  /// --- UI PARTS ---

  Widget _buildHandleBar() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mantra.primaryColor.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.history,
              color: mantra.primaryColor.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  mantra.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: mantra.primaryColor.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 20),
          Text(
            'No progress yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your ${mantra.name} jap today!',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressList() {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: dailyProgress.length,
      itemBuilder: (context, index) {
        final progress = dailyProgress[index];
        final date = DateTime.parse(progress.date);
        final isToday =
            progress.date == DateFormat('yyyy-MM-dd').format(DateTime.now());

        return _buildProgressCard(progress, date, isToday);
      },
    );
  }

  Widget _buildProgressCard(
    DailyProgress progress,
    DateTime date,
    bool isToday,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isToday ? mantra.primaryColor.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: mantra.primaryColor.shade200, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDateCircle(date, isToday),
          const SizedBox(width: 16),
          _buildProgressDetails(progress, date, isToday),
        ],
      ),
    );
  }

  Widget _buildDateCircle(DateTime date, bool isToday) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isToday
              ? [mantra.primaryColor.shade400, mantra.secondaryColor.shade400]
              : [Colors.grey.shade400, Colors.grey.shade600],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isToday ? mantra.primaryColor : Colors.grey).withOpacity(
              0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDetails(
    DailyProgress progress,
    DateTime date,
    bool isToday,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMM d, y').format(date),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isToday
                  ? mantra.primaryColor.shade600
                  : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.all_inclusive, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                'Malas: ${progress.malas}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? mantra.primaryColor.shade700
                      : Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.add_circle_outline,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                'Total: ${progress.totalCount}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? mantra.primaryColor.shade700
                      : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
