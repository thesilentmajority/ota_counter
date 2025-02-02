import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  Color _currentColor = Colors.grey[200]!;
  StreamSubscription? _accelerometerSubscription;
  DateTime? _lastShakeTime;
  static const _shakeThreshold = 15.0;
  static const _shakeCooldown = Duration(milliseconds: 1000);
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _initShakeDetection();
    }
  }

  void _initShakeDetection() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final acceleration = sqrt(
        event.x * event.x +
        event.y * event.y +
        event.z * event.z,
      );

      final now = DateTime.now();
      if (_lastShakeTime == null ||
          now.difference(_lastShakeTime!) > _shakeCooldown) {
        if (acceleration > _shakeThreshold) {
          _lastShakeTime = now;
          _generateRandomImage();
        }
      }
    });
  }

  void _generateRandomImage() {
    setState(() {
      _currentColor = Color.fromRGBO(
        Random().nextInt(256),
        Random().nextInt(256),
        Random().nextInt(256),
        1,
      );
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = Theme.of(context).colorScheme.inversePrimary.withAlpha(204);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('抽取图片'),
        backgroundColor: appBarColor,
      ),
      body: Center(
        child: GestureDetector(
          onTap: _generateRandomImage,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: _currentColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[400]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '点击或摇晃手机\n随机抽取',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 