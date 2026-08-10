/// Mechanism 领域模型——机制设计核心要素
///
/// 机制设计（Mechanism Design）：通过设计博弈规则，
/// 让参与者的自利行为导向期望结果。
library;

/// 机制：完整博弈结构
class Mechanism {
  final String id;
  final String name;
  final String description;
  final List<Player> players;
  final List<Strategy> strategies;
  final List<Rule> rules;
  final List<Objective> objectives;
  final List<MechanismRelation> relations;

  const Mechanism({
    required this.id,
    required this.name,
    required this.description,
    required this.players,
    required this.strategies,
    required this.rules,
    required this.objectives,
    this.relations = const [],
  });

  factory Mechanism.fromJson(Map<String, dynamic> json) => Mechanism(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    players: (json['players'] as List? ?? [])
        .map((e) => Player.fromJson(e as Map<String, dynamic>))
        .toList(),
    strategies: (json['strategies'] as List? ?? [])
        .map((e) => Strategy.fromJson(e as Map<String, dynamic>))
        .toList(),
    rules: (json['rules'] as List? ?? [])
        .map((e) => Rule.fromJson(e as Map<String, dynamic>))
        .toList(),
    objectives: (json['objectives'] as List? ?? [])
        .map((e) => Objective.fromJson(e as Map<String, dynamic>))
        .toList(),
    relations: (json['relations'] as List? ?? [])
        .map((e) => MechanismRelation.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// 关联机制（按 targetId 查找，未找到返回 null）
  Mechanism? relatedMechanism(String targetId, List<Mechanism> all) {
    for (final m in all) {
      if (m.id == targetId) return m;
    }
    return null;
  }
}

/// 机制关联关系（如 整合/子阶段 等）
class MechanismRelation {
  final String type;
  final String targetId;
  final String label;

  const MechanismRelation({
    required this.type,
    required this.targetId,
    required this.label,
  });

  factory MechanismRelation.fromJson(Map<String, dynamic> json) =>
      MechanismRelation(
        type: json['type'] as String? ?? '',
        targetId: json['target_id'] as String? ?? '',
        label: json['label'] as String? ?? '',
      );
}

/// 参与者：谁在博弈
class Player {
  final String id;
  final String name;
  final String role;

  const Player({required this.id, required this.name, required this.role});

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    role: json['role'] as String? ?? '',
  );
}

/// 策略：参与者的可选行动
class Strategy {
  final String id;
  final String playerId;
  final String name;
  final String description;

  const Strategy({
    required this.id,
    required this.playerId,
    required this.name,
    required this.description,
  });

  factory Strategy.fromJson(Map<String, dynamic> json) => Strategy(
    id: json['id'] as String? ?? '',
    playerId: json['player_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}

/// 规则：策略组合 → 结果（结果函数）
class Rule {
  final String id;
  final String name;
  final String description;

  const Rule({required this.id, required this.name, required this.description});

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}

/// 目标：机制设计者期望达成的结果
class Objective {
  final String id;
  final String name;
  final String description;

  const Objective({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Objective.fromJson(Map<String, dynamic> json) => Objective(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}
