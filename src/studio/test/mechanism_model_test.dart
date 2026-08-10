import 'package:flutter_test/flutter_test.dart';

import 'package:qtcloud_econ_studio/models/mechanism.dart';

void main() {
  group('Mechanism 模型', () {
    test('fromJson 解析完整机制', () {
      final json = {
        'id': 'test-game',
        'name': '测试机制',
        'description': '测试描述',
        'players': [
          {'id': 'p1', 'name': '参与方1', 'role': '博弈方'},
        ],
        'strategies': [
          {'id': 's1', 'player_id': 'p1', 'name': '策略A', 'description': '策略描述'},
        ],
        'rules': [
          {'id': 'r1', 'name': '规则A', 'description': '规则描述'},
        ],
        'objectives': [
          {'id': 'o1', 'name': '目标A', 'description': '目标描述'},
        ],
        'relations': [
          {
            'type': 'parent',
            'target_id': 'talent-development',
            'label': '人才培养机制（整合）',
          },
        ],
      };
      final m = Mechanism.fromJson(json);
      expect(m.id, 'test-game');
      expect(m.players.single.name, '参与方1');
      expect(m.strategies.single.playerId, 'p1');
      expect(m.rules.single.name, '规则A');
      expect(m.objectives.single.name, '目标A');
      expect(m.relations.single.type, 'parent');
      expect(m.relations.single.targetId, 'talent-development');
      expect(m.relations.single.label, '人才培养机制（整合）');
    });

    test('空列表容错', () {
      final m = Mechanism.fromJson({'id': 'x', 'name': 'X'});
      expect(m.players, isEmpty);
      expect(m.strategies, isEmpty);
      expect(m.relations, isEmpty);
    });

    test('relatedMechanism 按 id 查找关联机制', () {
      final a = Mechanism.fromJson({'id': 'a', 'name': 'A'});
      final b = Mechanism.fromJson({'id': 'b', 'name': 'B'});
      expect(a.relatedMechanism('b', [a, b])?.name, 'B');
      expect(a.relatedMechanism('not-exist', [a, b]), isNull);
    });
  });
}
