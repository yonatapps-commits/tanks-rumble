import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';
import 'package:tanks_rumble/features/game/presentation/components/tank_component.dart';
import 'package:tanks_rumble/features/game/presentation/components/terrain_renderer.dart';
import 'package:tanks_rumble/features/game/presentation/game/map_loader.dart';

class TankGame extends FlameGame with HasCollisionDetection {
  late TankComponent playerTank;
  late TankComponent enemyTank;
  late MapData mapData;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load Tiled map for data only (spawn points, collision)
    mapData = await MapLoader.load('arena_01.tmx');

    // Render terrain visually (no tile seams)
    world.add(TerrainRenderer.arena());

    // Add collision shapes from Tiled
    for (final collision in mapData.collisions) {
      world.add(collision);
    }

    // Create tanks at spawn points from Tiled
    playerTank = TankComponent(
      team: TankTeam.player,
      position: mapData.playerSpawn,
    );

    enemyTank = TankComponent(
      team: TankTeam.enemy,
      position: mapData.enemySpawn,
    );

    world.addAll([playerTank, enemyTank]);

    // Camera shows full world
    final worldSize = Vector2(
      GameConstants.worldWidth,
      GameConstants.worldHeight,
    );
    camera.viewfinder.visibleGameSize = worldSize;
    camera.viewfinder.position = worldSize / 2;
  }
}
