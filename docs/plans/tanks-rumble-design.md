# TanksRumble - Game Design & Implementation Plan

## Context
Building a turn-based 2D side-view tank game (Flutter + Flame Engine) for mobile (iOS + Android), landscape orientation. Unique gameplay: tanks must hit enemies to gain fuel for movement, collect stars by shooting through them, unlock a flag, and race to capture it. Three win conditions create strategic depth. Cartoon art style, Tiled Editor for map design.

## Game Design

### Arena
- 2D side-view, **landscape** orientation, cartoon/illustrated art style
- Terrain designed in **Tiled Editor** (.tmx) with tileset sprite sheets
- Mountain in the center with a locked flag (in a cage) at the top
- 3 stars scattered randomly in the sky each game
- Two tanks at opposite ends of the map
- Tanks can climb the mountain slopes to reach the flag

### Core Mechanics

1. **Shooting (Slingshot)**: Drag back from tank to aim (angle + power), release to fire. Projectile follows gravity arc (no wind)
2. **Fuel System**: Start with 0 fuel. Each hit on enemy = **+20% fuel**. Need 5 hits for full tank
3. **Movement**: Left/Right buttons, consumes fuel. Tanks can traverse terrain including mountain slopes
4. **Turn Choice**: Each turn, player chooses to **shoot OR move** (not both)
5. **Stars**: Collected when projectile passes through them mid-flight
6. **Flag**: Locked in cage, opens when 2+ stars collected (shared count between players)
7. **Turn Timer**: 15-30 seconds per turn

### Win Conditions
1. **Capture the Flag** - Reach the flag after cage opens (2 stars collected by either side)
2. **Star Domination** - Collect all 3 stars solo (no opponent stars) → instant win
3. **Destroy Enemy** - Reduce enemy HP to 0

### HP System
- Each tank has **3 hearts**
- Each hit = -1 heart
- 0 hearts = destroyed

### Camera
- **Follows projectile** during shot, zooming into impact point
- Returns to active tank after resolution

### Visual Effects
- Explosion on projectile impact (particles)
- Star sparkle/collect animation
- Heart loss animation
- Cage opening animation when 2 stars collected

### Audio
- Sound effects: shooting, explosion, star collect, heart loss, victory/defeat
- Background music during gameplay and menu

### AI Opponent
- Calculates angle + power toward player with randomized accuracy
- Basic strategy: shoot at player, occasionally aim for stars
- Movement: moves toward flag if has fuel and cage is open

---

## Architecture (Clean Architecture + Flame + Tiled)

### Map Design with Tiled Editor
Maps are designed in **Tiled Map Editor** (.tmx files) and loaded with `flame_tiled`:
- **Tile layers**: ground, mountain, decorations, background
- **Object layers**: spawn points (tanks, stars, flag), collision shapes
- Tilesets stored in `assets/tiles/` as sprite sheets + .tsx files
- Each map is a `.tmx` file in `assets/maps/`

```
assets/
├── maps/
│   └── arena_01.tmx              # Tiled map file (single map for MVP)
├── tiles/
│   ├── terrain_tileset.tsx        # Tileset definition
│   └── terrain_tileset.png        # Tileset sprite sheet
├── sprites/
│   ├── tank_player.png
│   ├── tank_enemy.png
│   ├── projectile.png
│   ├── star.png
│   ├── flag.png
│   ├── cage.png
│   ├── heart.png
│   └── explosion_sheet.png        # Sprite sheet for explosion animation
└── audio/
    ├── sfx/
    │   ├── shoot.wav
    │   ├── explosion.wav
    │   ├── star_collect.wav
    │   ├── heart_loss.wav
    │   └── victory.wav
    └── music/
        ├── menu_bgm.mp3
        └── game_bgm.mp3
```

### Tiled Map Structure (layers)
```
Layer 5: sky_decorations    (Tile layer - clouds, etc.)
Layer 4: objects            (Object layer - spawn_player, spawn_enemy, star_zone, flag_position)
Layer 3: collision          (Object layer - polygon collision shapes for terrain)
Layer 2: foreground         (Tile layer - terrain details, grass, rocks)
Layer 1: terrain            (Tile layer - main ground + mountain tiles)
Layer 0: background         (Tile layer - sky, parallax)
```

