import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/counter_model.dart';

class ExportImportService {
  static Future<String> exportData(List<CounterModel> counters) async {
    final data = counters.map((counter) => counter.toMap()).toList();
    final jsonStr = jsonEncode(data);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'counters_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonStr);
    
    return file.path;
  }

  static Future<List<CounterModel>> importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
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