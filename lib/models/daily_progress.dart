class DailyProgress {
  final String date;
  final int malas;
  final int totalCount;
  final String mantraId;

  DailyProgress({
    required this.date,
    required this.malas,
    required this.totalCount,
    required this.mantraId,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'malas': malas,
    'totalCount': totalCount,
    'mantraId': mantraId,
  };

  factory DailyProgress.fromJson(Map<String, dynamic> json) => DailyProgress(
    date: json['date'],
    malas: json['malas'],
    totalCount: json['totalCount'],
    mantraId: json['mantraId'] ?? 'radhe_radhe',
  );
}
