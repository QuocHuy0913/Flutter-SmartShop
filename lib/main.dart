import 'package:flutter/material.dart';
import 'package:flutter_application_smartshop/page/startwidget.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Startwidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}
