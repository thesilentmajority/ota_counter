import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'models/counter_model.dart';
import 'widgets/counter_card.dart';
import 'widgets/add_counter_dialog.dart';
import 'services/database_service.dart';
import 'services/settings_service.dart';
import 'services/export_import_service.dart';
import 'pages/image_page.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;  // 添加 Platform 导入
import 'pages/chart_page.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 仅在非 Android 平台初始化 FFI
  if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '计数器',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<CounterModel> _counters = [];
  double _gridSize = 2;  // 修改默认值为2
  bool _sortAscending = true;  // 添加排序方向状态

  @override
  void initState() {
    super.initState();
    _loadCounters();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final size = await SettingsService.getGridSize();
    setState(() {
      _gridSize = size;
    });
  }

  Future<void> _loadCounters() async {
    try {
      final counters = await DatabaseService.getCounters();
      setState(() {
        _counters.clear();
        _counters.addAll(counters);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: ${e.toString()}')),
        );
      }
    }
  }

  int get _total => _counters.fold<int>(0, (sum, counter) => sum + counter.count);

  double _getPercentage(int count) {
    return _total == 0 ? 0 : count / _total;
  }

  void _incrementCounter(int index) async {
    final counter = _counters[index];
    final updatedCounter = counter.copyWith(count: counter.count + 1);
    
    setState(() {
      _counters[index] = updatedCounter;
    });

    if (counter.id != null) {
      await DatabaseService.updateCounter(counter.id!, updatedCounter);
    }
  }

  Future<void> _addCounter() async {
    try {
      final result = await showDialog<CounterModel>(
        context: context,
        builder: (context) => const AddCounterDialog(),
      );
      
      if (result != null) {
        await DatabaseService.insertCounter(result);
        await _loadCounters();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _editCounter(int index) async {
    final counter = _counters[index];
    final result = await showDialog<CounterModel>(
      context: context,
      builder: (context) => AddCounterDialog(initialData: counter),
    );
    
    if (result != null && counter.id != null) {
      await DatabaseService.updateCounter(counter.id!, result);
      await _loadCounters();
    }
  }

  void _deleteCounter(int index) {
    final counter = _counters[index];
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个计数器吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed ?? false) {
        if (counter.id != null) {
          await DatabaseService.deleteCounter(counter.id!);
          await _loadCounters();
        }
      }
    });
  }

  void _showGridSizeDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => TweenAnimationBuilder(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          tween: Tween<double>(begin: 0.8, end: 1.0),
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child,
          ),
          child: AlertDialog(
            title: const Text('调整网格大小'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _gridSize,
                  min: 1,     // 从 2 改为 1
                  max: 5,     // 从 10 改为 5
                  divisions: 4,  // 从 8 改为 4
                  label: _gridSize.round().toString(),
                  onChanged: (value) {
                    setDialogState(() {
                      setState(() {
                        _gridSize = value.roundToDouble();
                        SettingsService.saveGridSize(_gridSize);
                      });
                    });
                  },
                ),
                Text('每行显示 ${_gridSize.round()} 个'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('确定'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sortCounters() {
    setState(() {
      _sortAscending = !_sortAscending;  // 切换排序方向
      _counters.sort((a, b) => _sortAscending 
          ? a.count.compareTo(b.count)
          : b.count.compareTo(a.count));
    });
  }

  void _showPieChart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartPage(
          counters: _counters,
          total: _total,
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      await ExportImportService.exportData(_counters);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _importData() async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认导入'),
          content: const Text('导入将清空当前所有数据，确定继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确定'),
            ),
          ],
        ),
      );

      if (result != true) return;

      final counters = await ExportImportService.importData();
      if (counters.isEmpty) return;

      // 清空当前数据
      final db = await DatabaseService.database;
      await db.delete(DatabaseService.tableName);

      // 导入新数据
      for (final counter in counters) {
        await DatabaseService.insertCounter(counter);
      }

      await _loadCounters();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据导入成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: ${e.toString()}')),
        );
      }
    }
  }

  // 修改宽高比计算方法
  double _calculateAspectRatio(double gridSize) {
    final ratio = switch (gridSize.toInt()) {
      1 => 0.95,  // 1列
      2 => 0.85,  // 2列
      3 => 0.75,  // 3列
      4 => 0.65,  // 4列
      5 => 0.55,  // 5列
      _ => 0.85,  // 默认
    };
    
    return ratio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha(204),
        title: Text('总计 $_total'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportData();
                  break;
                case 'import':
                  _importData();
                  break;
                case 'grid':
                  _showGridSizeDialog();
                  break;
                case 'sort':
                  _sortCounters();
                  break;
                case 'chart':
                  _showPieChart();
                  break;
                case 'image':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ImagePage()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('导出数据'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('导入数据'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'grid',
                child: Row(
                  children: [
                    Icon(Icons.grid_4x4),
                    SizedBox(width: 8),
                    Text('网格大小'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                    const SizedBox(width: 8),
                    Text(_sortAscending ? '按数量升序' : '按数量降序'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'chart',
                child: Row(
                  children: [
                    Icon(Icons.pie_chart),
                    SizedBox(width: 8),
                    Text('饼图统计'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'image',
                child: Row(
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 8),
                    Text('抽取图片'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withAlpha(26),
              Colors.purple.withAlpha(26),
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final counter = _counters[index];
                    return RepaintBoundary(
                      child: CounterCard(
                        key: ValueKey(counter.id),
                        counter: counter,
                        percentage: _getPercentage(counter.count),
                        onTap: () => _incrementCounter(index),
                        onEdit: () => _editCounter(index),
                        onDelete: () => _deleteCounter(index),
                      ),
                    );
                  },
                  childCount: _counters.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridSize.toInt(),
                  childAspectRatio: _calculateAspectRatio(_gridSize),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}
