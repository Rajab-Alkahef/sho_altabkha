import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../food/domain/entities/food.dart';

const List<Color> _kWheelPalette = [
  Color(0xFFEF6C6C), // coral
  Color(0xFFFFB74D), // amber
  Color(0xFFFFD54F), // mustard
  Color(0xFF81C784), // mint
  Color(0xFF4DB6AC), // teal
  Color(0xFF64B5F6), // sky
  Color(0xFF7986CB), // indigo
  Color(0xFFBA68C8), // orchid
];

class FortuneWheel extends StatefulWidget {
  const FortuneWheel({
    super.key,
    required this.items,
    required this.onSpinComplete,
    this.onSpinStatusChanged,
  });

  final List<Food> items;
  final ValueChanged<Food> onSpinComplete;
  final ValueChanged<bool>? onSpinStatusChanged;

  @override
  FortuneWheelState createState() => FortuneWheelState();
}

class FortuneWheelState extends State<FortuneWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  Animation<double>? _anim;
  double _rotation = 0;
  int? _highlightIndex;
  bool _spinning = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Animates so [winnerIndex] lands under the top pointer.
  void spinToWinner(int winnerIndex) {
    final n = widget.items.length;
    if (n == 0 || _spinning) return;
    if (winnerIndex < 0 || winnerIndex >= n) return;

    final sweep = 2 * pi / n;
    final thetaW = -pi / 2 + (winnerIndex + 0.5) * sweep;
    final base = -pi / 2 - thetaW;
    var target = base;
    const minSpins = 5;
    while (target < _rotation + minSpins * 2 * pi) {
      target += 2 * pi;
    }

    _spinning = true;
    widget.onSpinStatusChanged?.call(true);
    setState(() => _highlightIndex = null);

    _ctrl.reset();

    final tween = Tween<double>(begin: _rotation, end: target);
    _anim = tween.animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );

    void tick() {
      if (_anim != null) {
        setState(() => _rotation = _anim!.value);
      }
    }

    _anim!.addListener(tick);
    _ctrl.forward().then((_) {
      _anim?.removeListener(tick);
      setState(() {
        _rotation = target;
        _highlightIndex = winnerIndex;
        _spinning = false;
      });
      widget.onSpinStatusChanged?.call(false);
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
      widget.onSpinComplete(widget.items[winnerIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, c) {
        final d = min(c.maxWidth, c.maxHeight * 0.75).clamp(260.0, 460.0);
        return SizedBox(
          width: d,
          height: d,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(d, d),
                painter: _WheelPainter(
                  items: widget.items,
                  rotation: _rotation,
                  palette: _kWheelPalette,
                  highlightIndex: _highlightIndex,
                  ringColor: scheme.primary,
                  dividerColor: Colors.white.withValues(alpha: 0.85),
                  hubColor: scheme.surface,
                  hubBorder: scheme.primary,
                ),
              ),
              Positioned(top: -6, child: _Pointer(color: scheme.primary)),
              _Hub(
                size: d * 0.18,
                color: scheme.surface,
                border: scheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Pointer extends StatelessWidget {
  const _Pointer({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 44,
      child: CustomPaint(painter: _PointerPainter(color: color)),
    );
  }
}

class _PointerPainter extends CustomPainter {
  _PointerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..arcToPoint(
        Offset(size.width, 0),
        radius: Radius.circular(size.width / 2),
        clockwise: true,
      )
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.4), 4, false);
    final fill = Paint()..color = color;
    canvas.drawPath(path, fill);

    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final hl = Path()
      ..moveTo(size.width * 0.35, 2)
      ..lineTo(size.width * 0.5, size.height * 0.85)
      ..lineTo(size.width * 0.5, 2)
      ..close();
    canvas.drawPath(hl, highlight);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter old) => old.color != color;
}

class _Hub extends StatelessWidget {
  const _Hub({required this.size, required this.color, required this.border});

  final double size;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: border, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(Icons.restaurant_rounded, size: size * 0.55, color: border),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.items,
    required this.rotation,
    required this.palette,
    required this.ringColor,
    required this.dividerColor,
    required this.hubColor,
    required this.hubBorder,
    this.highlightIndex,
  });

  final List<Food> items;
  final double rotation;
  final List<Color> palette;
  final Color ringColor;
  final Color dividerColor;
  final Color hubColor;
  final Color hubBorder;
  final int? highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final n = items.length;
    if (n == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.92;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * pi / n;

    // Drop shadow under the wheel.
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius + 2));
    canvas.drawShadow(
      shadowPath,
      Colors.black.withValues(alpha: 0.45),
      14,
      false,
    );

    // Slices with radial gradient for depth.
    for (var i = 0; i < n; i++) {
      final isHi = highlightIndex == i;
      final base = palette[i % palette.length];
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          Color.lerp(base, Colors.white, 0.18)!,
          base,
          Color.lerp(base, Colors.black, 0.12)!,
        ],
        stops: const [0.0, 0.6, 1.0],
      );
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;
      final start = -pi / 2 + rotation + i * sweep;
      canvas.drawArc(rect, start, sweep, true, paint);

      if (isHi) {
        final highlight = Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill;
        canvas.drawArc(rect, start, sweep, true, highlight);
      }
    }

    // Slice dividers.
    final divider = Paint()
      ..color = dividerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < n; i++) {
      final a = -pi / 2 + rotation + i * sweep;
      canvas.drawLine(
        center,
        Offset(center.dx + cos(a) * radius, center.dy + sin(a) * radius),
        divider,
      );
    }

    // Labels.
    final labelFont = n <= 6
        ? 17.0
        : n <= 8
        ? 15.0
        : n <= 12
        ? 13.0
        : 11.5;
    for (var i = 0; i < n; i++) {
      final isHi = highlightIndex == i;
      final start = -pi / 2 + rotation + i * sweep;
      final mid = start + sweep / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: items[i].name,
          style: TextStyle(
            color: Colors.white,
            fontSize: labelFont,
            fontWeight: isHi ? FontWeight.w800 : FontWeight.w700,
            letterSpacing: 0.2,
            height: 1.05,
            shadows: const [
              Shadow(
                color: Color(0x66000000),
                // blurRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 2,
        ellipsis: '…',
      );
      tp.layout(maxWidth: radius * 0.62);
      final tr = radius * 0.58;
      canvas.save();
      canvas.translate(center.dx + cos(mid) * tr, center.dy + sin(mid) * tr);
      canvas.rotate(mid + pi);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Outer ring with subtle gradient.
    final ringRect = Rect.fromCircle(center: center, radius: radius + 6);
    final outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = SweepGradient(
        colors: [
          ringColor.withValues(alpha: 0.85),
          ringColor.withValues(alpha: 0.55),
          ringColor.withValues(alpha: 0.85),
        ],
        stops: const [0, 0.5, 1],
        transform: GradientRotation(rotation),
      ).createShader(ringRect);
    canvas.drawCircle(center, radius + 6, outerRing);

    // Thin inner ring at slice edge for crispness.
    final innerRing = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, innerRing);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.items != items ||
        oldDelegate.highlightIndex != highlightIndex;
  }
}
