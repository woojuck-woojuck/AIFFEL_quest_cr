import 'dart:convert'; // Base64 디코딩
import 'dart:typed_data'; // Uint8List 처리
import 'dart:html' as html; // FilePicker (Flutter Web 전용)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartoonify App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CartoonifyScreen(),
    );
  }
}

class CartoonifyScreen extends StatefulWidget {
  @override
  _CartoonifyScreenState createState() => _CartoonifyScreenState();
}

class _CartoonifyScreenState extends State<CartoonifyScreen> {
  Uint8List? _processedImage;

  Future<void> _uploadImage() async {
    // Flutter Web용 FilePicker
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(uploadInput.files!.first);
      reader.onLoadEnd.listen((e) async {
        // 업로드된 파일을 FastAPI로 전송
        final imageData = reader.result as Uint8List;
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://127.0.0.1:8000/upload_image/'),
        );
        request.files.add(http.MultipartFile.fromBytes('file', imageData, filename: 'upload.png'));

        final response = await request.send();
        if (response.statusCode == 200) {
          final res = await http.Response.fromStream(response);
          final Map<String, dynamic> json = jsonDecode(res.body);

          // Base64 디코딩하여 이미지 표시
          setState(() {
            _processedImage = Base64Decoder().convert(json['image']);
          });
        } else {
          print("Failed to upload image");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cartoonify App")),
      body: Center(
        child: _processedImage != null
            ? Image.memory(_processedImage!) // 처리된 이미지 표시
            : Text("Upload an image to process"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadImage,
        child: Icon(Icons.upload),
      ),
    );
  }
}
