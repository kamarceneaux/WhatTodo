import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/utils/forest_theme.dart';

/// A painted forest that grows one tree for every completed task.
class ForestHeader extends StatelessWidget {
  final Stream<ForestProgress> progress;

  const ForestHeader({Key? key, required this.progress}) : super(key: key);

  static const double height = 168;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ForestProgress>(
      stream: progress,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final grown = data?.grown ?? 0;
        return SizedBox(
          height: height,
          width: double.infinity,
          // Re-keyed on the tree count, so the newest tree grows in each time
          // a task is completed.
          child: TweenAnimationBuilder<double>(
            key: ValueKey(grown),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (context, growth, child) => CustomPaint(
              painter: ForestPainter(trees: grown, newestGrowth: growth),
              child: child,
            ),
            child: _ForestStats(progress: data),
          ),
        );
      },
    );
  }
}

class _ForestStats extends StatelessWidget {
  final ForestProgress? progress;

  const _ForestStats({required this.progress});

  @override
  Widget build(BuildContext context) {
    final p = progress;
    if (p == null) return const SizedBox.expand();
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _StatChip(
              icon: Icons.park,
              label: p.grown == 1 ? "1 tree grown" : "${p.grown} trees grown",
            ),
            _StatChip(
              icon: Icons.spa_outlined,
              label: p.toPlant == 0 ? "All planted" : "${p.toPlant} to plant",
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Forest.parchment.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Forest.fern),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Forest.pine,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ForestPainter extends CustomPainter {
  /// Number of trees to draw (one per completed task).
  final int trees;

  /// 0..1 growth of the most recently planted tree.
  final double newestGrowth;

  static const int maxTrees = 60;

  ForestPainter({required this.trees, required this.newestGrowth});

  // Back hill the far row of trees stands on.
  static const _backBase = 0.76;
  static const _backAmp = 9.0;
  static const _backWaves = 2.1;
  static const _backPhase = 1.7;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Forest.mist, Color(0xFFEFF2E2)],
        ).createShader(Offset.zero & size),
    );

    // Sun with a soft glow.
    final sun = Offset(w * 0.84, h * 0.30);
    canvas.drawCircle(
        sun, 34, Paint()..color = Forest.sun.withValues(alpha: 0.16));
    canvas.drawCircle(
        sun, 23, Paint()..color = Forest.sun.withValues(alpha: 0.32));
    canvas.drawCircle(sun, 15, Paint()..color = Forest.sun);

    // Hills.
    _hill(canvas, size,
        base: 0.62,
        amp: 13,
        waves: 1.3,
        phase: 0.4,
        color: Forest.sage.withValues(alpha: 0.5));
    _hill(canvas, size,
        base: _backBase,
        amp: _backAmp,
        waves: _backWaves,
        phase: _backPhase,
        color: Forest.sage.withValues(alpha: 0.85));

    final count = math.min(trees, maxTrees);
    final spots = List.generate(count, (i) => _TreeSpot.forIndex(i, w, h));

    // Far row.
    for (final spot in spots.where((s) => !s.front)) {
      final baseY = _hillY(spot.x, w, h,
              base: _backBase,
              amp: _backAmp,
              waves: _backWaves,
              phase: _backPhase) +
          3;
      _drawTree(canvas, spot, baseY, _growthFor(spot, count));
    }

    // Morning mist between the rows.
    final mistRect = Rect.fromLTWH(0, h * 0.66, w, h * 0.24);
    canvas.drawRect(
      mistRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Forest.parchment.withValues(alpha: 0),
            Forest.parchment.withValues(alpha: 0.45),
          ],
        ).createShader(mistRect),
    );

    // Ground.
    final ground = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.9)
      ..quadraticBezierTo(w * 0.5, h * 0.84, w, h * 0.9)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(ground, Paint()..color = Forest.moss);

    // Near row.
    for (final spot in spots.where((s) => s.front)) {
      _drawTree(canvas, spot, h - 3, _growthFor(spot, count));
    }

    if (count == 0) {
      _sprout(canvas, Offset(w * 0.5, h * 0.9), newestGrowth);
    }
  }

  double _growthFor(_TreeSpot spot, int count) =>
      spot.index == count - 1 ? newestGrowth : 1.0;

  static double _hillY(double x, double w, double h,
      {required double base,
      required double amp,
      required double waves,
      required double phase}) {
    return h * base - amp * math.sin(phase + x / w * waves * 2 * math.pi);
  }

  void _hill(Canvas canvas, Size size,
      {required double base,
      required double amp,
      required double waves,
      required double phase,
      required Color color}) {
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width + 4; x += 4) {
      path.lineTo(
          x,
          _hillY(x, size.width, size.height,
              base: base, amp: amp, waves: waves, phase: phase));
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawTree(Canvas canvas, _TreeSpot spot, double baseY, double growth) {
    final height = spot.height * growth;
    if (height <= 0.5) return;
    if (spot.round) {
      _roundTree(canvas, spot.x, baseY, height, spot.color);
    } else {
      _pine(canvas, spot.x, baseY, height, spot.color);
    }
  }

  void _pine(
      Canvas canvas, double x, double baseY, double height, Color color) {
    final trunkH = height * 0.16;
    final trunkW = math.max(2.0, height * 0.07);
    canvas.drawRect(
      Rect.fromLTWH(x - trunkW / 2, baseY - trunkH, trunkW, trunkH),
      Paint()..color = Forest.bark,
    );

    final paint = Paint()..color = color;
    final crownBottom = baseY - trunkH * 0.6;
    final crownH = height - trunkH * 0.6;
    final width = height * 0.44;
    for (var tier = 0; tier < 3; tier++) {
      final bottom = crownBottom - crownH * 0.28 * tier;
      final top = bottom - crownH * 0.44;
      final tierW = width * (1 - tier * 0.24);
      canvas.drawPath(
        Path()
          ..moveTo(x - tierW / 2, bottom)
          ..lineTo(x + tierW / 2, bottom)
          ..lineTo(x, top)
          ..close(),
        paint,
      );
    }
  }

  void _roundTree(
      Canvas canvas, double x, double baseY, double height, Color color) {
    final trunkW = math.max(2.0, height * 0.08);
    canvas.drawRect(
      Rect.fromLTWH(
          x - trunkW / 2, baseY - height * 0.42, trunkW, height * 0.42),
      Paint()..color = Forest.bark,
    );
    final paint = Paint()..color = color;
    final r = height * 0.26;
    final cy = baseY - height * 0.66;
    canvas.drawCircle(Offset(x, cy), r, paint);
    canvas.drawCircle(Offset(x - r * 0.7, cy + r * 0.35), r * 0.72, paint);
    canvas.drawCircle(Offset(x + r * 0.7, cy + r * 0.3), r * 0.75, paint);
  }

  void _sprout(Canvas canvas, Offset base, double growth) {
    final s = growth;
    if (s <= 0) return;
    canvas.drawLine(
      base,
      base.translate(0, -22 * s),
      Paint()
        ..color = Forest.fern
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    final leaf = Paint()..color = Forest.fern;
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(base.dx, base.dy - 20 * s);
      canvas.rotate(0.6 * side);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(9 * s * side, 0), width: 18 * s, height: 9 * s),
        leaf,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ForestPainter old) =>
      old.trees != trees || old.newestGrowth != newestGrowth;
}

/// Deterministic placement for the i-th tree, so the forest looks the same
/// every time and each new tree fills a gap rather than stacking up.
class _TreeSpot {
  final int index;
  final double x;
  final double height;
  final bool front;
  final bool round;
  final Color color;

  _TreeSpot(
      this.index, this.x, this.height, this.front, this.round, this.color);

  static const _goldenRatio = 0.61803398875;

  factory _TreeSpot.forIndex(int i, double w, double h) {
    final rnd = math.Random(i * 7919 + 13);
    final front = i % 2 == 1;
    final x = ((0.5 + i * _goldenRatio) % 1.0) * (w - 28) + 14;
    final baseHeight = front ? h * 0.42 : h * 0.27;
    final height = baseHeight * (0.75 + rnd.nextDouble() * 0.45);
    final round = rnd.nextDouble() < 0.28;
    final color = front
        ? (rnd.nextBool() ? Forest.fern : Forest.pine)
        : (rnd.nextBool() ? Forest.moss : const Color(0xFF7FA07A));
    return _TreeSpot(i, x, height, front, round, color);
  }
}
