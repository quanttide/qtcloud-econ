import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qtcloud_econ_studio/models/mechanism.dart';
import 'package:qtcloud_econ_studio/widgets/mechanism_card.dart';

Mechanism _buildMechanism() => const Mechanism(
      id: 'test-game',
      name: '测试机制',
      description: '测试描述文本',
      players: [
        Player(id: 'p1', name: '候选', role: '博弈方'),
        Player(id: 'p2', name: '量潮', role: '设计者'),
      ],
      strategies: [
        Strategy(id: 's1', playerId: 'p1', name: '策略A', description: '策略描述'),
      ],
      rules: [
        Rule(id: 'r1', name: '规则A', description: '规则描述'),
      ],
      objectives: [
        Objective(id: 'o1', name: '目标A', description: '目标描述'),
      ],
    );

void main() {
  group('MechanismCard 组件', () {
    testWidgets('渲染名称与描述', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MechanismCard(mechanism: _buildMechanism()))),
      );
      expect(find.text('测试机制'), findsOneWidget);
      expect(find.text('测试描述文本'), findsOneWidget);
    });

    testWidgets('渲染四要素统计', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MechanismCard(mechanism: _buildMechanism()))),
      );
      expect(find.text('参与者'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // players 数量（唯一）
      expect(find.text('策略'), findsOneWidget);
      expect(find.text('规则'), findsOneWidget);
      expect(find.text('目标'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(3)); // strategies/rules/objectives 各 1
    });

    testWidgets('点击触发 onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MechanismCard(mechanism: _buildMechanism(), onTap: () => tapped = true),
          ),
        ),
      );
      await tester.tap(find.text('测试机制'));
      expect(tapped, isTrue);
    });
  });
}
