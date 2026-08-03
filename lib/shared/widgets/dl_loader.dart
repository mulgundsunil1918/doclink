import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The loading animations the doctor can pick between in Appearance settings.
enum DlLoaderStyle {
  /// An ECG trace that sweeps across the screen with a glowing head.
  heartbeat,

  /// Concentric rings breathing outward from a solid core.
  pulse,

  /// Three dots orbiting a shared centre.
  orbit;

  String get label => switch (this) {
        DlLoaderStyle.heartbeat => 'Heartbeat',
        DlLoaderStyle.pulse => 'Pulse',
        DlLoaderStyle.orbit => 'Orbit',
      };

  String get blurb => switch (this) {
        DlLoaderStyle.heartbeat => 'An ECG trace, drawn as it loads',
        DlLoaderStyle.pulse => 'Soft rings breathing outward',
        DlLoaderStyle.orbit => 'Three dots circling',
      };
}

/// Branded loading indicator used in place of [CircularProgressIndicator].
///
/// Colours default to the ambient theme so this stays correct when the doctor
/// re-brands the app, and [style] follows their Appearance preference unless a
/// caller pins one explicitly.
class DlLoader extends StatefulWidget {
  const DlLoader({
    super.key,
    this.style = DlLoaderStyle.heartbeat,
    this.size = 56,
    this.color,
    this.trackColor,
    this.label,
  });

  /// Fills the available space and centres itself — the drop-in replacement for
  /// `Center(child: CircularProgressIndicator())`.
  static Widget fullscreen({
    DlLoaderStyle style = DlLoaderStyle.heartbeat,
    String? label,
    double size = 64,
  }) =>
      Center(child: DlLoader(style: style, size: size, label: label));

  final DlLoaderStyle style;
  final double size;

  /// Defaults to the theme's primary colour.
  final Color? color;

  /// The faint "not yet drawn" colour. Defaults to a low-opacity [color].
  final Color? trackColor;

  /// Optional caption rendered under the animation.
  final String? label;

  @override
  State<DlLoader> createState() => _DlLoaderState();
}

class _DlLoaderState extends State<DlLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: switch (widget.style) {
      DlLoaderStyle.heartbeat => const Duration(milliseconds: 1800),
      DlLoaderStyle.pulse => const Duration(milliseconds: 1600),
      DlLoaderStyle.orbit => const Duration(milliseconds: 1200),
    },
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.color ?? scheme.primary;
    final track = widget.trackColor ?? color.withValues(alpha: 0.14);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt to whatever room the caller actually has. The same widget is
        // used full-screen and inside a 20x20 button slot, and the ECG needs
        // width to be legible — so shrink it, then fall back to a square style
        // once the trace would be too small to read as a heartbeat.
        var style = widget.style;
        var size = widget.size;

        if (constraints.maxHeight.isFinite) {
          size = math.min(size, constraints.maxHeight);
        }

        if (style == DlLoaderStyle.heartbeat && constraints.maxWidth.isFinite) {
          const aspect = 2.4;
          if (constraints.maxWidth < size * aspect) {
            final fitted = constraints.maxWidth / aspect;
            if (fitted >= 16) {
              size = fitted;
            } else {
              style = DlLoaderStyle.orbit;
              size = math.min(size, constraints.maxWidth);
            }
          }
        }

        // The ECG reads as a trace, so it wants width to run along; the radial
        // styles stay square.
        final box = switch (style) {
          DlLoaderStyle.heartbeat => Size(size * 2.4, size),
          _ => Size.square(size),
        };

        return _build(context, style, box, color, track);
      },
    );
  }

  Widget _build(
    BuildContext context,
    DlLoaderStyle style,
    Size box,
    Color color,
    Color track,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              size: box,
              painter: switch (style) {
                DlLoaderStyle.heartbeat =>
                  _HeartbeatPainter(_c.value, color, track),
                DlLoaderStyle.pulse => _PulsePainter(_c.value, color, track),
                DlLoaderStyle.orbit => _OrbitPainter(_c.value, color, track),
              },
            ),
          ),
        ),
        if (widget.label case final label?) ...[
          const SizedBox(height: 14),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );
  }
}

// ── Heartbeat ────────────────────────────────────────────────────────────────

