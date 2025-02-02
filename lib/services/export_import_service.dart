import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/counter_model.dart';
import 'package:path/path.dart' as path;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportImportService {
  static Future<void> exportData(List<CounterModel> counters) async {
    final data = counters.map((counter) => counter.toMap()).toList();
    final jsonStr = jsonEncode(data);
    
    // 创建临时文件
    final tempDir = await getTemporaryDirectory();
    final fileName = 'counters_${DateTime.now().millisecondsSinceEpoch}.txt';
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsString(jsonStr);

    // 分享文件
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      subject: '计数器数据导出',
    );

    // 删除临时文件
    await tempFile.delete();
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