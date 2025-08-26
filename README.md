# Nave Morphis

A retro-neon futuristic space combat game for iOS built with SpriteKit and SwiftUI.

## Features

### Core Gameplay
- **Twin-stick controls**: Left stick for movement, right stick for aiming and shooting
- **Auto-fire mode**: Toggle automatic firing when aiming
- **Power-ups**: Health, energy, shield, damage boost, rapid fire, turbo, and morph abilities
- **Dynamic Difficulty Adjustment (DDA)**: Game adapts difficulty based on player performance
- **Wave-based progression**: Increasingly challenging enemy waves
- **Boss battles**: Epic mothership encounters with destructible modules

### Advanced AI
- **Hunter enemies**: Aggressive pursuit with steering behaviors and collision avoidance
- **Sniper enemies**: Maintain optimal distance and fire precise bursts
- **Flocking behavior**: Enemies use separation, alignment, and cohesion for realistic group movement
- **Smart pathfinding**: Enemies avoid boundaries and obstacles

### Visual Effects
- **Multi-layer parallax scrolling**: 5-layer deep space backgrounds
- **Particle systems**: Explosions, laser trails, thrust effects, and damage sparks
- **Screen effects**: Damage flashes, screen shake, and chromatic aberration
- **Neon aesthetic**: Glowing effects and retro-futuristic color palette
- **Animated nebulae**: Living background elements that move and pulse

### Audio & Haptics
- **Procedural SFX**: Dynamically generated sound effects for all game actions
- **Core Haptics**: Immersive feedback for impacts, explosions, and power-ups
- **Spatial audio**: Sounds positioned based on game events
- **Adaptive audio**: Volume and intensity adjust based on game state

### Technical Features
- **60 FPS target**: Optimized for smooth gameplay
- **Battery Saver mode**: Reduces effects for longer battery life
- **Physics simulation**: Realistic collision detection and response
- **Memory management**: Efficient particle and object pooling
- **Accessibility support**: High contrast mode, adjustable text size, reduced motion

## Requirements

- **iOS**: 17.0 or later
- **Device**: iPhone 12 or newer recommended
- **Xcode**: 15.0 or later for development
- **Swift**: 5.9 or later

## Installation

1. **Clone the repository**:
   ```bash
   git clone git@github.com:tagaa8/nave_morphis.git
   cd nave_morphis
   ```

2. **Open in Xcode**:
   ```bash
   open NaveMorphis.xcodeproj
   ```

3. **Build and Run**:
   - Select your target device or simulator
   - Press Cmd+R to build and run
   - Or use Product → Run from the menu

## Controls

### Touch Controls
- **Left side of screen**: Movement thumbstick
  - Drag to move your ship
  - Larger movements = faster acceleration
  
- **Right side of screen**: Aiming and firing
  - Tap to fire single shots
  - Hold and drag to aim continuous fire (auto-fire mode)
  - Distance from center determines fire direction

### Power-ups
- **Red (+)**: Restore health
- **Blue (⚡)**: Restore energy
- **Cyan (◊)**: Restore shield
- **Orange (⦿)**: Damage boost
- **Yellow (≡)**: Rapid fire
- **Green (▶)**: Turbo speed boost
- **Magenta (◈)**: Morph mode (triple shot)

## Game Modes

### Survival Mode
- Survive endless waves of enemies
- Difficulty increases with each wave
- Boss appears every 5th wave
- High score tracking

### Boss Rush Mode *(Future Update)*
- Face continuous boss encounters
- Unique boss mechanics and patterns
- Time-based scoring system

## Architecture

