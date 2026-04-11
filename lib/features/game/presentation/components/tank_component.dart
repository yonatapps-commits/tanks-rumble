import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';

enum TankTeam { player, enemy }

class TankComponent extends PositionComponent with CollisionCallbacks {
  final TankTeam team;
  int hearts;
  double fuel;

  TankComponent({
    required this.team,
    required super.position,
    this.hearts = GameConstants.maxHearts,
    this.fuel = 0.0,
  }) : super(
          size: Vector2(GameConstants.tankWidth, GameConstants.tankHeight),
        );

  Color get color => team == TankTeam.player
      ? const Color(0xFF2196F3)
      : const Color(0xFFF44336);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    // Tank body
    final bodyPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.y * 0.3, size.x, size.y * 0.7),
        const Radius.circular(4),
      ),
      bodyPaint,
    );

    // Tank turret
    final turretPaint = Paint()..color = color.withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.25, 0, size.x * 0.5, size.y * 0.45),
        const Radius.circular(6),
      ),
      turretPaint,
    );

    // Tank barrel
    final barrelPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final barrelStart = Offset(size.x * 0.5, size.y * 0.2);
    final barrelEnd = team == TankTeam.player
        ? Offset(size.x * 0.9, size.y * 0.05)
        : Offset(size.x * 0.1, size.y * 0.05);
    canvas.drawLine(barrelStart, barrelEnd, barrelPaint);

    // Wheels/tracks
    final trackPaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, size.y * 0.75, size.x - 4, size.y * 0.25),
        const Radius.circular(4),
      ),
      trackPaint,
    );
  }
}
