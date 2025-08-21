import 'package:basic_api/news/page/news_v1_page.dart';
import 'package:basic_api/news/page/news_v2_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NewsV1Page());
  }
}
