// 알림창이 뜨게 만드는게 생각보다 어려웠다. 오류가 많이 나서. GPT야 고맙다. 이걸로 공부해볼게.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

// MyApp 클래스: 애플리케이션의 진입점이며 MaterialApp 위제트를 생성
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // 지역화 설정을 위한 delegates
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 지원되는 로케일 목록
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      home: HomeScreen(), // 홈 화면으로 이동
    );
  }
}

// HomeScreen 클래스: 애플리케이션의 메인 화면을 구성
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // AppBar의 높이 설정
        child: AppBar(
          title: Row(
            children: [
              Expanded(
                flex: 2,
                child: Image.asset(
                  'images/flower_smile.png', // 로컬에 있는 이미지 파일 경로
                  height: 40.0,
                  width: 40.0,
                  fit: BoxFit.contain, // 이미지 크기 조정을 위해 BoxFit 사용
                ),
              ),
              const Expanded(
                flex: 8,
                child: Center(
                  child: Text(
                    '플러터 애플 만들기', // 앱바에 표시될 텍스트
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue, // AppBar의 배경색 설정
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
          children: [
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                print('버튼을 눌렀습니다'); // 디버그 콘솔에 메세지 출력
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('알림'), // 알림창 제목
                      content: const Text('버튼을 눌렀습니다'), // 알림창 내용
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 알림창 닫기
                          },
                          child: const Text('확인'),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0), // 버튼의 둥근 모서리 설정
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                child: Text('TEXT'), // 버튼에 표시될 텍스트
              ),
            ),
            const SizedBox(height: 20.0),
            Stack(
              alignment: Alignment.topLeft, // 모든 컨테이너의 왼쪽 상단 모서리 정렬
              children: [
                Container(
                  width: 300.0,
                  height: 300.0,
                  color: Colors.red, // 가장 큰 컨테이너 (빨간색)
                ),
                Container(
                  width: 240.0,
                  height: 240.0,
                  color: Colors.orange, // 두 번째로 큰 컨테이너 (주흑색)
                ),
                Container(
                  width: 180.0,
                  height: 180.0,
                  color: Colors.yellow, // 세 번째로 큰 컨테이너 (노란색)
                ),
                Container(
                  width: 120.0,
                  height: 120.0,
                  color: Colors.green, // 넷 번째로 큰 컨테이너 (초록색)
                ),
                Container(
                  width: 60.0,
                  height: 60.0,
                  color: Colors.blue, // 가장 작은 컨테이너 (파란색)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
