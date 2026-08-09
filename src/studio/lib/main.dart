import 'package:flutter/material.dart';

import 'screens/mechanism_screen.dart';

void main() {
  runApp(const EconApp());
}

class EconApp extends StatelessWidget {
  const EconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '量潮经济云',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const Shell(),
    );
  }
}

/// 应用壳：品牌侧边栏 + 内容区
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 80,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    '量',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_tree_outlined,
                      size: 20,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Expanded(child: MechanismScreen()),
          ],
        ),
      ),
    );
  }
}
