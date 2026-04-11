import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class TerrainCollision extends PositionComponent with CollisionCallbacks {
  final List<Vector2> vertices;

  TerrainCollision({
    required this.vertices,
    required super.position,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(PolygonHitbox(vertices));
  }
}
