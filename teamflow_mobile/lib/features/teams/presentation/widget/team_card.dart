import 'package:flutter/material.dart';
import 'package:teamflow_mobile/features/teams/domain/entities/team_entity.dart';

class TeamCard extends StatelessWidget {
  final TeamEntity team;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TeamCard({
    super.key,
    required this.team,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Name + action buttons ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (team.description != null &&
                          team.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          team.description!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                  tooltip: 'Edit',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  tooltip: 'Delete',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 20),

            // ── Members + Projects chips ─────────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...team.members.map(
                  (m) => _Chip(
                    label: m.user?.name ?? '',
                    color: const Color(0xFFE0E7FF),
                  ),
                ),
                ...team.projects.map(
                  (p) => _Chip(label: p.name, color: const Color(0xFFDBEAFE)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
