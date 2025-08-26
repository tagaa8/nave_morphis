import Foundation
import CoreGraphics

struct GameConfig {
    
    struct Player {
        static let maxHealth: CGFloat = 100
        static let maxShield: CGFloat = 50
        static let maxEnergy: CGFloat = 100
        static let speed: CGFloat = 350
        static let fireRate: TimeInterval = 0.15
        static let laserDamage: CGFloat = 10
        static let respawnInvulnerability: TimeInterval = 2.0
        static let energyRegenRate: CGFloat = 5.0
        static let shieldRegenDelay: TimeInterval = 3.0
        static let morphDuration: TimeInterval = 5.0
        static let turboDuration: TimeInterval = 3.0
        static let turboSpeedMultiplier: CGFloat = 2.0
    }
    
    struct Enemy {
        static let baseHealth: CGFloat = 30
        static let baseSpeed: CGFloat = 200
        static let baseDamage: CGFloat = 15
        static let baseFireRate: TimeInterval = 1.0
        static let scoreValue: Int = 100
        static let hunterAcceleration: CGFloat = 150
        static let sniperRange: CGFloat = 400
        static let sniperBurstCount: Int = 3
        static let difficultyScaling: CGFloat = 1.15
    }
    
    struct Mothership {
        static let health: CGFloat = 1000
        static let moduleHealth: CGFloat = 200
        static let moduleCount: Int = 4
        static let turretFireRate: TimeInterval = 0.5
        static let missileDamage: CGFloat = 30
        static let beamDamage: CGFloat = 50
        static let scoreValue: Int = 5000
        static let enrageHealthThreshold: CGFloat = 0.3
    }
    
    struct PowerUp {
        static let healAmount: CGFloat = 25
        static let energyAmount: CGFloat = 50
        static let damageMultiplier: CGFloat = 2.0
        static let fireRateMultiplier: CGFloat = 0.5
        static let duration: TimeInterval = 10.0
        static let spawnChance: CGFloat = 0.15
        static let magnetRange: CGFloat = 150
    }
    
    struct Visual {
        static let parallaxLayers: Int = 5
        static let starCount: Int = 200
        static let nebulaAlpha: CGFloat = 0.4
        static let trailLength: Int = 10
        static let explosionParticles: Int = 50
        static let damageFlashDuration: TimeInterval = 0.1
        static let screenShakeIntensity: CGFloat = 10
        static let chromaticAberrationStrength: CGFloat = 5
    }
    
    struct Audio {
        static let masterVolume: Float = 0.8
        static let sfxVolume: Float = 0.7
        static let musicVolume: Float = 0.5
        static let hapticIntensity: Float = 0.8
    }
    
    struct Game {
        static let waveInterval: TimeInterval = 30.0
        static let enemiesPerWave: Int = 5
        static let maxEnemiesOnScreen: Int = 15
        static let scoreMultiplierDecay: TimeInterval = 5.0
        static let maxScoreMultiplier: Int = 10
        static let ddaUpdateInterval: TimeInterval = 10.0
        static let softWrapBoundary: CGFloat = 50
        static let targetFPS: Int = 60
        static let batterySaverFPS: Int = 30
    }
    
    struct Controls {
        static let thumbstickRadius: CGFloat = 60
        static let thumbstickSensitivity: CGFloat = 1.0
        static let autoFireEnabled: Bool = true
        static let deadZone: CGFloat = 0.15
        static let maxThumbstickRange: CGFloat = 80
    }
    
    struct Accessibility {
        static let highContrastMode: Bool = false
        static let reducedMotion: Bool = false
        static let textScaleFactor: CGFloat = 1.0
        static let colorBlindMode: String = "none"
        static let subtitlesEnabled: Bool = false
    }
    
    static func difficulty(for wave: Int) -> CGFloat {
        return 1.0 + (CGFloat(wave) * 0.2)
    }
    
    static func enemyCount(for wave: Int) -> Int {
        return min(Game.enemiesPerWave + (wave / 2), Game.maxEnemiesOnScreen)
    }
    
    static func shouldSpawnBoss(wave: Int) -> Bool {
        return wave > 0 && wave % 5 == 0
    }
}