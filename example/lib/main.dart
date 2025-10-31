import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_detector/flutter_face_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterFaceDetectorPlugin = FlutterFaceDetector();

  String _confidence = '0%';
  String _inferenceTime = '0ms';
  String _platformVersion = 'Unknown';
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      final platformVersion =
          await _flutterFaceDetectorPlugin.getPlatformVersion() ??
              'Unknown platform version';
      setState(() => _platformVersion = platformVersion);
    } on PlatformException {
      setState(() => _platformVersion = 'Failed to get platform version.');
    }
  }

  Future<void> _pickImageAndDetect() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() => _imageBytes = bytes);

    try {
      final Map<String, dynamic> result =
          await _flutterFaceDetectorPlugin.faceDetectionFromImage(bytes);

      setState(() {
        _confidence = result['confidence']?.toString() ?? 'N/A';
        _inferenceTime = result['inferenceTime']?.toString() ?? 'N/A';
      });
    } catch (e) {
      debugPrint('Face detection error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Face Detector Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Platform: $_platformVersion'),
              const SizedBox(height: 20),
              if (_imageBytes != null)
                Image.memory(_imageBytes!,
                    width: 200, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 20),
              Text('Detection confidence: $_confidence'),
              Text('Inference time: $_inferenceTime'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImageAndDetect,
                child: const Text('Select from Photo Library'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
