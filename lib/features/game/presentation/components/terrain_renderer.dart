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

  /// Creates the default arena terrain - same style, scaled for wide map.
  factory TerrainRenderer.arena() {
    const groundY = 880.0;
    final centerX = GameConstants.worldWidth / 2; // 3840

    // Single massive triangle mountain in center
    // ~40% of map width base, peak at ~20% from top
    final vertices = [
      Offset(centerX, 180),                // peak
      Offset(centerX + 1400, groundY),     // bottom right
      Offset(centerX - 1400, groundY),     // bottom left
    ];

    return TerrainRenderer(
      groundY: groundY,
      mountainVertices: vertices,
    );
  }

  @override
  void render(Canvas canvas) {
    final w = GameConstants.worldWidth;
    // Extra padding so camera never shows empty space
    const pad = 500.0;

    // Sky - extends far above
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Rect.fromLTWH(-pad, -pad, w + pad * 2, groundY + pad), skyPaint);

    // Ground - extends far below
    final groundPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(-pad, groundY, w + pad * 2, pad * 2), groundPaint);

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
