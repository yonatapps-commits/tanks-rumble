import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';

/// Renders the terrain visually using solid shapes.
/// Tiled map is used only for data (spawn points, collision).
class TerrainRenderer extends PositionComponent {
  final double groundY;
  final List<Offset> mountainVertices;

  TerrainRenderer({
    required this.groundY,
    required this.mountainVertices,
  }) : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
        );

  /// Creates the default arena terrain.
  factory TerrainRenderer.arena() {
    const groundY = 26 * 32.0; // row 26 = ground start

    // Smooth triangle mountain
    final centerX = GameConstants.worldWidth / 2;
    const peakY = 18 * 32.0; // mountain peak
    const baseHalfWidth = 4 * 32.0; // 4 tiles wide on each side at base

    final vertices = [
      Offset(centerX, peakY),                  // peak (top center)
      Offset(centerX + baseHalfWidth, groundY), // bottom right
      Offset(centerX - baseHalfWidth, groundY), // bottom left
    ];

    return TerrainRenderer(
      groundY: groundY,
      mountainVertices: vertices,
    );
  }

  @override
  void render(Canvas canvas) {
    // Sky background
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, GameConstants.worldWidth, groundY),
      skyPaint,
    );

    // Ground
    final groundPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        groundY,
        GameConstants.worldWidth,
        GameConstants.worldHeight - groundY,
      ),
      groundPaint,
    );

    // Mountain (smooth triangle)
    final mountainPaint = Paint()..color = const Color(0xFF795548);
    final path = ui.Path();
    path.moveTo(mountainVertices[0].dx, mountainVertices[0].dy);
    for (var i = 1; i < mountainVertices.length; i++) {
      path.lineTo(mountainVertices[i].dx, mountainVertices[i].dy);
    }
    path.close();
    canvas.drawPath(path, mountainPaint);
  }
}
