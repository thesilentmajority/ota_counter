import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/counter_model.dart';

class CounterPieChart extends StatefulWidget {
  final List<CounterModel> counters;
  final int total;

  const CounterPieChart({
    super.key,
    required this.counters,
    required this.total,
  });

  @override
  State<CounterPieChart> createState() => _CounterPieChartState();
}

class _CounterPieChartState extends State<CounterPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.counters.isEmpty || widget.total == 0) {
      return const Center(child: Text('暂无数据'));
    }

    // 获取屏幕尺寸
    final size = MediaQuery.of(context).size;
    final chartSize = size.width * 0.8; // 图表宽度为屏幕宽度的80%
    final maxHeight = size.height * 0.6; // 最大高度为屏幕高度的60%
    final chartHeight = chartSize < maxHeight ? chartSize : maxHeight;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: chartHeight,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: chartHeight * 0.1, // 中心空白区域大小随图表大小变化
                    sections: _buildSections(chartHeight),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _buildLegends(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double chartHeight) {
    final baseRadius = chartHeight * 0.35; // 基础半径随图表大小变化
    
    return List.generate(widget.counters.length, (i) {
      final counter = widget.counters[i];
      final percentage = counter.count / widget.total;
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? baseRadius * 1.1 : baseRadius;
      final fontSize = isTouched ? 14.0 : 12.0;

      return PieChartSectionData(
        color: counter.colorValue,
        value: counter.count.toDouble(),
        title: '${(percentage * 100).toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: _isColorDark(counter.colorValue) ? Colors.white : Colors.black,
          shadows: const [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: isTouched ? _Badge(
          counter.name,
          counter.count.toString(),
          counter.colorValue,
        ) : null,
        badgePositionPercentageOffset: 1.2,
      );
    });
  }

  List<Widget> _buildLegends() {
    return widget.counters.map((counter) {
      final percentage = counter.count / widget.total;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: counter.colorValue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${counter.name} (${counter.count})',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      );
    }).toList();
  }

  bool _isColorDark(Color color) {
    return color.computeLuminance() < 0.5;
  }
}

class _Badge extends StatelessWidget {
  final String name;
  final String value;
  final Color color;

  const _Badge(this.name, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _isColorDark(color) ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isColorDark(Color color) {
    return color.computeLuminance() < 0.5;
  }
} 