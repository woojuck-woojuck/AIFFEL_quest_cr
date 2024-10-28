import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

void main() => runApp(JellyfishClassifierApp());

class JellyfishClassifierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 기본 앱 설정
    return MaterialApp(
      title: 'Jellyfish Classifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JellyfishClassifierPage(),
    );
  }
}

class JellyfishClassifierPage extends StatefulWidget {
  @override
  _JellyfishClassifierPageState createState() => _JellyfishClassifierPageState();
}

class _JellyfishClassifierPageState extends State<JellyfishClassifierPage> {
  Uint8List? _imageBytes; // 선택된 이미지의 바이트 데이터를 저장
  String _predictionResult = ""; // 예측 결과를 저장
  String _confidenceResult = ""; // 예측 확률을 저장

  // 이미지를 선택하는 함수
  Future<void> _pickImage() async {
    try {
      // 파일 선택기 사용하여 이미지 선택
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() {
          _imageBytes = result.files.single.bytes; // 선택된 이미지 바이트 데이터를 상태에 저장
        });
      } else {
        print('No image selected.'); // 이미지 선택이 취소된 경우
      }
    } catch (e) {
      print('Error picking image: $e'); // 이미지 선택 중 오류 발생 시 출력
    }
  }

  // 선택된 이미지로 예측을 수행하는 함수
  Future<void> _runInference() async {
    if (_imageBytes == null) return; // 이미지가 선택되지 않았으면 종료

    // FastAPI 서버에 예측 요청을 보냄
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://6e7b-182-229-245-237.ngrok-free.app/predict'), // Ngrok URL로 변경 필요
    );
    request.files.add(http.MultipartFile.fromBytes('file', _imageBytes!, filename: 'uploaded_image.jpg'));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final decodedData = json.decode(responseData.body);

        // 예측 결과와 신뢰도를 상태에 저장
        setState(() {
          _predictionResult = "Predicted Food: ${decodedData['predicted_food']}";
          _confidenceResult = "Confidence: ${(decodedData['confidence'] * 100).toStringAsFixed(2)}%";
        });
      } else {
        print('Failed to get prediction. Status code: ${response.statusCode}'); // 예측 실패 시 오류 출력
      }
    } catch (e) {
      print('Error occurred during inference: $e'); // 예측 중 오류 발생 시 출력
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jellyfish Classifier'), // 앱 제목
        leading: Image.asset('assets/jellyfish_icon.png'), // 좌측 상단 해파리 아이콘
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // 선택된 이미지가 있으면 표시, 없으면 안내 텍스트 표시
            _imageBytes == null
                ? Text('No image selected.')
                : Image.memory(
                    _imageBytes!,
                    width: 300,
                    height: 300,
                  ),
            SizedBox(height: 20),
            // 이미지 선택 및 예측 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _pickImage, // 이미지 선택 버튼
                  child: Text('Load Image'),
                ),
                ElevatedButton(
                  onPressed: _runInference, // 예측 실행 버튼
                  child: Text('Run Inference'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // 예측 결과 및 신뢰도 출력
            Text(_predictionResult),
            SizedBox(height: 10),
            Text(_confidenceResult),
          ],
        ),
      ),
    );
  }
}
