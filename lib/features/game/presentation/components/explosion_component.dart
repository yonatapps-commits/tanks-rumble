import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Visual explosion effect that expands and fades out.
class ExplosionComponent extends PositionComponent {
  static const double _maxRadius = 30.0;
  static const double _duration = 0.4; // seconds

  double _elapsed = 0;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  ExplosionComponent({required super.position})
      : super(anchor: Anchor.center, priority: 20);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Generate random particles
    for (var i = 0; i < 12; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 50 + _random.nextDouble() * 150;
      _particles.add(_Particle(
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        color: _randomExplosionColor(),
        size: 2 + _random.nextDouble() * 4,
      ));
    }
  }

  Color _randomExplosionColor() {
    final colors = [
      const Color(0xFFFF6F00), // orange
      const Color(0xFFFFD600), // yellow
      const Color(0xFFFF3D00), // red-orange
      const Color(0xFFFFAB00), // amber
      Colors.white,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= _duration) {
      removeFromParent();
      return;
    }

    // Update particles
    for (final particle in _particles) {
      particle.position += particle.velocity * dt;
      particle.velocity *= 0.95; // friction
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / _duration).clamp(0.0, 1.0);

    // Main explosion circle (expanding + fading)
    final radius = _maxRadius * progress;
    final alpha = ((1.0 - progress) * 200).toInt().clamp(0, 255);

    // Outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFF6F00).withAlpha(alpha ~/ 2);
    canvas.drawCircle(Offset.zero, radius * 1.3, glowPaint);

    // Main circle
    final mainPaint = Paint()
      ..color = const Color(0xFFFFD600).withAlpha(alpha);
    canvas.drawCircle(Offset.zero, radius, mainPaint);

    // Inner bright core
    final corePaint = Paint()
      ..color = Colors.white.withAlpha(alpha);
    canvas.drawCircle(Offset.zero, radius * 0.3, corePaint);

    // Draw particles
    for (final particle in _particles) {
      final particleAlpha = ((1.0 - progress) * 255).toInt().clamp(0, 255);
      final paint = Paint()
        ..color = particle.color.withAlpha(particleAlpha);
      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particle.size * (1.0 - progress * 0.5),
        paint,
      );
    }
  }
}

class _Particle {
  Vector2 velocity;
  Vector2 position;
  final Color color;
  final double size;

  _Particle({
    required this.velocity,
    required this.color,
    required this.size,
  }) : position = Vector2.zero();
}