### Code Structure
```
lib/
├── core/
│   ├── constants/
│   │   └── game_constants.dart        # Physics, fuel rates, HP, sizes, turn timer
│   └── utils/
│       └── math_utils.dart            # Trajectory calculation helpers
│
├── features/
│   ├── game/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── tank_entity.dart       # HP (3 hearts), fuel (0-100%), position, team
│   │   │   │   ├── projectile_entity.dart # angle, power, position
│   │   │   │   ├── star_entity.dart       # position, collected, collectedBy
│   │   │   │   ├── flag_entity.dart       # locked/unlocked, position
│   │   │   │   └── game_state_entity.dart # turn, phase (shoot/move), timer, win condition
│   │   │   ├── repositories/
│   │   │   │   └── game_repository.dart   # Interface for game state
│   │   │   └── usecases/
│   │   │       ├── shoot_usecase.dart        # Fire projectile
│   │   │       ├── move_tank_usecase.dart    # Move with fuel consumption
│   │   │       ├── collect_star_usecase.dart  # Star collection logic
│   │   │       └── check_win_usecase.dart     # 3 win conditions check
│   │   │
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── game_repository_impl.dart
│   │   │
│   │   └── presentation/
│   │       ├── game/
│   │       │   ├── tank_game.dart           # Main FlameGame class
│   │       │   └── game_world.dart          # World setup, load Tiled map
│   │       ├── components/
│   │       │   ├── tank_component.dart      # Tank sprite + slingshot input
│   │       │   ├── projectile_component.dart # Projectile with gravity physics
│   │       │   ├── star_component.dart      # Collectible star with sparkle effect
│   │       │   ├── flag_component.dart      # Flag + cage visual + open animation
│   │       │   ├── tiled_map_component.dart # Load & render .tmx map + collision
│   │       │   ├── explosion_component.dart # Particle explosion effect
│   │       │   └── trajectory_line.dart     # Dotted aim line during drag
│   │       ├── overlays/
│   │       │   ├── hud_overlay.dart         # Hearts, fuel bar, stars, turn timer
│   │       │   ├── turn_indicator.dart      # Whose turn + shoot/move choice
│   │       │   ├── movement_controls.dart   # Left/Right buttons (shown when move chosen)
│   │       │   ├── win_overlay.dart         # Victory/defeat screen + Play Again
│   │       │   └── pause_overlay.dart       # Pause menu
│   │       └── providers/
│   │           └── game_provider.dart       # Riverpod state management
│   │
│   ├── ai/
│   │   └── domain/
│   │       └── usecases/
│   │           └── ai_turn_usecase.dart     # AI decision: shoot/move, aim logic
│   │
│   └── menu/
│       └── presentation/
│           └── screens/
│               └── main_menu_screen.dart    # Title + Play button
│
└── main.dart                               # App entry, Riverpod, landscape lock
```

---

## Implementation Plan (Ordered Phases)

### Phase 1: Project Setup
- [ ] Create Flutter project with `flutter create tanks_rumble`
- [ ] Add dependencies: `flame`, `flame_tiled`, `flame_audio`, `flutter_riverpod`, `freezed`, `freezed_annotation`, `build_runner`, `json_annotation`
- [ ] Set up folder structure (Clean Architecture)
- [ ] Set up `assets/` folders: `maps/`, `tiles/`, `sprites/`, `audio/sfx/`, `audio/music/`
- [ ] Lock orientation to landscape in `main.dart`
- [ ] Configure `game_constants.dart`: gravity, max power, fuel per hit (20%), hearts (3), turn timer (20s)

**Files:** `pubspec.yaml`, `lib/main.dart`, `lib/core/constants/game_constants.dart`

### Phase 2: Tiled Map & Basic Rendering
- [ ] Create placeholder tileset sprite sheet (`terrain_tileset.png`) and `.tsx` definition
- [ ] Design first map in Tiled Editor: terrain + mountain + spawn points + collision layer → `arena_01.tmx`
- [ ] Create `TiledMapComponent` wrapper - load `.tmx`, extract collision polygons from object layer
- [ ] Create `TankGame` (FlameGame) with camera setup (landscape viewport)
- [ ] Read spawn points from Tiled object layer (spawn_player, spawn_enemy, flag_position)
- [ ] Create basic `TankComponent` - static tank sprite placed at spawn points
- [ ] Render two tanks on the Tiled map

**Files:** `assets/maps/arena_01.tmx`, `assets/tiles/terrain_tileset.*`, `tiled_map_component.dart`, `tank_game.dart`, `tank_component.dart`

### Phase 3: Slingshot Shooting Mechanic
- [ ] Implement drag-back input on player tank (DragCallbacks)
- [ ] Create `TrajectoryLine` - dotted line showing aim direction + power
- [ ] Create `ProjectileComponent` with gravity physics (parabolic arc, no wind)
- [ ] Camera follows projectile during flight, zooms to impact point
- [ ] Collision detection: projectile vs Tiled collision polygons, projectile vs tank
- [ ] Create `ExplosionComponent` particle effect on impact

