import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';

class TankGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Sky blue

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.visibleGameSize = Vector2(
      GameConstants.worldWidth,
      GameConstants.worldHeight,
    );

    // Placeholder ground
    final ground = RectangleComponent(
      position: Vector2(0, GameConstants.worldHeight * 0.75),
      size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight * 0.25),
      paint: Paint()..color = const Color(0xFF4CAF50),
    );

    // Placeholder mountain
    final mountain = RectangleComponent(
      position: Vector2(
        GameConstants.worldWidth / 2 - 100,
        GameConstants.worldHeight * 0.45,
      ),
      size: Vector2(200, GameConstants.worldHeight * 0.30),
      paint: Paint()..color = const Color(0xFF795548),
    );

    // Placeholder player tank
    final playerTank = RectangleComponent(
      position: Vector2(
        150,
        GameConstants.worldHeight * 0.75 - GameConstants.tankHeight,
      ),
      size: Vector2(GameConstants.tankWidth, GameConstants.tankHeight),
      paint: Paint()..color = const Color(0xFF2196F3),
    );

    // Placeholder enemy tank
    final enemyTank = RectangleComponent(
      position: Vector2(
        GameConstants.worldWidth - 150 - GameConstants.tankWidth,
        GameConstants.worldHeight * 0.75 - GameConstants.tankHeight,
      ),
      size: Vector2(GameConstants.tankWidth, GameConstants.tankHeight),
      paint: Paint()..color = const Color(0xFFF44336),
    );

    world.addAll([ground, mountain, playerTank, enemyTank]);
  }
}
