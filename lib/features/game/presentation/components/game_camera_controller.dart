import 'dart:math';

import 'package:flame/components.dart';
import 'package:tanks_rumble/core/constants/game_constants.dart';

enum CameraTarget { player, enemy, projectile, overview }

/// Controls camera position with smooth following and zoom.
class GameCameraController extends Component {
  final CameraComponent camera;
  PositionComponent? _target;
  bool _isOverview = false;

  /// The zoom level when following a tank.
  late final double _normalZoom;

  /// The zoom level to show the full map.
  late final double _overviewZoom;

  GameCameraController({required this.camera});

  @override
  void onMount() {
    super.onMount();

    final vpW = camera.viewport.size.x;
    final vpH = camera.viewport.size.y;

    // Normal: show cameraViewWidth of world
    _normalZoom = vpW / GameConstants.cameraViewWidth;

    // Overview: fit full map - use the smaller zoom so both width AND height fit
    final zoomW = vpW / GameConstants.worldWidth;
    final zoomH = vpH / GameConstants.worldHeight;
    _overviewZoom = min(zoomW, zoomH);
  }

  /// Set the component the camera should follow.
  void follow(PositionComponent target, {CameraTarget mode = CameraTarget.player}) {
    _target = target;
    _isOverview = false;
  }

  /// Set overview mode (hold = true, release = false).
  void setOverview(bool active) {
    _isOverview = active;
  }

  bool get isOverview => _isOverview;

  @override
  void update(double dt) {
    super.update(dt);

    if (_isOverview) {
      _lerpZoom(_overviewZoom, dt);
      // Center on the ground area (not dead center of world)
      _lerpPosition(
        Vector2(GameConstants.worldWidth / 2, 550),
        dt,
      );
      return;
    }

    if (_target == null) return;

    _lerpZoom(_normalZoom, dt);
    _lerpPosition(_clampedTarget(), dt);
  }

  void _lerpPosition(Vector2 targetPos, double dt) {
    final speed = GameConstants.cameraLerpSpeed;
    final current = camera.viewfinder.position;
    final diff = targetPos - current;

    if (diff.length < 1) {
      camera.viewfinder.position = targetPos;
    } else {
      camera.viewfinder.position = current + diff * (speed * dt).clamp(0, 1);
    }
  }

  void _lerpZoom(double targetZoom, double dt) {
    final current = camera.viewfinder.zoom;
    final diff = targetZoom - current;

    if (diff.abs() < 0.001) {
      camera.viewfinder.zoom = targetZoom;
    } else {
      camera.viewfinder.zoom =
          current + diff * (GameConstants.cameraLerpSpeed * dt).clamp(0, 1);
    }
  }

  /// Clamp so camera stays within world bounds.
  Vector2 _clampedTarget() {
    final target = _target!;
    final zoom = camera.viewfinder.zoom;
    if (zoom <= 0) return target.position.clone();

    final vpW = camera.viewport.size.x;
    final vpH = camera.viewport.size.y;

    final halfVisW = (vpW / zoom) / 2;
    final halfVisH = (vpH / zoom) / 2;

    final wCenter = GameConstants.worldWidth / 2;
    final hCenter = GameConstants.worldHeight / 2;

    // If view is wider/taller than world, center on world
    final double x;
    if (halfVisW * 2 >= GameConstants.worldWidth) {
      x = wCenter;
    } else {
      x = target.position.x.clamp(halfVisW, GameConstants.worldWidth - halfVisW);
    }

    final double y;
    if (halfVisH * 2 >= GameConstants.worldHeight) {
      y = hCenter;
    } else {
      y = target.position.y.clamp(halfVisH, GameConstants.worldHeight - halfVisH);
    }

    return Vector2(x, y);
  }
}
