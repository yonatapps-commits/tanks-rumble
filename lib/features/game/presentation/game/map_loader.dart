import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:tanks_rumble/features/game/presentation/components/terrain_collision.dart';

class MapData {
  final TiledComponent tiledMap;
  final Vector2 playerSpawn;
  final Vector2 enemySpawn;
  final Vector2 flagPosition;
  final ui.Rect starZone;
  final List<TerrainCollision> collisions;

  const MapData({
    required this.tiledMap,
    required this.playerSpawn,
    required this.enemySpawn,
    required this.flagPosition,
    required this.starZone,
    required this.collisions,
  });
}

class MapLoader {
  static Future<MapData> load(String mapFile) async {
    final tiledMap = await TiledComponent.load(
      mapFile,
      Vector2.all(32),
    );

    final objectLayer = tiledMap.tileMap.getLayer<ObjectGroup>('objects');
    final collisionLayer = tiledMap.tileMap.getLayer<ObjectGroup>('collision');

    // Defaults
    var playerSpawn = Vector2(150, 700);
    var enemySpawn = Vector2(1700, 700);
    var flagPosition = Vector2(960, 500);
    var starZone = const ui.Rect.fromLTWH(100, 64, 1720, 400);

    if (objectLayer != null) {
      for (final obj in objectLayer.objects) {
        switch (obj.name) {
          case 'spawn_player':
            playerSpawn = Vector2(obj.x, obj.y);
          case 'spawn_enemy':
            enemySpawn = Vector2(obj.x, obj.y);
          case 'flag_position':
            flagPosition = Vector2(obj.x, obj.y);
          case 'star_zone':
            starZone = ui.Rect.fromLTWH(obj.x, obj.y, obj.width, obj.height);
        }
      }
    }

    // Extract collision shapes
    final collisions = <TerrainCollision>[];
    if (collisionLayer != null) {
      for (final obj in collisionLayer.objects) {
        if (obj.isPolygon) {
          final vertices =
              obj.polygon.map((p) => Vector2(p.x, p.y)).toList();
          collisions.add(TerrainCollision(
            vertices: vertices,
            position: Vector2(obj.x, obj.y),
          ));
        } else if (obj.isRectangle) {
          final vertices = [
            Vector2.zero(),
            Vector2(obj.width, 0),
            Vector2(obj.width, obj.height),
            Vector2(0, obj.height),
          ];
          collisions.add(TerrainCollision(
            vertices: vertices,
            position: Vector2(obj.x, obj.y),
          ));
        }
      }
    }

    return MapData(
      tiledMap: tiledMap,
      playerSpawn: playerSpawn,
      enemySpawn: enemySpawn,
      flagPosition: flagPosition,
      starZone: starZone,
      collisions: collisions,
    );
  }
}
