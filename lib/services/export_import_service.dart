import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/counter_model.dart';
import 'package:path/path.dart' as path;

class ExportImportService {
  static Future<String> exportData(List<CounterModel> counters) async {
    final data = counters.map((counter) => counter.toMap()).toList();
    final jsonStr = jsonEncode(data);
    
    if (Platform.isAndroid) {
      // 在 Android 上使用下载目录
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        throw Exception('找不到下载目录');
      }

      final fileName = 'counters_${DateTime.now().millisecondsSinceEpoch}.txt';
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsString(jsonStr);
      return filePath;
    } else {
      // 在其他平台使用文件选择器
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '选择保存位置',
        fileName: 'counters_${DateTime.now().millisecondsSinceEpoch}.txt',
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result == null) {
        throw Exception('未选择保存位置');
      }

      final file = File(result);
      await file.writeAsString(jsonStr);
      return result;
    }
  }

  static Future<List<CounterModel>> importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      dialogTitle: '选择要导入的文件',
    );

    if (result == null || result.files.isEmpty) return [];

    final file = File(result.files.first.path!);
    final jsonStr = await file.readAsString();
    
    try {
      final List<dynamic> data = jsonDecode(jsonStr);
      return data.map((item) => CounterModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FormatException('文件格式错误');
    }
  }
} 