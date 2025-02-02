import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/counter_model.dart';

class CounterCard extends StatelessWidget {
  final CounterModel counter;
  final double percentage;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CounterCard({
    super.key,
    required this.counter,
    required this.percentage,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: counter.colorValue.withAlpha(179),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 计算合适的字体大小
                      final numberStr = counter.count.toString();
                      final maxWidth = constraints.maxWidth * 0.8;
                      final maxHeight = constraints.maxHeight * 0.4;
                      
                      // 根据容器大小计算基础字体大小
                      double fontSize = (maxHeight * 0.8).clamp(20.0, 48.0);
                      
                      // 根据数字长度调整字体大小
                      if (numberStr.length > 3) {
                        fontSize *= (3 / numberStr.length);
                      }
                      
                      // 确保百分比和名称的字体大小也随容器大小变化
                      final percentageFontSize = (maxHeight * 0.15).clamp(12.0, 18.0);
                      final nameFontSize = (maxHeight * 0.18).clamp(14.0, 20.0);
                      
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: maxWidth,
                                maxHeight: maxHeight,
                              ),
                              child: Text(
                                numberStr,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(percentage * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: percentageFontSize,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            counter.name,
                            style: TextStyle(
                              fontSize: nameFontSize,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 