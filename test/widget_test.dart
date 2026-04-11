import 'package:flutter_test/flutter_test.dart';
import 'package:tanks_rumble/features/game/presentation/game/tank_game.dart';

void main() {
  test('TankGame can be instantiated', () {
    final game = TankGame();
    expect(game, isNotNull);
  });
}
