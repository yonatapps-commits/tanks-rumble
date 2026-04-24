import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';
import 'package:tanks_rumble/core/utils/math_utils.dart';
import 'package:tanks_rumble/features/game/presentation/components/projectile_component.dart';
import 'package:tanks_rumble/features/game/presentation/components/trajectory_line.dart';
import 'package:tanks_rumble/features/game/presentation/game/tank_game.dart';

enum TankTeam { player, enemy }

class TankComponent extends PositionComponent with CollisionCallbacks {
  final TankTeam team;
  int hearts;
  double fuel;

  /// Barrel angle in radians. 0 = right, negative = up.
  double barrelAngle;

  /// Whether this tank can currently shoot (controlled by turn system later).
  bool canShoot = true;

  /// Drag state for slingshot aiming.
  bool _isDragging = false;
  Vector2 _dragStart = Vector2.zero();
  Vector2 _dragCurrent = Vector2.zero();
  Vector2 _currentVelocity = Vector2.zero();

  bool get isDragging => _isDragging;

  /// Reference to trajectory line (set by TankGame).
  TrajectoryLine? trajectoryLine;

  /// Callback when projectile is fired (used by TankGame to add it to world).
  void Function(ProjectileComponent projectile)? onFire;

  /// Check if input is blocked (e.g. during overview mode).
  bool get _isInputBlocked {
    final game = findParent<TankGame>();
    return game?.inputBlocked ?? false;
  }

  TankComponent({
    required this.team,
    required super.position,
    this.hearts = GameConstants.maxHearts,
    this.fuel = 0.0,
  })  : barrelAngle = team == TankTeam.player ? -pi / 6 : pi + pi / 6,
        super(
          size: Vector2(GameConstants.tankWidth, GameConstants.tankHeight),
        );

  Color get color => team == TankTeam.player
      ? const Color(0xFF2196F3)
      : const Color(0xFFF44336);

  /// The world position where the barrel tip is (projectile spawn point).
  Vector2 get barrelTip {
    const barrelLength = 28.0;
    final turretCenter = position + Vector2(size.x * 0.5, size.y * 0.2);
    return turretCenter +
        Vector2(cos(barrelAngle) * barrelLength,
            sin(barrelAngle) * barrelLength);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  // --- Slingshot (driven by TankGame drag events) ---

  void beginAim(Vector2 startPos) {
    if (!canShoot || team != TankTeam.player || _isInputBlocked) return;
    _isDragging = true;
    _dragStart = startPos;
    _dragCurrent = startPos;
  }

  void updateAim(Vector2 delta) {
    if (!_isDragging) return;

    _dragCurrent += delta;
    final dragDelta = _dragCurrent - _dragStart;

    _currentVelocity = MathUtils.dragToVelocity(
      dragDelta: dragDelta,
      minPower: GameConstants.minPower,
      maxPower: GameConstants.maxPower,
      sensitivity: GameConstants.dragSensitivity,
    );

    if (_currentVelocity.length > 1) {
      barrelAngle = MathUtils.vectorToAngle(_currentVelocity);
    }

    trajectoryLine?.updateTrajectory(
      origin: barrelTip,
      velocity: _currentVelocity,
    );
  }

  void endAim() {
    if (!_isDragging) return;
    _isDragging = false;

    if (_currentVelocity.length > GameConstants.minPower) {
      _fire();
    }

    trajectoryLine?.clear();
    _currentVelocity = Vector2.zero();
  }

  void cancelAim() {
    _isDragging = false;
    trajectoryLine?.clear();
    _currentVelocity = Vector2.zero();
  }

  void _fire() {
    final projectile = ProjectileComponent(
      position: barrelTip,
      velocity: _currentVelocity.clone(),
      firedBy: team,
    );

    onFire?.call(projectile);
  }

  // --- Rendering ---

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

    // Tank barrel (rotates based on barrelAngle)
    final barrelPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    const barrelLength = 28.0;
    final barrelStart = Offset(size.x * 0.5, size.y * 0.2);
    final barrelEnd = Offset(
      size.x * 0.5 + cos(barrelAngle) * barrelLength,
      size.y * 0.2 + sin(barrelAngle) * barrelLength,
    );
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

    // Draw power indicator during drag
    if (_isDragging && _currentVelocity.length > 1) {
      _renderPowerIndicator(canvas);
    }
  }

  void _renderPowerIndicator(Canvas canvas) {
    final powerPercent = MathUtils.dragToPowerPercent(
      dragDistance: (_dragCurrent - _dragStart).length,
      minPower: GameConstants.minPower,
      maxPower: GameConstants.maxPower,
    );

    // Power bar background
    const barWidth = 50.0;
    const barHeight = 6.0;
    final barX = (size.x - barWidth) / 2;
    const barY = -14.0;

    final bgPaint = Paint()..color = Colors.black54;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barWidth, barHeight),
        const Radius.circular(3),
      ),
      bgPaint,
    );

    // Power bar fill (green → yellow → red)
    final fillColor = Color.lerp(
      Colors.green,
      Colors.red,
      powerPercent,
    )!;
    final fillPaint = Paint()..color = fillColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barWidth * powerPercent, barHeight),
        const Radius.circular(3),
      ),
      fillPaint,
    );
  }
}
