import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NewsSummaryApp(),
    );
  }
}

class NewsSummaryApp extends StatefulWidget {
  @override
  _NewsSummaryAppState createState() => _NewsSummaryAppState();
}

class _NewsSummaryAppState extends State<NewsSummaryApp> {
  TextEditingController _controller = TextEditingController();
  String _summary = "";
  
  Future<void> summarizeText() async {
    final String text = _controller.text;
    
    // 요청 본문을 JSON 형식으로 준비합니다.
    final Map<String, dynamic> requestBody = {"text": text};
    
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/summarize/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody), // JSON 형식으로 변환
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _summary = responseData['summary'];
      });
    } else {
      setState(() {
        _summary = "Error: Unable to summarize text. (${response.statusCode})";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Summary App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter news text",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: summarizeText,
              child: Text("Summarize"),
            ),
            SizedBox(height: 16),
            Text(
              "Summary:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_summary),
          ],
        ),
      ),
    );
  }
}
