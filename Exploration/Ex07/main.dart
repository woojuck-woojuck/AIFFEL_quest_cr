import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PromptInputPage(),
    );
  }
}

class PromptInputPage extends StatefulWidget {
  @override
  _PromptInputPageState createState() => _PromptInputPageState();
}

class _PromptInputPageState extends State<PromptInputPage> {
  final TextEditingController _controller = TextEditingController();
  String? _imagePath; // 생성된 이미지 URL 저장
  String? _error; // 에러 메시지 저장
  bool _isLoading = false; // 로딩 상태

  final String apiUrl = 'http://192.168.0.100:8000/generate/'; // API URL

  Future<void> generateImage(String prompt) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _imagePath = null;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl), // API URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': prompt}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _imagePath = data['image_url']; // FastAPI에서 반환된 image_url 사용
        });
      } else {
        setState(() {
          _error = 'Error: Failed to generate image. Status Code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: Unable to connect to server. $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Generator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 프롬프트 입력 필드
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter your prompt',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // 이미지 생성 버튼
            ElevatedButton(
              onPressed: _isLoading
                  ? null // 로딩 중이면 버튼 비활성화
                  : () {
                      final prompt = _controller.text.trim();
                      if (prompt.isNotEmpty) {
                        generateImage(prompt);
                      } else {
                        setState(() {
                          _error = 'Error: Prompt cannot be empty.';
                        });
                      }
                    },
              child: Text(_isLoading ? 'Generating...' : 'Generate Image'),
            ),
            SizedBox(height: 16),
            // 로딩 스피너
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            // 에러 메시지 표시
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            // 생성된 이미지 표시
            if (_imagePath != null)
              Expanded(
                child: Image.network(
                  _imagePath!,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Text(
                      'Failed to load image.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(ImageGeneratorApp());
