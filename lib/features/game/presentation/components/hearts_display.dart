import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';
import 'package:tanks_rumble/features/game/presentation/components/tank_component.dart';

/// Displays hearts above a tank.
class HeartsDisplay extends PositionComponent {
  final TankComponent tank;

  static const double _heartSize = 16.0;
  static const double _heartSpacing = 4.0;
  static const double _offsetAboveTank = 12.0;

  HeartsDisplay({required this.tank}) : super(priority: 50);

  @override
  void render(Canvas canvas) {
    final totalWidth = GameConstants.maxHearts * (_heartSize + _heartSpacing) -
        _heartSpacing;
    final startX = tank.position.x + (tank.size.x - totalWidth) / 2;
    final y = tank.position.y - _offsetAboveTank - _heartSize;

    for (var i = 0; i < GameConstants.maxHearts; i++) {
      final x = startX + i * (_heartSize + _heartSpacing);
      final isFilled = i < tank.hearts;

      _drawHeart(canvas, x, y, _heartSize, isFilled);
    }
  }

  void _drawHeart(
      Canvas canvas, double x, double y, double size, bool filled) {
    final paint = Paint()
      ..color = filled ? const Color(0xFFE53935) : const Color(0x55E53935)
      ..style = PaintingStyle.fill;

    // Simple heart shape using two circles + triangle
    final halfSize = size / 2;
    final quarterSize = size / 4;

    // Left circle
    canvas.drawCircle(
      Offset(x + quarterSize, y + quarterSize),
      quarterSize,
      paint,
    );

    // Right circle
    canvas.drawCircle(
      Offset(x + halfSize + quarterSize, y + quarterSize),
      quarterSize,
      paint,
    );

    // Bottom triangle
    final path = Path();
    path.moveTo(x, y + quarterSize);
    path.lineTo(x + halfSize, y + size);
    path.lineTo(x + size, y + quarterSize);
    path.close();
    canvas.drawPath(path, paint);

    // Border
    if (filled) {
      final borderPaint = Paint()
        ..color = const Color(0xFFB71C1C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(
        Offset(x + quarterSize, y + quarterSize),
        quarterSize,
        borderPaint,
      );
      canvas.drawCircle(
        Offset(x + halfSize + quarterSize, y + quarterSize),
        quarterSize,
        borderPaint,
      );
    }
  }
}
