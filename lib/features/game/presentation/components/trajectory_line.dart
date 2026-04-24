import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';
import 'package:tanks_rumble/core/utils/math_utils.dart';

/// Renders a dotted trajectory line during slingshot aiming.
class TrajectoryLine extends PositionComponent {
  List<Vector2> _points = [];
  bool visible = false;

  TrajectoryLine() : super(priority: 10);

  /// Updates the trajectory preview based on shooting parameters.
  void updateTrajectory({
    required Vector2 origin,
    required Vector2 velocity,
  }) {
    if (velocity.length < 1) {
      _points = [];
      visible = false;
      return;
    }

    _points = MathUtils.calculateTrajectoryPoints(
      origin: origin,
      velocity: velocity,
      gravity: GameConstants.gravity * GameConstants.gravityMultiplier,
      steps: 60,
      timeStep: 0.05,
    );
    visible = true;
  }

  void clear() {
    _points = [];
    visible = false;
  }

  @override
  void render(Canvas canvas) {
    if (!visible || _points.length < 2) return;

    for (var i = 0; i < _points.length; i++) {
      // Fade out dots along the trajectory
      final alpha = ((1.0 - i / _points.length) * 200).toInt().clamp(0, 255);
      final dotSize = 3.0 * (1.0 - i / _points.length * 0.5);

      final paint = Paint()
        ..color = Colors.white.withAlpha(alpha);

      // Draw every other dot for dotted effect
      if (i % 2 == 0) {
        canvas.drawCircle(
          Offset(_points[i].x, _points[i].y),
          dotSize,
          paint,
        );
      }
    }
  }
}