**Files:** `projectile_component.dart`, `trajectory_line.dart`, `explosion_component.dart`, `math_utils.dart`

### Phase 4: Turn System & HP
- [ ] Implement `GameStateEntity` - track turns, HP, fuel, stars, turn phase
- [ ] Turn choice: player picks **Shoot** or **Move** each turn
- [ ] Turn timer (20 seconds countdown)
- [ ] Turn flow: Player acts → resolve → AI acts → resolve → repeat
- [ ] HP system: 3 hearts, hit = -1 heart, heart loss animation
- [ ] Win condition #3: Destroy enemy → victory

**Files:** `game_state_entity.dart`, `tank_entity.dart`, `check_win_usecase.dart`, `game_provider.dart`

### Phase 5: Fuel & Movement
- [ ] Fuel meter: starts at 0, +20% on enemy hit (5 hits = full)
- [ ] Movement controls overlay (Left/Right buttons) - shown when "Move" chosen
- [ ] Tank movement on terrain, including climbing mountain slopes
- [ ] Movement consumes fuel proportionally to distance

**Files:** `move_tank_usecase.dart`, `movement_controls.dart`, `hud_overlay.dart`

### Phase 6: Stars & Flag System
- [ ] Create `StarComponent` - 3 random positions in sky, sparkle animation
- [ ] Collision: projectile passes through star → collected (sparkle + collect SFX)
- [ ] Track star ownership: which player collected which star
- [ ] Star counter in HUD (player stars / total collected)
- [ ] Create `FlagComponent` on mountain top with cage visual
- [ ] Cage opens animation when 2 stars collected (any player combination)
- [ ] Win condition #1: tank reaches open flag → victory
- [ ] Win condition #2: one player collects all 3 stars alone → instant win

**Files:** `star_component.dart`, `flag_component.dart`, `star_entity.dart`, `flag_entity.dart`, `collect_star_usecase.dart`

### Phase 7: AI Opponent
- [ ] `AITurnUseCase` - decide shoot vs move
- [ ] Shooting: calculate angle/power toward player with randomized accuracy
- [ ] Movement: move toward flag if has fuel + cage is open
- [ ] Star awareness: occasionally aim to collect stars near trajectory

**Files:** `ai_turn_usecase.dart`

### Phase 8: HUD & Overlays
- [ ] HUD: hearts display (both tanks), fuel bar, star counter, turn timer countdown
- [ ] Turn indicator: whose turn + Shoot/Move choice buttons
- [ ] Win/Lose overlay with reason (flag captured / stars dominated / enemy destroyed) + "Play Again"
- [ ] Pause overlay with Resume/Quit

**Files:** `hud_overlay.dart`, `win_overlay.dart`, `turn_indicator.dart`, `pause_overlay.dart`

### Phase 9: Audio
- [ ] Add `flame_audio` sound effects: shoot, explosion, star collect, heart loss, victory/defeat
- [ ] Background music: menu BGM, game BGM
- [ ] Mute toggle in pause menu

**Files:** `audio/sfx/*`, `audio/music/*`, integration in components

### Phase 10: Main Menu
- [ ] Main menu screen with game title + "Play" button + settings (sound toggle)
- [ ] Navigation: menu → game → win/lose → menu

**Files:** `main_menu_screen.dart`, `main.dart`

---

## Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.22.0
  flame_tiled: ^1.20.0
  flame_audio: ^2.10.0
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  freezed: ^2.5.0
  freezed_annotation: ^2.4.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.6.0
  json_serializable: ^6.8.0
```

---

## Verification Plan
1. **Phase 1-2**: Run app → see Tiled map loaded (landscape) with mountain terrain and two tanks at spawn points
2. **Phase 3**: Drag on player tank → see trajectory line → release → projectile flies with gravity → camera follows → explosion on impact
3. **Phase 4**: Choose Shoot → hit enemy → heart lost (3→2) → kill enemy → win screen. Timer counts down each turn
4. **Phase 5**: Hit enemy → fuel bar +20% → choose Move → press L/R → tank moves, fuel decreases. Tank can climb mountain
5. **Phase 6**: Shoot through star → sparkle + collected → collect 2 → cage opens → move to flag → win. Also: collect all 3 solo → instant win
6. **Phase 7**: AI turn → AI decides shoot/move → shoots toward player with varying accuracy → AI moves toward flag when strategic
7. **Phase 8**: Full HUD visible: hearts, fuel, stars, timer. Win screen shows victory reason
8. **Phase 9**: Sound effects play on actions. Music plays in menu and game. Mute works
9. **Phase 10**: Full game loop: menu → play → game → win/lose → play again / back to menu
