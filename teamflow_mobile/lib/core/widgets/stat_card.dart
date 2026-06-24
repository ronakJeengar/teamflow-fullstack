import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teamflow_mobile/core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final String? trendText;
  final bool trendIsPositive;
  final List<double>? sparklineData;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
    this.trendText,
    this.trendIsPositive = true,
    this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    // Generate some default dummy sparkline data if none is provided
    final sparkData = sparklineData ?? [1.0, 1.5, 1.2, 2.0, 1.8, 2.5, 2.2, 3.0];

    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Sparkline
          SizedBox(
            height: 32,
            width: double.infinity,
            child: CustomPaint(
              painter: SparklinePainter(sparkData, color),
            ),
          ),
          if (trendText != null) ...[
            const SizedBox(height: 8),
            // Trend text
            Text(
              trendText!,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: trendIsPositive ? AppColors.success : AppColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / (data.length - 1);
    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      // Normalize Y mapping to fit within the drawing height
      final double y = size.height - ((data[i] - minVal) / range * (size.height - 4) + 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}

class StatBlockRow extends StatelessWidget {
  final List<StatCard> cards;

  const StatBlockRow({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: c,
        ))).toList(),
      );
    }

    // Mobile/Tablet snap scroll list
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: cards[index],
          );
        },
      ),
    );
  }
}
