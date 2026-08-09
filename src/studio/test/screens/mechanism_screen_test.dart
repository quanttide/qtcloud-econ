import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qtcloud_econ_studio/models/mechanism.dart';
import 'package:qtcloud_econ_studio/screens/mechanism_screen.dart';

Mechanism _buildMechanism() => const Mechanism(
  id: 'recruitment-game',
  name: '招聘博弈机制',
  description: '与招聘者的动态博弈描述',
  players: [
    Player(id: 'candidate', name: '候选人', role: '博弈方'),
    Player(id: 'company', name: '量潮', role: '机制设计者'),
  ],
  strategies: [
    Strategy(
      id: 's1',
      playerId: 'candidate',
      name: '提供增量',
      description: '在系统内找到目标',
    ),
  ],
  rules: [Rule(id: 'r1', name: '市场化微型创业', description: '拉进池子自己找题')],
  objectives: [Objective(id: 'o1', name: '招到留得住的人', description: '宁缺毋滥')],
);

void main() {
  group('MechanismScreen 列表页', () {
    testWidgets('从种子数据加载并显示机制卡片', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MechanismScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('机制设计'), findsOneWidget);
      expect(find.text('基于贡献证明的内部货币化信号甄别与转化平台'), findsOneWidget);
    });
  });

  group('MechanismDetailScreen 详情页', () {
    testWidgets('渲染四要素区块', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: MechanismDetailScreen(mechanism: _buildMechanism())),
      );

      expect(find.text('参与者'), findsOneWidget);
      expect(find.text('策略空间'), findsOneWidget);
      expect(find.text('规则（结果函数）'), findsOneWidget);
      expect(find.text('设计目标'), findsOneWidget);

      // 区块内容
      expect(find.textContaining('候选人 · 博弈方'), findsOneWidget);
      expect(find.textContaining('提供增量'), findsOneWidget);
      expect(find.textContaining('市场化微型创业'), findsOneWidget);
      expect(find.textContaining('招到留得住的人'), findsOneWidget);
    });
  });
}
