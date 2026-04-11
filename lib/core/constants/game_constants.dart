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
