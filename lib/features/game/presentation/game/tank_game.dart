import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/features/game/presentation/components/tank_component.dart';
import 'package:tanks_rumble/features/game/presentation/game/map_loader.dart';

class TankGame extends FlameGame with HasCollisionDetection {
  late TankComponent playerTank;
  late TankComponent enemyTank;
  late MapData mapData;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Sky blue

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load Tiled map
    mapData = await MapLoader.load('arena_01.tmx');

    // Add map to world
    world.add(mapData.tiledMap);

    // Add collision shapes
    for (final collision in mapData.collisions) {
      world.add(collision);
    }

    // Create tanks at spawn points
    playerTank = TankComponent(
      team: TankTeam.player,
      position: mapData.playerSpawn,
    );

    enemyTank = TankComponent(
      team: TankTeam.enemy,
      position: mapData.enemySpawn,
    );

    world.addAll([playerTank, enemyTank]);

    // Set up camera to show full map
    final mapSize = Vector2(
      mapData.tiledMap.width,
      mapData.tiledMap.height,
    );

    camera.viewfinder.visibleGameSize = mapSize;
    camera.viewfinder.position = mapSize / 2;
  }
}
