import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';
import 'package:tanks_rumble/features/game/presentation/components/explosion_component.dart';
import 'package:tanks_rumble/features/game/presentation/components/tank_component.dart';
import 'package:tanks_rumble/features/game/presentation/components/terrain_collision.dart';

/// A projectile that follows a parabolic arc under gravity.
class ProjectileComponent extends CircleComponent with CollisionCallbacks {
  final Vector2 velocity;
  final TankTeam firedBy;
  final double gravityPixels;

  /// Trail points for smoke trail effect
  final List<Vector2> _trail = [];
  static const int _maxTrailLength = 20;

  bool _hasExploded = false;

  /// Called when projectile is removed (hit or out of bounds).
  VoidCallback? onRemoveCallback;

  ProjectileComponent({
    required super.position,
    required this.velocity,
    required this.firedBy,
    this.gravityPixels = GameConstants.gravity * GameConstants.gravityMultiplier,
  }) : super(
          radius: GameConstants.projectileRadius,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_hasExploded) return;

    // Store trail point
    _trail.add(position.clone());
    if (_trail.length > _maxTrailLength) {
      _trail.removeAt(0);
    }

    // Apply gravity to vertical velocity
    velocity.y += gravityPixels * dt;

    // Move projectile
    position += velocity * dt;

    // Remove if out of world bounds
    if (position.x < -50 ||
        position.x > GameConstants.worldWidth + 50 ||
        position.y > GameConstants.worldHeight + 50) {
      onRemoveCallback?.call();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw trail
    for (var i = 0; i < _trail.length; i++) {
      final alpha = (i / _trail.length * 150).toInt();
      final trailSize = (i / _trail.length) * radius;
      final trailPaint = Paint()
        ..color = Colors.orange.withAlpha(alpha);
      final offset = _trail[i] - position;
      canvas.drawCircle(
        Offset(offset.x, offset.y),
        trailSize,
        trailPaint,
      );
    }

    // Draw projectile body
    final paint = Paint()..color = const Color(0xFF212121);
    canvas.drawCircle(Offset.zero, radius, paint);

    // Inner glow
    final glowPaint = Paint()..color = const Color(0xFFFF6F00);
    canvas.drawCircle(Offset.zero, radius * 0.5, glowPaint);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (_hasExploded) return;

    // Hit terrain
    if (other is TerrainCollision) {
      _explode();
      return;
    }

    // Hit a tank (only damage the OTHER team)
    if (other is TankComponent && other.team != firedBy) {
      other.hearts -= 1;
      _explode();
      return;
    }
  }

  void _explode() {
    if (_hasExploded) return;
    _hasExploded = true;

    // Spawn explosion at current position
    parent?.add(ExplosionComponent(position: position.clone()));

    // Remove projectile
    onRemoveCallback?.call();
    removeFromParent();
  }
}
