import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../food/domain/entities/food.dart';

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
    final colors = [Colors.green, Colors.blue, Colors.red];
    return LayoutBuilder(
      builder: (context, c) {
        final d = min(c.maxWidth, c.maxHeight * 0.65).clamp(220.0, 380.0);
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
                  colors: colors,
                  highlightIndex: _highlightIndex,
                  onSurface: scheme.onPrimaryContainer,
                ),
              ),
              Positioned(
                top: 4,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.items,
    required this.rotation,
    required this.colors,
    required this.onSurface,
    this.highlightIndex,
  });

  final List<Food> items;
  final double rotation;
  final List<Color> colors;
  final Color onSurface;
  final int? highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final n = items.length;
    if (n == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.9;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * pi / n;

    for (var i = 0; i < n; i++) {
      final isHi = highlightIndex == i;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: isHi ? 1.0 : 0.88)
        ..style = PaintingStyle.fill;
      final start = -pi / 2 + rotation + i * sweep;
      canvas.drawArc(rect, start, sweep, true, paint);

      if (isHi) {
        final border = Paint()
          ..color = Colors.white.withValues(alpha: 0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawArc(rect, start, sweep, true, border);
      }

      final mid = start + sweep / 2;
      final label = items[i].name.length > 18
          ? '${items[i].name.substring(0, 17)}…'
          : items[i].name;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.92),
            fontSize: n > 10 ? 9 : 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      );
      tp.layout(maxWidth: radius * 0.55);
      final tr = radius * 0.5;
      canvas.save();
      canvas.translate(center.dx + cos(mid) * tr, center.dy + sin(mid) * tr);
      canvas.rotate(mid + pi);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    final hub = Paint()..color = Colors.white.withValues(alpha: 0.96);
    canvas.drawCircle(center, radius * 0.12, hub);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.items != items ||
        oldDelegate.highlightIndex != highlightIndex;
  }
}
