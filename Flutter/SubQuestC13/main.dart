// iscat의 변수는 잘 들어갔는데 is_cat 변수로 했을 때 힘들었다. 


import 'package:flutter/material.dart';
import 'cat.dart';
import 'dog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal App',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // 화면 전환을 위한 라우트 정의
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => FirstPage());
        } else if (settings.name == '/second') {
          final bool is_cat = settings.arguments as bool;
          return MaterialPageRoute(builder: (context) => SecondPage(is_cat: is_cat));
        }
        return null;
      },
    );
  }
}