import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';
import 'package:tanks_rumble/features/game/presentation/components/game_camera_controller.dart';
import 'package:tanks_rumble/features/game/presentation/components/hearts_display.dart';
import 'package:tanks_rumble/features/game/presentation/components/projectile_component.dart';
import 'package:tanks_rumble/features/game/presentation/components/tank_component.dart';
import 'package:tanks_rumble/features/game/presentation/components/terrain_renderer.dart';
import 'package:tanks_rumble/features/game/presentation/components/trajectory_line.dart';
import 'package:tanks_rumble/features/game/presentation/game/map_loader.dart';

class TankGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  late TankComponent playerTank;
  late TankComponent enemyTank;
  late MapData mapData;
  late TrajectoryLine trajectoryLine;
  late GameCameraController cameraController;

  /// When true, input on tanks is blocked (during overview).
  bool inputBlocked = false;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Generate map data (no TMX dependency)
    mapData = MapLoader.loadArena();

    // Render terrain
    world.add(TerrainRenderer.arena());

    // Add collision shapes
    for (final collision in mapData.collisions) {
      world.add(collision);
    }

    // Trajectory line
    trajectoryLine = TrajectoryLine();
    world.add(trajectoryLine);

    // Create tanks
    playerTank = TankComponent(
      team: TankTeam.player,
      position: mapData.playerSpawn,
    );
    playerTank.trajectoryLine = trajectoryLine;
    playerTank.onFire = _onProjectileFired;

    enemyTank = TankComponent(
      team: TankTeam.enemy,
      position: mapData.enemySpawn,
    );

    world.addAll([playerTank, enemyTank]);

    // Hearts display
    world.add(HeartsDisplay(tank: playerTank));
    world.add(HeartsDisplay(tank: enemyTank));

    // Camera controller
    cameraController = GameCameraController(camera: camera);
    cameraController.follow(playerTank);
    add(cameraController);

    // Initial camera state
    camera.viewfinder.zoom = camera.viewport.size.x / GameConstants.cameraViewWidth;
    camera.viewfinder.position = playerTank.position.clone();
  }

  void _onProjectileFired(ProjectileComponent projectile) {
    world.add(projectile);

    // Camera follows projectile
    cameraController.follow(projectile, mode: CameraTarget.projectile);

    // When projectile is removed, go back to player tank
    projectile.onRemoveCallback = () {
      cameraController.follow(playerTank);
    };
  }

  // --- Drag anywhere to aim & fire ---

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    playerTank.beginAim(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    playerTank.updateAim(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    playerTank.endAim();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    playerTank.cancelAim();
  }

  /// Called by eye button - hold mode.
  void setOverview(bool active) {
    cameraController.setOverview(active);
    inputBlocked = active;
  }
}
