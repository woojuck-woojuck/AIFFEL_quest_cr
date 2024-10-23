import 'package:flutter/material.dart';
import 'main.dart';
import 'page5.dart';

class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('싸움 뉴스'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Page5()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                // 검색 기능 추가 예정
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text('싸움 관련 뉴스 1'),
                ),
                ListTile(
                  title: Text('싸움 관련 뉴스 2'),
                ),
                ListTile(
                  title: Text('싸움 관련 뉴스 3'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}