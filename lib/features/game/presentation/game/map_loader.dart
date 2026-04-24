import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';
import 'package:tanks_rumble/features/game/presentation/components/terrain_collision.dart';

class MapData {
  final Vector2 playerSpawn;
  final Vector2 enemySpawn;
  final Vector2 flagPosition;
  final ui.Rect starZone;
  final List<TerrainCollision> collisions;

  const MapData({
    required this.playerSpawn,
    required this.enemySpawn,
    required this.flagPosition,
    required this.starZone,
    required this.collisions,
  });
}

class MapLoader {
  static const double groundY = 880.0;

  /// Generates map data matching TerrainRenderer.arena().
  /// No longer depends on Tiled TMX (old file had wrong dimensions).
  static MapData loadArena() {
    final w = GameConstants.worldWidth;
    final centerX = w / 2;

    return MapData(
      playerSpawn: Vector2(300, groundY - GameConstants.tankHeight),
      enemySpawn: Vector2(w - 380, groundY - GameConstants.tankHeight),
      flagPosition: Vector2(centerX, 500),
      starZone: ui.Rect.fromLTWH(500, 50, w - 1000, 400),
      collisions: _buildCollisions(centerX, w),
    );
  }

  static List<TerrainCollision> _buildCollisions(double centerX, double w) {
    return [
      // Ground - full width
      TerrainCollision(
        vertices: [
          Vector2.zero(),
          Vector2(w, 0),
          Vector2(w, 200),
          Vector2(0, 200),
        ],
        position: Vector2(0, groundY),
      ),

      // Mountain triangle - exact same shape as TerrainRenderer
      TerrainCollision(
        vertices: [
          Vector2(0, 180 - groundY),     // peak relative to position.y
          Vector2(1400, 0),              // bottom right at groundY
          Vector2(-1400, 0),             // bottom left at groundY
        ],
        position: Vector2(centerX, groundY),
      ),
    ];
  }
}
