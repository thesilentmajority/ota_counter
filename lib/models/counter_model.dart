import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';

class CounterModel {
  final int? id;
  final String name;
  final int count;
  final String color;
  final String namePinyin;

  CounterModel({
    this.id,
    required this.name,
    required this.count,
    required this.color,
  }) : namePinyin = PinyinHelper.getPinyinE(
        name, 
        defPinyin: '#', 
        format: PinyinFormat.WITHOUT_TONE,
      );

  CounterModel copyWith({
    int? id,
    String? name,
    int? count,
    String? color,
  }) {
    return CounterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      color: color ?? this.color,
    );
  }

  Color get colorValue {
    if (!color.startsWith('#') || color.length != 7) {
      return Colors.yellow;
    }
    try {
      final colorValue = int.parse('FF${color.substring(1)}', radix: 16);
      return Color(colorValue);
    } catch (e) {
      return Colors.yellow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'count': count,
      'color': color,
    };
  }

  factory CounterModel.fromMap(Map<String, dynamic> map) {
    return CounterModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      count: map['count'] as int,
      color: map['color'] as String,
    );
  }

  HSVColor get hsvColor {
    return HSVColor.fromColor(colorValue);
  }
} 