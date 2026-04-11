import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tanks_rumble/features/game/presentation/game/tank_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    const ProviderScope(
      child: TanksRumbleApp(),
    ),
  );
}

class TanksRumbleApp extends StatelessWidget {
  const TanksRumbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tanks Rumble',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: GameWidget(game: TankGame()),
    );
  }
}