/// Draws a faint ECG baseline with a bright, glowing segment travelling along it.
class _HeartbeatPainter extends CustomPainter {
  _HeartbeatPainter(this.t, this.color, this.track);

  final double t;
  final Color color;
  final Color track;

  /// Normalised ECG deflection at [x] (0..1). Hand-tuned to read as PQRST
  /// rather than as a generic zigzag.
  double _ecg(double x) {
    double y = 0;
    // P wave — a low, wide bump before the spike.
    y += 0.16 * _bump(x, centre: 0.22, width: 0.07);
    // QRS complex — the sharp trio that makes it legible as a heartbeat.
    y -= 0.20 * _bump(x, centre: 0.38, width: 0.022); // Q
    y += 1.00 * _bump(x, centre: 0.44, width: 0.020); // R
    y -= 0.42 * _bump(x, centre: 0.50, width: 0.026); // S
    // T wave — the broad recovery hump.
    y += 0.30 * _bump(x, centre: 0.70, width: 0.065);
    return y;
  }

  /// A smooth unit bump centred at [centre]; zero outside ~3 widths.
  double _bump(double x, {required double centre, required double width}) {
    final d = (x - centre) / width;
    if (d.abs() > 3) return 0;
    return math.exp(-d * d);
  }

  Path _buildPath(Size size) {
    final path = Path();
    final mid = size.height / 2;
    const steps = 220;
    for (var i = 0; i <= steps; i++) {
      final x = i / steps;
      final px = x * size.width;
      final py = mid - _ecg(x) * (size.height * 0.40);
      i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    // Baseline: the whole trace, faint.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = track,
    );

    // Bright travelling window, extracted from the same path so it sits exactly
    // on the baseline.
    final metric = path.computeMetrics().first;
    final len = metric.length;
    const tailFraction = 0.34;
    final head = t * (1 + tailFraction) * len;
    final start = math.max(0.0, head - tailFraction * len);
    final end = math.min(len, head);

    if (end > start) {
      final segment = metric.extractPath(start, end);
      final rect = Offset.zero & size;

      // Glow underlay — a blurred, wider pass reads as light coming off the line.
      canvas.drawPath(
        segment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color.withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // The trace itself, fading out toward the tail.
      canvas.drawPath(
        segment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = LinearGradient(
            colors: [color.withValues(alpha: 0), color],
            stops: const [0, 0.85],
          ).createShader(rect),
      );

      // Leading dot.
      final headPos = metric.getTangentForOffset(end)?.position;
      if (headPos != null) {
        canvas
          ..drawCircle(
            headPos,
            6,
            Paint()
              ..color = color.withValues(alpha: 0.35)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
          )
          ..drawCircle(headPos, 3, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(_HeartbeatPainter old) =>
      old.t != t || old.color != color || old.track != track;
}

// ── Pulse ────────────────────────────────────────────────────────────────────

class _PulsePainter extends CustomPainter {
  _PulsePainter(this.t, this.color, this.track);

  final double t;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;

    // Two rings, offset in phase, expanding and fading as they go.
    for (final phase in [0.0, 0.5]) {
      final p = (t + phase) % 1.0;
      final r = maxR * (0.32 + p * 0.68);
      final alpha = (1 - p).clamp(0.0, 1.0);
      canvas.drawCircle(
        centre,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = color.withValues(alpha: alpha * 0.55),
      );
    }

    // Core, breathing gently so the centre never looks static.
    final breathe = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
    canvas
      ..drawCircle(
        centre,
        maxR * 0.30,
        Paint()
          ..color = color.withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      )
      ..drawCircle(
        centre,
        maxR * (0.20 + breathe * 0.06),
        Paint()..color = color,
      );
  }

  @override
  bool shouldRepaint(_PulsePainter old) =>
      old.t != t || old.color != color || old.track != track;
}

// ── Orbit ────────────────────────────────────────────────────────────────────

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.t, this.color, this.track);

  final double t;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 5;

    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = track,
    );

    for (var i = 0; i < 3; i++) {
      final angle = (t + i / 3) * 2 * math.pi;
      final pos = centre + Offset(math.cos(angle) * r, math.sin(angle) * r);
      // Leading dot is brightest; the followers trail off.
      final alpha = 1.0 - i * 0.28;
      canvas.drawCircle(
        pos,
        5.0 - i * 0.8,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.t != t || old.color != color || old.track != track;
}
