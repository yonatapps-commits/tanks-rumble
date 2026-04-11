import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';

/// Renders the terrain visually using solid shapes.
/// Tiled map is used only for data (spawn points, collision).
class TerrainRenderer extends PositionComponent {
  final double groundY;
  final List<MountainLayer> mountainLayers;

  TerrainRenderer({
    required this.groundY,
    required this.mountainLayers,
  }) : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
        );

  /// Creates the default arena terrain.
  factory TerrainRenderer.arena() {
    const groundRow = 26;
    const groundY = groundRow * 32.0;

    // Mountain trapezoid layers (narrowing toward top)
    final layers = <MountainLayer>[];
    for (var row = 0; row < 8; row++) {
      final shrink = row ~/ 2;
      final mLeft = (27 + shrink) * 32.0;
      final mRight = (33 - shrink + 1) * 32.0;
      final y = (18 + row) * 32.0;
      layers.add(MountainLayer(
        rect: Rect.fromLTRB(mLeft, y, mRight, y + 32),
      ));
    }

    return TerrainRenderer(
      groundY: groundY,
      mountainLayers: layers,
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

    // Mountain
    final mountainPaint = Paint()..color = const Color(0xFF795548);
    for (final layer in mountainLayers) {
      canvas.drawRect(layer.rect, mountainPaint);
    }
  }
}

class MountainLayer {
  final Rect rect;
  const MountainLayer({required this.rect});
}