### Project Structure
```
NaveMorphis/
├── Sources/
│   ├── GameCore/           # Core game systems
│   │   ├── Physics.swift   # Collision detection
│   │   ├── GameConfig.swift # Game constants
│   │   └── HapticManager.swift
│   ├── Scenes/             # Game scenes
│   │   ├── MainMenuScene.swift
│   │   ├── GameScene.swift
│   │   ├── PauseScene.swift
│   │   └── GameOverScene.swift
│   ├── Entities/           # Game objects
│   │   ├── PlayerShipNode.swift
│   │   ├── EnemyShipNode.swift
│   │   ├── MothershipNode.swift
│   │   ├── LaserNode.swift
│   │   └── PowerUpNode.swift
│   ├── UI/                 # User interface
│   │   ├── HUDView.swift
│   │   └── Controls/
│   │       └── ThumbstickView.swift
│   ├── FX/                 # Effects and shaders
│   │   ├── Emitters/       # Particle effects
│   │   └── Shaders/        # Custom shaders
│   └── Audio/              # Audio system
│       └── SoundManager.swift
├── Assets.xcassets/        # Game assets
└── Scripts/                # Build scripts
    └── commit_push.sh
```

### Physics Categories
- **Player**: `1 << 0` - Player ship
- **Enemy**: `1 << 1` - Enemy ships  
- **LaserPlayer**: `1 << 2` - Player projectiles
- **LaserEnemy**: `1 << 3` - Enemy projectiles
- **Mothership**: `1 << 4` - Boss and modules
- **PowerUp**: `1 << 5` - Collectible items
- **Shield**: `1 << 6` - Shield effects
- **Boundary**: `1 << 7` - Screen boundaries

## Development

### Configuration
Game behavior can be tuned via `GameConfig.swift`:

```swift
struct GameConfig {
    struct Player {
        static let maxHealth: CGFloat = 100
        static let speed: CGFloat = 350
        static let fireRate: TimeInterval = 0.15
    }
    
    struct Enemy {
        static let baseHealth: CGFloat = 30
        static let baseSpeed: CGFloat = 200
        static let difficultyScaling: CGFloat = 1.15
    }
}
```

### Adding New Features

1. **New Enemy Types**:
   - Extend `EnemyType` enum in `EnemyShipNode.swift`
   - Implement new behavior in `updateAI` method
   - Add configuration in `GameConfig.swift`

2. **New Power-ups**:
   - Extend `PowerUpType` enum in `PlayerShipNode.swift`
   - Add visual representation in `PowerUpNode.swift`
   - Implement effect in `applyPowerUp` method

3. **New Scenes**:
   - Inherit from `SKScene`
   - Implement `didMove(to view:)` for setup
   - Add transition logic from existing scenes

### Performance Tips
- Use object pooling for frequently created/destroyed objects
- Batch particle effects updates
- Limit number of active sounds
- Use texture atlases for sprites
- Profile using Instruments for optimization

## Build Scripts

### Commit and Push Script
```bash
bash Scripts/commit_push.sh
```

This script:
- Stages all changes with `git add -A`
- Creates a descriptive commit message
- Pushes to the remote repository

## Troubleshooting

### Common Issues

**Build Errors**:
- Ensure iOS deployment target is set to 17.0+
- Check that all asset files are properly referenced
- Verify code signing settings

**Performance Issues**:
- Reduce particle count in GameConfig
- Enable Battery Saver mode
- Close background apps on device

**Audio Not Playing**:
- Check device volume and silent mode
- Verify audio session configuration
- Ensure sound files are included in bundle

### Debug Features
- **Show FPS**: Enabled in GameViewController for development
- **Physics Debug**: Can be enabled in GameViewController
- **Node Count**: Visible during development builds

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Use Swift naming conventions
- Add comments for complex algorithms
- Keep functions focused and small
- Use extensions to organize code
- Follow SOLID principles

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

**Development**: Created with Swift, SpriteKit, and SwiftUI
**Assets**: Procedurally generated placeholder assets
**Audio**: Dynamically generated sound effects
**Physics**: Built on SpriteKit physics engine
**Haptics**: Powered by Core Haptics framework

## Version History

### v1.0.0 (Current)
- Initial release with core gameplay
- Twin-stick controls and auto-fire
- 7 different power-ups
- Advanced enemy AI with flocking
- Boss battles with destructible modules
- Procedural audio and haptic feedback
- Multi-layer parallax backgrounds
- Performance optimizations

### Planned Updates
- **v1.1.0**: Additional enemy types and boss patterns
- **v1.2.0**: Local multiplayer support
- **v1.3.0**: Custom ship loadouts and upgrades
- **v2.0.0**: Campaign mode with story elements