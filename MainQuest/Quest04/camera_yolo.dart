import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraYoloScreen extends StatefulWidget {
  const CameraYoloScreen({super.key});

  @override
  _CameraYoloScreenState createState() => _CameraYoloScreenState();
}

class _CameraYoloScreenState extends State<CameraYoloScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String _yoloResult = 'No result';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndSendFrame() async {
    try {
      if (_initializeControllerFuture == null) return;
      await _initializeControllerFuture;

      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      String base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://162d-182-229-245-237.ngrok-free.app/predict/'), // ngrok URL로 대체
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        setState(() {
          _yoloResult = _formatDetectionResults(responseData);
        });
      } else {
        setState(() {
          _yoloResult = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _yoloResult = 'Error: $e';
      });
    }
  }

  String _formatDetectionResults(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey('error')) {
      return 'Error: ${jsonData['error']}';
    }

    List<dynamic> detections = jsonData['detections'];
    if (detections.isEmpty) {
      return 'No objects detected';
    }

    Map<String, List<double>> detectionMap = {};
    for (var detection in detections) {
      String className = _getClassName(detection['class']);
      double confidence = detection['confidence'];

      if (detectionMap.containsKey(className)) {
        detectionMap[className]!.add(confidence);
      } else {
        detectionMap[className] = [confidence];
      }
    }

    String result = 'Detected objects:\n';
    detectionMap.forEach((className, confidences) {
      double avgConfidence = confidences.reduce((a, b) => a + b) / confidences.length;
      result += '$className: ${confidences.length} (Avg. Confidence: ${avgConfidence.toStringAsFixed(2)})\n';
    });

    final previewSize = _controller?.value.previewSize;
    if (previewSize != null) {
      result += 'Image size: ${previewSize.height.toInt()} x ${previewSize.width.toInt()}';
    }
    return result;
  }

  String _getClassName(int classId) {
    switch (classId) {
      case 0:
        return 'person';
      case 1:
        return 'bicycle';
      case 2:
        return 'car';
      case 3:
        return 'motorcycle';
      case 4:
        return 'airplane';
      case 5:
        return 'bus';
      case 6:
        return 'train';
      case 7:
        return 'truck';
      case 8:
        return 'boat';
      case 9:
        return 'traffic light';
      case 10:
        return 'fire hydrant';
      case 11:
        return 'stop sign';
      case 12:
        return 'parking meter';
      case 13:
        return 'bench';
      case 14:
        return 'bird';
      case 15:
        return 'cat';
      case 16:
        return 'dog';
      case 17:
        return 'horse';
      case 18:
        return 'sheep';
      case 19:
        return 'cow';
      case 20:
        return 'elephant';
      case 21:
        return 'bear';
      case 22:
        return 'zebra';
      case 23:
        return 'giraffe';
      case 24:
        return 'backpack';
      case 25:
        return 'umbrella';
      case 26:
        return 'handbag';
      case 27:
        return 'tie';
      case 28:
        return 'suitcase';
      case 29:
        return 'frisbee';
      case 30:
        return 'skis';
      case 31:
        return 'snowboard';
      case 32:
        return 'sports ball';
      case 33:
        return 'kite';
      case 34:
        return 'baseball bat';
      case 35:
        return 'baseball glove';
      case 36:
        return 'skateboard';
      case 37:
        return 'surfboard';
      case 38:
        return 'tennis racket';
      case 39:
        return 'bottle';
      case 40:
        return 'wine glass';
      case 41:
        return 'cup';
      case 42:
        return 'fork';
      case 43:
        return 'knife';
      case 44:
        return 'spoon';
      case 45:
        return 'bowl';
      case 46:
        return 'banana';
      case 47:
        return 'apple';
      case 48:
        return 'sandwich';
      case 49:
        return 'orange';
      case 50:
        return 'broccoli';
      case 51:
        return 'carrot';
      case 52:
        return 'hot dog';
      case 53:
        return 'pizza';
      case 54:
        return 'donut';
      case 55:
        return 'cake';
      case 56:
        return 'chair';
      case 57:
        return 'couch';
      case 58:
        return 'potted plant';
      case 59:
        return 'bed';
      case 60:
        return 'dining table';
      case 61:
        return 'toilet';
      case 62:
        return 'TV';
      case 63:
        return 'laptop';
      case 64:
        return 'mouse';
      case 65:
        return 'remote';
      case 66:
        return 'keyboard';
      case 67:
        return 'cell phone';
      case 68:
        return 'microwave';
      case 69:
        return 'oven';
      case 70:
        return 'toaster';
      case 71:
        return 'sink';
      case 72:
        return 'refrigerator';
      case 73:
        return 'book';
      case 74:
        return 'clock';
      case 75:
        return 'vase';
      case 76:
        return 'scissors';
      case 77:
        return 'teddy bear';
      case 78:
        return 'hair drier';
      case 79:
        return 'toothbrush';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time YOLO Detection (Flutter)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _initializeControllerFuture == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller!);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _yoloResult,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: _initializeControllerFuture == null
                ? null
                : _captureAndSendFrame,
            child: const Text('Capture Frame and Send to YOLO'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: CameraYoloScreen()));
}
