import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ─── StatusBadge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (textColor, bgColor) = switch (status.toLowerCase()) {
      'success' || 'completed' || 'done' => (AppColors.success, AppColors.success.withOpacity(0.1)),
      'warning' || 'in progress' || 'doing' => (AppColors.warning, AppColors.warning.withOpacity(0.1)),
      'danger' || 'todo' || 'blocked' => (AppColors.danger, AppColors.danger.withOpacity(0.1)),
      _ => (AppColors.muted, AppColors.muted.withOpacity(0.1)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ─── Avatar ──────────────────────────────────────────────────────────────────
class Avatar extends StatelessWidget {
  final String name;
  final double size;

  const Avatar({
    super.key,
    required this.name,
    this.size = 32,
  });

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  Color _colorFromName(String name) {
    final colors = [
      const Color(0xFF7C5CFF),
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      AppColors.primary,
      AppColors.primary,
      AppColors.success,
    ];
    int hash = 0;
    for (final c in name.codeUnits) {
      hash = (hash * 31 + c) & 0xFFFFFFFF;
    }
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bg = _colorFromName(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: GoogleFonts.inter(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── AvatarStack ─────────────────────────────────────────────────────────────
class AvatarStack extends StatelessWidget {
  final List<String> names;
  final double size;
  final int maxVisible;

  const AvatarStack({
    super.key,
    required this.names,
    this.size = 24,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return const SizedBox.shrink();

    final visibleNames = names.take(maxVisible).toList();
    final overflowCount = names.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size,
          width: visibleNames.length * (size - 8) + 8 + (overflowCount > 0 ? (size - 8) : 0),
          child: Stack(
            children: [
              for (int i = 0; i < visibleNames.length; i++)
                Positioned(
                  left: i * (size - 8),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 1.5),
                    ),
                    child: Avatar(name: visibleNames[i], size: size - 3),
                  ),
                ),
              if (overflowCount > 0)
                Positioned(
                  left: visibleNames.length * (size - 8),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '+$overflowCount',
                        style: GoogleFonts.inter(
                          fontSize: size * 0.35,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── TaskCard ────────────────────────────────────────────────────────────────
class TaskCard extends StatelessWidget {
  final String title;
  final String projectName;
  final bool isCompleted;
  final ValueChanged<bool?>? onCheckboxChanged;
  final String status;
  final List<String> assignees;
  final String? dueDate;

  const TaskCard({
    super.key,
    required this.title,
    required this.projectName,
    required this.isCompleted,
    this.onCheckboxChanged,
    required this.status,
    required this.assignees,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: isCompleted,
              onChanged: onCheckboxChanged,
              activeColor: AppColors.primary,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(color: AppColors.border, width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? AppColors.muted : AppColors.textPrimary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  projectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: status),
          const SizedBox(width: 8),
          AvatarStack(names: assignees, size: 24),
          if (dueDate != null) ...[
            const SizedBox(width: 8),
            Text(
              dueDate!,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── SectionHeader ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── SidebarItem ─────────────────────────────────────────────────────────────
class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 2),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SparklinePainter ────────────────────────────────────────────────────────
class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final widthStep = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * widthStep;
      final y = size.height - ((data[i] - minVal) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

// ─── StatCard ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final List<double> chartData;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (chartData.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 24,
              width: double.infinity,
              child: CustomPaint(
                painter: SparklinePainter(chartData, AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
