import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final bool is_cat;
  const SecondPage({required this.is_cat}); // is_cat 값을 받기 위한 생성자

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('images/dogicon.png', width: 30, height: 30), // AppBar의 강아지 아이콘
        title: Text('Second Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 첫 번째 페이지로 돌아가고 is_cat을 true로 재설정
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushNamed(
              context,
              '/',
              arguments: true,
            );
          },
          child: Text('Back'), // 첫 번째 페이지로 돌아가는 버튼
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
            'images/dog.jpg',
            width: 300,
            height: 300,
          ), // 화면 하단에 표시되는 강아지 이미지
        ),
      ),
    );
  }
}
