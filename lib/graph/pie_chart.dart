import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChartScreen extends StatefulWidget {
  const PieChartScreen({super.key});

  @override
  State<PieChartScreen> createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  late List<PieData> pieData;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    pieData = [
      PieData('Happy', 100, Colors.green),
      PieData('Bad', 75, Colors.red),
      PieData('Sad', 25, Colors.blue),
      PieData('Angry', 50, Colors.orange),
      PieData('Neutral', 30, Colors.grey),
      PieData('Neutral', 30, Colors.blueGrey),
      PieData('Neutral', 60, Colors.grey),
      PieData('Neutral', 60, Colors.pink),
      PieData('Neutral', 20, Colors.brown),
      PieData('Neutral', 70, Colors.amber),
      PieData('Neutral', 10, Colors.greenAccent),
      PieData('Neutral', 49, Colors.yellow),
    ];
    _tooltip = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Mood Distribution',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.5,
                    padding: const EdgeInsets.all(60.0),
                    child: SfCircularChart(
                      margin: const EdgeInsets.all(0),
                      tooltipBehavior: _tooltip,
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap,
                      ),
                      series: <PieSeries<PieData, String>>[
                        PieSeries<PieData, String>(
                          dataSource: pieData,
                          xValueMapper: (PieData data, _) => data.category,
                          yValueMapper: (PieData data, _) => data.value,
                          pointColorMapper: (PieData data, _) => data.color,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            labelIntersectAction: LabelIntersectAction.none,
                            connectorLineSettings: ConnectorLineSettings(
                              type: ConnectorType.line,
                              length: '10%',
                              width: 2,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          dataLabelMapper: (PieData data, _) => '${data.category}\n${data.value}',
                          enableTooltip: true,
                          animationDuration: 500,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PieData {
  final String category;
  final int value;
  final Color color;

  PieData(this.category, this.value, this.color);
}

