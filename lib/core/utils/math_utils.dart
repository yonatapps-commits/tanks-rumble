import 'dart:math';

import 'package:flame/components.dart';

/// Utility class for trajectory and physics calculations.
class MathUtils {
  MathUtils._();

  /// Calculates trajectory points for a projectile.
  ///
  /// Returns a list of positions along the parabolic arc.
  /// [origin] - starting position of the projectile
  /// [velocity] - initial velocity vector (px/s)
  /// [gravity] - gravity acceleration (px/s²)
  /// [steps] - number of points to calculate
  /// [timeStep] - time between each point (seconds)
  static List<Vector2> calculateTrajectoryPoints({
    required Vector2 origin,
    required Vector2 velocity,
    required double gravity,
    int steps = 40,
    double timeStep = 0.05,
  }) {
    final points = <Vector2>[];
    for (var i = 0; i < steps; i++) {
      final t = i * timeStep;
      final x = origin.x + velocity.x * t;
      final y = origin.y + velocity.y * t + 0.5 * gravity * t * t;
      points.add(Vector2(x, y));
    }
    return points;
  }

  /// Converts a drag delta (from tank to finger) into shooting velocity.
  ///
  /// The shot goes in the OPPOSITE direction of the drag (slingshot style).
  /// Power is proportional to drag distance, clamped to [minPower, maxPower].
  static Vector2 dragToVelocity({
    required Vector2 dragDelta,
    required double minPower,
    required double maxPower,
    double sensitivity = 3.0,
  }) {
    final distance = dragDelta.length;
    if (distance < 5) return Vector2.zero();

    // Clamp power
    final power = (distance * sensitivity).clamp(minPower, maxPower);

    // Direction is opposite of drag (slingshot)
    final direction = -dragDelta.normalized();

    return direction * power;
  }

  /// Returns the angle in radians from a direction vector.
  /// 0 = right, pi/2 = down, -pi/2 = up
  static double vectorToAngle(Vector2 direction) {
    return atan2(direction.y, direction.x);
  }

  /// Returns a normalized power value (0.0 - 1.0) from drag distance.
  static double dragToPowerPercent({
    required double dragDistance,
    required double minPower,
    required double maxPower,
    double sensitivity = 3.0,
  }) {
    final power = (dragDistance * sensitivity).clamp(minPower, maxPower);
    return (power - minPower) / (maxPower - minPower);
  }
}
