import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MoodBarChart extends StatefulWidget {
  const MoodBarChart({super.key});

  @override
  State<MoodBarChart> createState() => _MoodBarChartState();
}

class _MoodBarChartState extends State<MoodBarChart> {
  final List<MoodEntry> moodData = [
    MoodEntry(time: DateTime(2025, 1, 1, 20, 00), mood: "happy"),
    MoodEntry(time: DateTime(2025, 1, 1, 19, 00), mood: "angry"),
    MoodEntry(time: DateTime(2025, 1, 1, 21, 00), mood: "bad"),
    MoodEntry(time: DateTime(2025, 1, 1, 3, 00), mood: "angry"),
    MoodEntry(time: DateTime(2025, 1, 1, 6, 30), mood: "neutral"),
    MoodEntry(time: DateTime(2025, 1, 1, 2, 30), mood: "happy"),
    MoodEntry(time: DateTime(2025, 1, 2, 9, 00), mood: "bad"),
    MoodEntry(time: DateTime(2025, 1, 3, 19, 00), mood: "happy"),
    MoodEntry(time: DateTime(2025, 1, 3, 20, 30), mood: "bad"),
    MoodEntry(time: DateTime(2025, 1, 4, 22, 00), mood: "bad"),
    MoodEntry(time: DateTime(2025, 1, 4, 12, 00), mood: "happy"),
    MoodEntry(time: DateTime(2025, 1, 5, 14, 00), mood: "neutral"),
    MoodEntry(time: DateTime(2025, 1, 5, 22, 00), mood: "bad"),
    MoodEntry(time: DateTime(2025, 1, 7, 11, 00), mood: "neutral"),
    MoodEntry(time: DateTime(2025, 1, 7, 23, 00), mood: "happy"),
    MoodEntry(time: DateTime(2025, 1, 8, 4, 00), mood: "angry"),
    MoodEntry(time: DateTime(2025, 1, 10, 21, 00), mood: "bad"),
    MoodEntry(time: DateTime(2025, 1, 10, 2, 00), mood: "neutral"),
  ];

  Map<DateTime, List<MoodEntry>> get groupedByDate {
    Map<DateTime, List<MoodEntry>> grouped = {};
    for (var entry in moodData) {
      final date = DateTime(entry.time.year, entry.time.month, entry.time.day);
      grouped.putIfAbsent(date, () => []).add(entry);
    }
    grouped.forEach((key, value) {
      value.sort((a, b) => a.time.compareTo(b.time));
    });
    return grouped;
  }

  List<DateTime> get sortedDates {
    return groupedByDate.keys.toList()..sort();
  }

  double _timeToMinutes(DateTime time) {
    return time.hour * 60.0 + time.minute;
  }

  int get maxSegmentsPerDate {
    int max = 0;
    groupedByDate.forEach((key, value) {
      if (value.length > max) max = value.length;
    });
    return max;
  }

  List<DateSegmentData> _getSegmentsForDate(DateTime date) {
    final entriesForDate = groupedByDate[date] ?? [];
    if (entriesForDate.isEmpty) return [];

    List<DateSegmentData> segments = [];
    double startTime = 0;

    for (var moodEntry in entriesForDate) {
      double endTime = _timeToMinutes(moodEntry.time);
      if (endTime > startTime) {
        segments.add(DateSegmentData(
          date: date,
          startTime: startTime,
          endTime: endTime,
          mood: moodEntry.mood,
        ));
      }
      startTime = endTime;
    }

    return segments;
  }

  @override
  Widget build(BuildContext context) {
    final dates = sortedDates;
    final maxSegments = maxSegmentsPerDate;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: 400,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: dates.length * 80.0,
              child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
              title: AxisTitle(text: ''),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 1440,
              interval: 360,
              labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
              title: AxisTitle(text: ''),
              axisLabelFormatter: (args) {
                return ChartAxisLabel(
                  _formatTime(args.value.toDouble()),
                  const TextStyle(fontSize: 11, color: Colors.grey),
                );
              },
            ),
            plotAreaBorderWidth: 1,
            plotAreaBorderColor: Colors.grey.withOpacity(0.3),
            zoomPanBehavior: ZoomPanBehavior(
              enablePanning: true,
              enablePinching: true,
              enableDoubleTapZooming: true,
            ),
            series: _buildStackedSeries(dates, maxSegments),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<StackedColumnSeries<SegmentData, String>> _buildStackedSeries(
      List<DateTime> dates, int maxSegments) {
    List<StackedColumnSeries<SegmentData, String>> series = [];

    for (int segmentIndex = 0; segmentIndex < maxSegments; segmentIndex++) {
      List<SegmentData> segmentData = [];

      for (var date in dates) {
        final segments = _getSegmentsForDate(date);
        if (segmentIndex < segments.length) {
          final segment = segments[segmentIndex];
          segmentData.add(SegmentData(
            date: date,
            duration: segment.endTime - segment.startTime,
            mood: segment.mood,
            startTime: segment.startTime,
          ));
        } else {
          segmentData.add(SegmentData(
            date: date,
            duration: 0,
            mood: '',
            startTime: 0,
          ));
        }
      }

      series.add(
        StackedColumnSeries<SegmentData, String>(
          dataSource: segmentData,
          xValueMapper: (SegmentData d, _) => _formatDate(d.date),
          yValueMapper: (SegmentData d, _) => d.duration,
          width: 0.6,
          spacing: 0.1,
          pointColorMapper: (SegmentData d, _) {
            if (d.mood.isEmpty || d.duration == 0) {
              return Colors.transparent;
            }
            return getMoodColor(d.mood);
          },
          name: 'Segment${segmentIndex + 1}',
          animationDuration: 0,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      );
    }

    return series;
  }

  String _formatTime(double minutes) {
    if (minutes == 0) return "0";
    int hours = (minutes / 60).floor();
    if (hours == 6) return "06:00 AM";
    if (hours == 12) return "12:00 PM";
    if (hours == 18) return "6:00 PM";
    if (hours == 24 || hours == 0) return "12:00 AM";
    final hour = hours % 12 == 0 ? 12 : hours % 12;
    String period = hours >= 12 ? "PM" : "AM";
    return "$hour:00 $period";
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]}";
  }

  Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case "happy":
        return Colors.green;
      case "bad":
        return Colors.red;
      case "sad":
        return Colors.blue;
      case "angry":
        return Colors.orange;
      case "neutral":
        return Colors.grey;
      default:
        return Colors.black45;
    }
  }
}

class DateSegmentData {
  final DateTime date;
  final double startTime;
  final double endTime;
  final String mood;

  DateSegmentData({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.mood,
  });
}

class SegmentData {
  final DateTime date;
  final double duration;
  final String mood;
  final double startTime;

  SegmentData({
    required this.date,
    required this.duration,
    required this.mood,
    required this.startTime,
  });
}

class MoodEntry {
  final DateTime time;
  final String mood;

  MoodEntry({required this.time, required this.mood});
}
