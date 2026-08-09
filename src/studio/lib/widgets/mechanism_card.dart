import 'package:flutter/material.dart';

import '../models/mechanism.dart';

/// 机制卡片——机制结构总览
class MechanismCard extends StatelessWidget {
  final Mechanism mechanism;
  final VoidCallback? onTap;

  const MechanismCard({super.key, required this.mechanism, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_tree_outlined,
                      size: 18, color: Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mechanism.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mechanism.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _stat('参与者', '${mechanism.players.length}'),
                const SizedBox(width: 16),
                _stat('策略', '${mechanism.strategies.length}'),
                const SizedBox(width: 16),
                _stat('规则', '${mechanism.rules.length}'),
                const SizedBox(width: 16),
                _stat('目标', '${mechanism.objectives.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4F46E5),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}
