import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CombinationChart extends StatefulWidget {
  const CombinationChart({super.key});

  @override
  State<CombinationChart> createState() => _CombinationChartState();
}

class _CombinationChartState extends State<CombinationChart> {
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

  List<SleepData> get sleepDataList {
    return [
      SleepData(date: DateTime(2025, 1, 1), hours: 8, minutes: 0),
      SleepData(date: DateTime(2025, 1, 2), hours: 3, minutes: 0),
      SleepData(date: DateTime(2025, 1, 3), hours: 3, minutes: 8),
      SleepData(date: DateTime(2025, 1, 4), hours: 6, minutes: 30),
      SleepData(date: DateTime(2025, 1, 5), hours: 7, minutes: 15),
      SleepData(date: DateTime(2025, 1, 7), hours: 5, minutes: 45),
      SleepData(date: DateTime(2025, 1, 8), hours: 4, minutes: 20),
      SleepData(date: DateTime(2025, 1, 10), hours: 14, minutes: 30),
    ];
  }

  Map<DateTime, SleepData> get sleepDataMap {
    Map<DateTime, SleepData> map = {};
    for (var sleep in sleepDataList) {
      final date = DateTime(sleep.date.year, sleep.date.month, sleep.date.day);
      map[date] = sleep;
    }
    return map;
  }

  double _getSleepMinutesForDate(DateTime date) {
    final sleep = sleepDataMap[date];
    if (sleep == null) return 0;
    return ((sleep.hours * 60) + sleep.minutes).toDouble();
  }

  List<MedicationData> get medicationDataList {
    return [
      MedicationData(date: DateTime(2025, 1, 1), value: 120),
      MedicationData(date: DateTime(2025, 1, 2), value: 180),
      MedicationData(date: DateTime(2025, 1, 3), value: 90),
      MedicationData(date: DateTime(2025, 1, 4), value: 240),
      MedicationData(date: DateTime(2025, 1, 5), value: 150),
      MedicationData(date: DateTime(2025, 1, 7), value: 200),
      MedicationData(date: DateTime(2025, 1, 8), value: 110),
      MedicationData(date: DateTime(2025, 1, 10), value: 300),
    ];
  }

  Map<DateTime, MedicationData> get medicationDataMap {
    Map<DateTime, MedicationData> map = {};
    for (var medication in medicationDataList) {
      final date = DateTime(medication.date.year, medication.date.month, medication.date.day);
      map[date] = medication;
    }
    return map;
  }

  double _getMedicationValueForDate(DateTime date) {
    final medication = medicationDataMap[date];
    if (medication == null) return 0;
    return medication.value.toDouble();
  }

  String _formatSleepTime(double minutes) {
    if (minutes == 0) return "0 hours";
    int hours = (minutes / 60).floor();
    int mins = (minutes % 60).floor();
    if (hours == 0) {
      return "$mins minutes";
    } else if (mins == 0) {
      return "$hours ${hours == 1 ? 'hour' : 'hours'}";
    } else {
      return "$hours ${hours == 1 ? 'hour' : 'hours'} $mins minutes";
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = sortedDates;
    final maxSegments = maxSegmentsPerDate;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  tooltipBehavior: TooltipBehavior(enable: true),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.top,
                  ),
                  series: _buildCombinationSeries(dates, maxSegments),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<CartesianSeries> _buildCombinationSeries(
      List<DateTime> dates, int maxSegments) {
    List<CartesianSeries> series = [];

    List<StackedColumnSeries<SegmentData, String>> stackedSeries = [];
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

      stackedSeries.add(
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

    series.addAll(stackedSeries);

    List<LineData> lineData = dates.map((date) {
      final sleep = sleepDataMap[date];
      return LineData(
        date: date,
        value: _getSleepMinutesForDate(date),
        sleepHours: sleep?.hours ?? 0,
        sleepMinutes: sleep?.minutes ?? 0,
      );
    }).toList();

    series.add(
      LineSeries<LineData, String>(
        dataSource: lineData,
        xValueMapper: (LineData d, _) => _formatDate(d.date),
        yValueMapper: (LineData d, _) => d.value,
        name: 'Sleep',
        color: Colors.purple,
        width: 3,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 6,
          width: 6,
          shape: DataMarkerType.circle,
        ),
        animationDuration: 0,
        dataLabelSettings: DataLabelSettings(
          isVisible: false,
        ),
      ),
    );

    List<MedicationLineData> medicationLineData = dates.map((date) {
      final medication = medicationDataMap[date];
      return MedicationLineData(
        date: date,
        value: _getMedicationValueForDate(date),
        medicationValue: medication?.value ?? 0,
      );
    }).toList();

    series.add(
      LineSeries<MedicationLineData, String>(
        dataSource: medicationLineData,
        xValueMapper: (MedicationLineData d, _) => _formatDate(d.date),
        yValueMapper: (MedicationLineData d, _) => d.value,
        name: 'Medication',
        color: Colors.blue,
        width: 3,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 6,
          width: 6,
          shape: DataMarkerType.circle,
        ),
        animationDuration: 0,
        dataLabelSettings: DataLabelSettings(
          isVisible: false,
        ),
      ),
    );

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

class SleepData {
  final DateTime date;
  final int hours;
  final int minutes;

  SleepData({
    required this.date,
    required this.hours,
    required this.minutes,
  });
}

class LineData {
  final DateTime date;
  final double value;
  final int sleepHours;
  final int sleepMinutes;

  LineData({
    required this.date,
    required this.value,
    required this.sleepHours,
    required this.sleepMinutes,
  });
}

class MedicationData {
  final DateTime date;
  final int value;

  MedicationData({
    required this.date,
    required this.value,
  });
}

class MedicationLineData {
  final DateTime date;
  final double value;
  final int medicationValue;

  MedicationLineData({
    required this.date,
    required this.value,
    required this.medicationValue,
  });
}

class MoodEntry {
  final DateTime time;
  final String mood;

  MoodEntry({required this.time, required this.mood});
}

