import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Branded loading spinner: a rotating gradient arc around a gently pulsing
/// wallet mark. Used everywhere we wait on the network.
class BrandSpinner extends StatefulWidget {
  final double size;
  final String? label;
  const BrandSpinner({super.key, this.size = 56, this.label});

  @override
  State<BrandSpinner> createState() => _BrandSpinnerState();
}

class _BrandSpinnerState extends State<BrandSpinner>
    with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: s,
          width: s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _spin,
                child: CustomPaint(
                  size: Size(s, s),
                  painter: _ArcPainter(),
                ),
              ),
              ScaleTransition(
                scale: Tween(begin: 0.82, end: 1.0).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: Container(
                  height: s * 0.46,
                  width: s * 0.46,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded,
                      size: s * 0.28, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 12),
          Text(widget.label!, style: AppType.caption),
        ],
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.11;
    // Faint track.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.secondary;
    canvas.drawCircle(rect.center, (size.width - stroke) / 2, track);
    // Gradient sweep.
    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..shader = const SweepGradient(
        colors: [
          AppColors.aiAccent,
          AppColors.primary,
          AppColors.primaryDark,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawArc(
      Rect.fromCircle(
          center: rect.center, radius: (size.width - stroke) / 2),
      -math.pi / 2,
      math.pi * 1.4,
      false,
      sweep,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
