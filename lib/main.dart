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
    final game = TankGame();

    return MaterialApp(
      title: 'Tanks Rumble',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game),
            // Eye button - top right
            Positioned(
              top: 16,
              right: 16,
              child: _EyeButton(game: game),
            ),
          ],
        ),
      ),
    );
  }
}

class _EyeButton extends StatefulWidget {
  final TankGame game;
  const _EyeButton({required this.game});

  @override
  State<_EyeButton> createState() => _EyeButtonState();
}

class _EyeButtonState extends State<_EyeButton> {
  bool _holding = false;

  void _onDown() {
    setState(() => _holding = true);
    widget.game.setOverview(true);
  }

  void _onUp() {
    setState(() => _holding = false);
    widget.game.setOverview(false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onDown(),
      onTapUp: (_) => _onUp(),
      onTapCancel: _onUp,
      onLongPressStart: (_) => _onDown(),
      onLongPressEnd: (_) => _onUp(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _holding
              ? Colors.white.withAlpha(200)
              : Colors.black.withAlpha(120),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withAlpha(150),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.zoom_out_map,
          color: _holding ? Colors.black87 : Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
