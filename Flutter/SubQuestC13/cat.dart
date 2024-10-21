import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool is_cat = true; // 현재 동물이 고양이인지 여부를 추적하는 Boolean 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('images/caticon.png', width: 30, height: 30), // AppBar의 고양이 아이콘
        title: Text('First Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // is_cat 변수를 false로 설정하고 두 번째 페이지로 이동
            setState(() {
              is_cat = false;
            });
            Navigator.pushNamed(
              context,
              '/second',
              arguments: is_cat,
            );
          },
          child: Text('Next'), // 다음 페이지로 이동하는 버튼
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            // 현재 is_cat 상태를 디버그 콘솔에 출력
            debugPrint('is_cat: $is_cat');
          },
          child: Image.asset(
            'images/cat1.jpg',
            width: 300,
            height: 300,
          ), // 화면 하단에 표시되는 고양이 이미지
        ),
      ),
    );
  }
}