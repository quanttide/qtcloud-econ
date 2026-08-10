import 'dart:convert';

import 'package:flutter/material.dart';

import '../widgets/mechanism_card.dart';
import '../models/mechanism.dart';

/// 机制设计模块——机制列表页
class MechanismScreen extends StatefulWidget {
  const MechanismScreen({super.key});

  @override
  State<MechanismScreen> createState() => _MechanismScreenState();
}

class _MechanismScreenState extends State<MechanismScreen> {
  List<Mechanism> _mechanisms = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/data/mechanisms.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final list = (json['mechanisms'] as List? ?? [])
          .map((e) => Mechanism.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _mechanisms = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '机制数据加载失败：$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Color(0xFFEF4444))),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '机制设计',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '通过设计博弈规则，让参与者的自利行为导向期望结果',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _mechanisms.isEmpty
                ? const Center(
                    child: Text(
                      '暂无机制',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.separated(
                    itemCount: _mechanisms.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final m = _mechanisms[index];
                      return MechanismCard(
                        mechanism: m,
                        onTap: () => _openDetail(m),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openDetail(Mechanism m) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MechanismDetailScreen(mechanism: m, allMechanisms: _mechanisms),
      ),
    );
  }
}

/// 机制详情页——结构总览（参与者/策略/规则/目标）
class MechanismDetailScreen extends StatelessWidget {
  final Mechanism mechanism;

  /// 全部机制列表（用于解析关联跳转目标）
  final List<Mechanism> allMechanisms;

  const MechanismDetailScreen({
    super.key,
    required this.mechanism,
    this.allMechanisms = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(mechanism.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            mechanism.description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          if (mechanism.relations.isNotEmpty) ...[
            ..._relationSection(context),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 20),
          _section(
            '参与者',
            Icons.groups_outlined,
            mechanism.players.map((p) => ('${p.name} · ${p.role}')).toList(),
          ),
          const SizedBox(height: 16),
          _section(
            '策略空间',
            Icons.alt_route,
            mechanism.strategies
                .map((s) => ('${s.name}：${s.description}'))
                .toList(),
          ),
          const SizedBox(height: 16),
          _section(
            '规则（结果函数）',
            Icons.rule,
            mechanism.rules.map((r) => ('${r.name}：${r.description}')).toList(),
          ),
          const SizedBox(height: 16),
          _section(
            '设计目标',
            Icons.track_changes_outlined,
            mechanism.objectives
                .map((o) => ('${o.name}：${o.description}'))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// 关联机制区块——父/子机制列表，点击跳转对应机制详情
  List<Widget> _relationSection(BuildContext context) {
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  size: 16,
                  color: Color(0xFF4F46E5),
                ),
                SizedBox(width: 6),
                Text(
                  '关联机制',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...mechanism.relations.map((r) {
              final target = _findTarget(r.targetId);
              final isParent = r.type == 'parent';
              return InkWell(
                onTap: target == null
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MechanismDetailScreen(
                            mechanism: target,
                            allMechanisms: allMechanisms,
                          ),
                        ),
                      ),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        isParent
                            ? Icons.call_merge_outlined
                            : Icons.call_split_outlined,
                        size: 14,
                        color: const Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${isParent ? '父机制' : '子机制'} · ${r.label}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      if (target != null)
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ];
  }

  Mechanism? _findTarget(String id) {
    for (final m in allMechanisms) {
      if (m.id == id) return m;
    }
    return null;
  }

  Widget _section(String title, IconData icon, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('· ', style: TextStyle(color: Color(0xFF4F46E5))),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
