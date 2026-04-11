# Phase 1: Project Setup - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use flutter-craft:flutter-executing to implement this plan task-by-task.

**Goal:** Create the Flutter project foundation with Flame Engine, folder structure, game constants, and a basic running game screen.

**Architecture:** Clean Architecture with Riverpod

**Dependencies:** flame, flame_tiled, flame_audio, flutter_riverpod, freezed_annotation

---

## Task 1: Create Flutter Project

**Layer:** Setup

**Commands:**
```bash
cd /Users/yehonatanohana/Documents/Claude/TanksRumble
flutter create . --project-name tanks_rumble --org com.tanksrumble
```

**Verification:**
```bash
flutter analyze
```

**Commit:**
```bash
git init
git add .
git commit -m "chore: init Flutter project"
```

---

## Task 2: Add Dependencies

**Layer:** Setup

**Files:**
- Modify: `pubspec.yaml`

**Implementation:**

Replace the `dependencies` and `dev_dependencies` sections in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.22.0
  flame_tiled: ^1.20.0
  flame_audio: ^2.10.0
  flutter_riverpod: ^2.6.0
  freezed_annotation: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  freezed: ^2.5.0
  build_runner: ^2.4.0
```

Also add the assets section under `flutter:`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/maps/
    - assets/tiles/
    - assets/sprites/
    - assets/audio/sfx/
    - assets/audio/music/
```

**Verification:**
```bash
flutter pub get
```

**Commit:**
```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add Flame, Riverpod, and Freezed dependencies"
```

---

## Task 3: Create Folder Structure & Placeholder Assets

**Layer:** Setup

**Directories to create:**
```
lib/core/constants/
lib/core/utils/
lib/features/game/domain/entities/
lib/features/game/domain/repositories/
lib/features/game/domain/usecases/
lib/features/game/data/repositories/
lib/features/game/presentation/game/
lib/features/game/presentation/components/
lib/features/game/presentation/overlays/
lib/features/game/presentation/providers/
lib/features/ai/domain/usecases/
lib/features/menu/presentation/screens/
assets/maps/
assets/tiles/
assets/sprites/
assets/audio/sfx/
assets/audio/music/
```

**Placeholder files** (empty .gitkeep in each assets folder so git tracks them):
```bash
touch assets/maps/.gitkeep
touch assets/tiles/.gitkeep
touch assets/sprites/.gitkeep
touch assets/audio/sfx/.gitkeep
touch assets/audio/music/.gitkeep
```

**Commit:**
```bash
git add lib/ assets/
git commit -m "chore: set up Clean Architecture folder structure"
```

---

## Task 4: Game Constants

**Layer:** Core

**Files:**
- Create: `lib/core/constants/game_constants.dart`

**Implementation:**

```dart
class GameConstants {
  GameConstants._();

  // Physics
  static const double gravity = 9.8;
  static const double maxPower = 500.0;
  static const double minPower = 50.0;
  static const double projectileRadius = 5.0;

  // Tank
  static const int maxHearts = 3;
  static const double tankWidth = 64.0;
  static const double tankHeight = 48.0;
  static const double tankSpeed = 100.0;

  // Fuel
  static const double fuelPerHit = 0.20; // 20% per hit
  static const double maxFuel = 1.0; // 100%
  static const double fuelConsumptionRate = 0.002; // per pixel moved

  // Stars & Flag
  static const int totalStars = 3;
  static const int starsToUnlockFlag = 2;

  // Turn
  static const int turnTimerSeconds = 20;

  // World
  static const double worldWidth = 1920.0;
  static const double worldHeight = 1080.0;
}
```

**Verification:**
```bash
flutter analyze lib/core/constants/game_constants.dart
```

**Commit:**
```bash
git add lib/core/constants/game_constants.dart
git commit -m "feat(core): add game constants"
```

---

## Task 5: Main Entry Point with Landscape Lock

**Layer:** Setup

**Files:**
- Modify: `lib/main.dart`

**Implementation:**

```dart
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
```

**Commit:**
```bash
git add lib/main.dart
git commit -m "feat: configure main.dart with landscape lock and Riverpod"
```

---

## Task 6: Basic TankGame (Placeholder)

**Layer:** Presentation

**Files:**
- Create: `lib/features/game/presentation/game/tank_game.dart`

**Implementation:**

```dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
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
      position: Vector2(150, GameConstants.worldHeight * 0.75 - GameConstants.tankHeight),
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
```

**Verification:**
```bash
flutter analyze
flutter run  # Should show sky-blue background, green ground, brown mountain, blue and red tanks
```

**Commit:**
```bash
git add lib/features/game/presentation/game/tank_game.dart
git commit -m "feat(game): add basic TankGame with placeholder rendering"
```

---
