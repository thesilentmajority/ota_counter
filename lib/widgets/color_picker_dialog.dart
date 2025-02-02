import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _currentColor;
  final _redController = TextEditingController();
  final _greenController = TextEditingController();
  final _blueController = TextEditingController();

  static const List<Color> _presetColors = [
    Colors.red,
    Colors.yellow,
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.purple,
    Colors.black,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _updateTextFields();
  }

  void _updateTextFields() {
    _redController.text = _currentColor.red.toString();
    _greenController.text = _currentColor.green.toString();
    _blueController.text = _currentColor.blue.toString();
  }

  void _updateColorFromRGB() {
    final r = int.tryParse(_redController.text) ?? 0;
    final g = int.tryParse(_greenController.text) ?? 0;
    final b = int.tryParse(_blueController.text) ?? 0;
    
    setState(() {
      _currentColor = Color.fromRGBO(
        r.clamp(0, 255),
        g.clamp(0, 255),
        b.clamp(0, 255),
        1,
      );
    });
    widget.onColorChanged(_currentColor);
  }

  @override
  void dispose() {
    _redController.dispose();
    _greenController.dispose();
    _blueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸
    final size = MediaQuery.of(context).size;
    final dialogWidth = size.width * 0.8;
    final dialogHeight = size.height * 0.8;

    return Dialog(
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择颜色',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // RGB 输入
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _redController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'R',
                              helperText: '0-255',
                            ),
                            onChanged: (_) => _updateColorFromRGB(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _greenController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'G',
                              helperText: '0-255',
                            ),
                            onChanged: (_) => _updateColorFromRGB(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _blueController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'B',
                              helperText: '0-255',
                            ),
                            onChanged: (_) => _updateColorFromRGB(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 预设颜色
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentColor = color;
                              _updateTextFields();
                            });
                            widget.onColorChanged(color);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color == _currentColor ? Colors.black : Colors.grey,
                                width: color == _currentColor ? 2 : 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // 颜色选择器
                    SizedBox(
                      width: dialogWidth * 0.8,
                      child: ColorPicker(
                        pickerColor: _currentColor,
                        onColorChanged: (color) {
                          setState(() {
                            _currentColor = color;
                            _updateTextFields();
                          });
                          widget.onColorChanged(color);
                        },
                        enableAlpha: false,
                        displayThumbColor: true,
                        portraitOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 