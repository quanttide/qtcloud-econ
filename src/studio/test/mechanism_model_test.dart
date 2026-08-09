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
      };
      final m = Mechanism.fromJson(json);
      expect(m.id, 'test-game');
      expect(m.players.single.name, '参与方1');
      expect(m.strategies.single.playerId, 'p1');
      expect(m.rules.single.name, '规则A');
      expect(m.objectives.single.name, '目标A');
    });

    test('空列表容错', () {
      final m = Mechanism.fromJson({'id': 'x', 'name': 'X'});
      expect(m.players, isEmpty);
      expect(m.strategies, isEmpty);
    });
  });
}
