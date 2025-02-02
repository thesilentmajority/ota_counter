import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/counter_model.dart';

class CounterPieChart extends StatefulWidget {
  final List<CounterModel> counters;
  final int total;
  final bool showLegend;  // 添加控制图例显示的参数

  const CounterPieChart({
    super.key,
    required this.counters,
    required this.total,
    this.showLegend = true,  // 默认显示图例
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
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    
    // 使用父组件传入的尺寸，或者使用默认计算
    final chartSize = isPortrait 
        ? screenSize.width * 0.9  // 增大到90%
        : screenSize.height * 0.7;  // 增大到70%

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: chartSize,
            width: chartSize,
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
                sectionsSpace: 1,
                centerSpaceRadius: chartSize * 0.07,
                sections: _buildSections(chartSize),
              ),
            ),
          ),
          if (widget.showLegend) ...[  // 根据参数决定是否显示图例
            const SizedBox(height: 10),
            SizedBox(
              width: chartSize * 0.6,
              child: Wrap(
                direction: isPortrait ? Axis.vertical : Axis.horizontal,
                spacing: 10,  // 从 12 减小到 10
                runSpacing: 6,  // 从 8 减小到 6
                alignment: WrapAlignment.center,
                children: _buildLegends(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double chartSize) {
    final baseRadius = chartSize * 0.4;  // 从 0.38 增加到 0.4，使饼图占比更大
    
    return List.generate(widget.counters.length, (i) {
      final counter = widget.counters[i];
      final percentage = counter.count / widget.total;
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? baseRadius * 1.05 : baseRadius;
      final fontSize = isTouched ? 12.0 : 10.0;  // 从 13/11 减小到 12/10

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
        badgePositionPercentageOffset: 1.08,  // 从 1.1 减小到 1.08
      );
    });
  }

  List<Widget> _buildLegends() {
    return widget.counters.map((counter) {
      final percentage = counter.count / widget.total;
      return _LegendItem(
        name: counter.name,
        value: '${counter.count} (${(percentage * 100).toStringAsFixed(1)}%)',
        color: counter.colorValue,
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

class _LegendItem extends StatelessWidget {
  final String name;
  final String value;
  final Color color;

  const _LegendItem({
    Key? key,
    required this.name,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
} 