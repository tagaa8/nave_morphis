import UIKit
import SceneKit
import GameplayKit

class Game3DScene: SCNScene {
    
    // MARK: - Game Properties
    internal var score = 0
    internal var lives = 3
    internal var wave = 1
    internal var gameState: GameState = .playing
    
    // MARK: - 3D Nodes
    internal var cameraNode: SCNNode!
    internal var lightNode: SCNNode!
    internal var playerShip: SCNNode!
    internal var spaceStation: SCNNode!
    internal var enemyShips: [SCNNode] = []
    internal var bullets: [SCNNode] = []
    
    // MARK: - Game Controller
    internal weak var sceneView: SCNView?
    internal var lastUpdateTime: TimeInterval = 0
    
    // MARK: - Input
    private var isMovingForward = false
    private var isMovingBackward = false
    private var isMovingLeft = false
    private var isMovingRight = false
    private var isMovingUp = false
    private var isMovingDown = false
    private var isFiring = false
    
    // MARK: - Collision Cooldown
    internal var lastCollisionTime: TimeInterval = 0
    internal let collisionCooldown: TimeInterval = 1.0
    
    // MARK: - Physics Categories
    struct PhysicsCategory {
        static let none: Int = 0
        static let player: Int = 0x1 << 0
        static let enemy: Int = 0x1 << 1
        static let bullet: Int = 0x1 << 2
        static let enemyBullet: Int = 0x1 << 3
        static let station: Int = 0x1 << 4
    }
    
    enum GameState {
        case playing, paused, gameOver
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupScene()
        setupCamera()
        setupLighting()
        loadSpaceStation()
        loadPlayerShip()
        setupPhysics()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupScene() {
        // Space background
        background.contents = UIColor.black
        
        // Add starfield
        createStarfield()
        
        // Physics world setup
        physicsWorld.gravity = SCNVector3(0, 0, 0) // Zero gravity space
        physicsWorld.contactDelegate = self
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 30)
        cameraNode.eulerAngles = SCNVector3(x: -0.3, y: 0, z: 0)
        
        // Camera settings for better 3D view
        cameraNode.camera?.fieldOfView = 60
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 1000
        
        rootNode.addChildNode(cameraNode)
    }
    
    private func setupLighting() {
        // Ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.3, alpha: 1.0)
        rootNode.addChildNode(ambientLight)
        
        // Main directional light
        lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.light?.color = UIColor.white
        lightNode.light?.intensity = 1000
        lightNode.position = SCNVector3(x: 10, y: 20, z: 10)
        lightNode.eulerAngles = SCNVector3(x: -0.5, y: 0.3, z: 0)
        rootNode.addChildNode(lightNode)
        
        // Additional fill light
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .omni
        fillLight.light?.color = UIColor.blue
        fillLight.light?.intensity = 300
        fillLight.position = SCNVector3(x: -10, y: -5, z: 15)
        rootNode.addChildNode(fillLight)
    }
    
    private func createStarfield() {
        // Create particle system for stars
        let stars = SCNParticleSystem()
        stars.birthRate = 50
        stars.particleLifeSpan = 60
        stars.particleColor = UIColor.white
        stars.particleSize = 1.0
        stars.particleSizeVariation = 0.5
        stars.emitterShape = SCNSphere(radius: 100)
        stars.particleVelocity = 0
        stars.particleVelocityVariation = 0
        
        let starsNode = SCNNode()
        starsNode.addParticleSystem(stars)
        rootNode.addChildNode(starsNode)
    }
    
    private func loadSpaceStation() {
        spaceStation = createSpaceStationNode()
        spaceStation.position = SCNVector3(x: 0, y: 0, z: -50)
        spaceStation.scale = SCNVector3(2, 2, 2)
        
        // Add physics
        spaceStation.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        spaceStation.physicsBody?.categoryBitMask = PhysicsCategory.station
        
        rootNode.addChildNode(spaceStation)
        
        // Rotate the station slowly
        let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 60)
        let repeatRotate = SCNAction.repeatForever(rotateAction)
        spaceStation.runAction(repeatRotate)
    }
    
    private func createSpaceStationNode() -> SCNNode {
        let stationNode = SCNNode()
        
        // Central hub
        let hubGeometry = SCNCylinder(radius: 3, height: 6)
        hubGeometry.firstMaterial?.diffuse.contents = UIColor.gray
        hubGeometry.firstMaterial?.metalness.contents = 0.8
        hubGeometry.firstMaterial?.roughness.contents = 0.2
        let hub = SCNNode(geometry: hubGeometry)
        hub.eulerAngles = SCNVector3(CGFloat.pi/2, 0, 0)
        stationNode.addChildNode(hub)
        
        // Outer ring
        let ringGeometry = SCNTorus(ringRadius: 15, pipeRadius: 2)
        ringGeometry.firstMaterial?.diffuse.contents = UIColor.darkGray
        ringGeometry.firstMaterial?.metalness.contents = 0.7
        let ring = SCNNode(geometry: ringGeometry)
        stationNode.addChildNode(ring)
        
        // Connecting pylons
        for i in 0..<6 {
            let angle = Float(i) * Float.pi / 3
            let pylonGeometry = SCNBox(width: 0.5, height: 12, length: 0.5, chamferRadius: 0)
            pylonGeometry.firstMaterial?.diffuse.contents = UIColor.lightGray
            let pylon = SCNNode(geometry: pylonGeometry)
            pylon.position = SCNVector3(cos(angle) * 9, 0, sin(angle) * 9)
            stationNode.addChildNode(pylon)
        }
        
        // Add some lights
        for i in 0..<8 {
            let angle = Float(i) * Float.pi / 4
            let lightGeometry = SCNSphere(radius: 0.2)
            lightGeometry.firstMaterial?.emission.contents = UIColor.cyan
            let lightNode = SCNNode(geometry: lightGeometry)
            lightNode.position = SCNVector3(cos(angle) * 15, 0, sin(angle) * 15)
            stationNode.addChildNode(lightNode)
        }
        
        return stationNode
    }
    
    private func loadPlayerShip() {
        // Create USS Defiant-style ship
        playerShip = createPlayerShipNode()
        playerShip.position = SCNVector3(x: 0, y: 0, z: 10)
        playerShip.scale = SCNVector3(0.5, 0.5, 0.5)
        
        // Add physics
        playerShip.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        playerShip.physicsBody?.categoryBitMask = PhysicsCategory.player
        playerShip.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.enemyBullet
        
        rootNode.addChildNode(playerShip)
    }
    
    private func createPlayerShipNode() -> SCNNode {
        // Try to load the actual USS Defiant model
        if let url = Bundle.main.url(forResource: "uss_defiant", withExtension: "obj") {
            do {
                let scene = try SCNScene(url: url, options: nil)
                let shipNode = SCNNode()
                
                // Add all child nodes from the loaded scene
                for child in scene.rootNode.childNodes {
                    shipNode.addChildNode(child)
                }
                
                // Scale the model appropriately
                shipNode.scale = SCNVector3(0.1, 0.1, 0.1)
                
                // Ensure materials are properly configured
                shipNode.enumerateChildNodes { (node, stop) in
                    if let geometry = node.geometry {
                        for material in geometry.materials {
                            material.lightingModel = .physicallyBased
                            if material.diffuse.contents == nil {
                                material.diffuse.contents = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0)
                            }
                            material.metalness.contents = 0.3
                            material.roughness.contents = 0.7
                        }
                    }
                }
                
                return shipNode
            } catch {
                print("Failed to load USS Defiant model: \(error)")
            }
        }
        
        // Fallback to procedural USS Defiant-style ship
        let shipNode = SCNNode()
        
        // Main hull (Defiant-style)
        let hullGeometry = SCNBox(width: 3, height: 0.8, length: 6, chamferRadius: 0.1)
        hullGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        hullGeometry.firstMaterial?.metalness.contents = 0.8
        hullGeometry.firstMaterial?.roughness.contents = 0.3
        let hull = SCNNode(geometry: hullGeometry)
        shipNode.addChildNode(hull)
        
        // Wings
        let wingGeometry = SCNBox(width: 6, height: 0.3, length: 2, chamferRadius: 0.05)
        wingGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        wingGeometry.firstMaterial?.metalness.contents = 0.8
        let wings = SCNNode(geometry: wingGeometry)
        wings.position = SCNVector3(0, 0, -1)
        shipNode.addChildNode(wings)
        
        // Engine nacelles
        for x in [-2.0, 2.0] {
            let nacelleGeometry = SCNCylinder(radius: 0.3, height: 3)
            nacelleGeometry.firstMaterial?.diffuse.contents = UIColor.darkGray
            nacelleGeometry.firstMaterial?.emission.contents = UIColor.cyan
            let nacelle = SCNNode(geometry: nacelleGeometry)
            nacelle.position = SCNVector3(Float(x), -0.2, -1.5)
            nacelle.eulerAngles = SCNVector3(CGFloat.pi/2, 0, 0)
            shipNode.addChildNode(nacelle)
        }
        
        // Bridge/cockpit
        let bridgeGeometry = SCNSphere(radius: 0.4)
        bridgeGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        bridgeGeometry.firstMaterial?.transparency = 0.8
        let bridge = SCNNode(geometry: bridgeGeometry)
        bridge.position = SCNVector3(0, 0.6, 1)
        shipNode.addChildNode(bridge)
        
        return shipNode
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = SCNVector3(0, 0, 0)
    }
    
    // MARK: - Game Loop
    func update(atTime time: TimeInterval, in sceneView: SCNView) {
        self.sceneView = sceneView
        
        if lastUpdateTime == 0 {
            lastUpdateTime = time
        }
        
        let deltaTime = time - lastUpdateTime
        lastUpdateTime = time
        
        guard gameState == .playing else { return }
        
        updatePlayerMovement(deltaTime: deltaTime)
        updateEnemies(deltaTime: deltaTime)
        updateBullets(deltaTime: deltaTime)
        updateCamera()
        
        // Spawn enemies periodically (less frequently to avoid collision spam)
        if enemyShips.count < 2 && Int(time) % 8 == 0 {
            spawnEnemy()
        }
    }
    
    private func updatePlayerMovement(deltaTime: TimeInterval) {
        let moveSpeed: Float = 20.0
        
        var movement = SCNVector3(0, 0, 0)
        
        if isMovingForward { movement.z -= moveSpeed }
        if isMovingBackward { movement.z += moveSpeed }
        if isMovingLeft { movement.x -= moveSpeed }
        if isMovingRight { movement.x += moveSpeed }
        if isMovingUp { movement.y += moveSpeed }
        if isMovingDown { movement.y -= moveSpeed }
        
        // Apply movement
        if movement.x != 0 || movement.y != 0 || movement.z != 0 {
            let scaledMovement = SCNVector3(
                movement.x * Float(deltaTime),
                movement.y * Float(deltaTime),
                movement.z * Float(deltaTime)
            )
            playerShip.position = SCNVector3(
                playerShip.position.x + scaledMovement.x,
                playerShip.position.y + scaledMovement.y,
                playerShip.position.z + scaledMovement.z
            )
            
            // Add banking rotation when turning
            let bankAngle = movement.x * 0.3
            playerShip.eulerAngles = SCNVector3(0, 0, -bankAngle)
        } else {
            // Return to level when not turning
            playerShip.eulerAngles = SCNVector3(0, 0, 0)
        }
        
        // Keep player in bounds
        let bounds: Float = 25
        playerShip.position.x = max(-bounds, min(bounds, playerShip.position.x))
        playerShip.position.y = max(-bounds/2, min(bounds/2, playerShip.position.y))
        playerShip.position.z = max(-10, min(20, playerShip.position.z))
    }
    
    private func updateCamera() {
        // Follow player with some offset and smoothing
        let targetPosition = SCNVector3(
            playerShip.position.x * 0.3,
            playerShip.position.y * 0.3 + 15,
            playerShip.position.z + 30
        )
        
        // Smooth camera movement
        cameraNode.position = SCNVector3(
            cameraNode.position.x + (targetPosition.x - cameraNode.position.x) * 0.1,
            cameraNode.position.y + (targetPosition.y - cameraNode.position.y) * 0.1,
            cameraNode.position.z + (targetPosition.z - cameraNode.position.z) * 0.1
        )
    }
    
    private func updateEnemies(deltaTime: TimeInterval) {
        for enemy in enemyShips {
            // Simple AI: move toward player
            let direction = SCNVector3(
                playerShip.position.x - enemy.position.x,
                playerShip.position.y - enemy.position.y,
                playerShip.position.z - enemy.position.z
            )
            
            let distance = sqrt(direction.x*direction.x + direction.y*direction.y + direction.z*direction.z)
            
            if distance > 0 {
                let normalizedDirection = SCNVector3(
                    direction.x / distance,
                    direction.y / distance,
                    direction.z / distance
                )
                
                let moveSpeed: Float = 5.0
                enemy.position = SCNVector3(
                    enemy.position.x + normalizedDirection.x * moveSpeed * Float(deltaTime),
                    enemy.position.y + normalizedDirection.y * moveSpeed * Float(deltaTime),
                    enemy.position.z + normalizedDirection.z * moveSpeed * Float(deltaTime)
                )
                
                // Look at player
                enemy.look(at: playerShip.position)
                
                // Fire occasionally
                if Int(CFAbsoluteTimeGetCurrent()) % 3 == 0 && distance < 20 {
                    fireEnemyBullet(from: enemy)
                }
            }
        }
    }
    
    private func updateBullets(deltaTime: TimeInterval) {
        bullets.removeAll { bullet in
            // Move bullets forward
            let speed: Float = bullet.name?.contains("enemy") == true ? 30 : 50
            let _ = bullet.worldTransform.m31 // Forward direction (unused)
            bullet.position = SCNVector3(
                bullet.position.x,
                bullet.position.y,
                bullet.position.z - speed * Float(deltaTime)
            )
            
            // Remove if too far
            if abs(bullet.position.z) > 100 {
                bullet.removeFromParentNode()
                return true
            }
            return false
        }
    }
    
    private func spawnEnemy() {
        let enemy = createEnemyShipNode()
        
        // Random spawn position around the arena
        let angle = Float.random(in: 0...(2 * Float.pi))
        let radius: Float = 40
        enemy.position = SCNVector3(
            cos(angle) * radius,
            Float.random(in: -10...10),
            sin(angle) * radius
        )
        
        enemy.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.bullet
        
        enemyShips.append(enemy)
        rootNode.addChildNode(enemy)
    }
    
    private func createEnemyShipNode() -> SCNNode {
        // Try to load the actual UFO model
        if let url = Bundle.main.url(forResource: "ufo_enemy", withExtension: "obj") {
            do {
                let scene = try SCNScene(url: url, options: nil)
                let enemyNode = SCNNode()
                
                // Add all child nodes from the loaded scene
                for child in scene.rootNode.childNodes {
                    enemyNode.addChildNode(child)
                }
                
                // Scale the model appropriately
                enemyNode.scale = SCNVector3(0.05, 0.05, 0.05)
                
                // Ensure materials are properly configured
                enemyNode.enumerateChildNodes { (node, stop) in
                    if let geometry = node.geometry {
                        for material in geometry.materials {
                            material.lightingModel = .physicallyBased
                            if material.diffuse.contents == nil {
                                material.diffuse.contents = UIColor.gray
                            }
                            material.metalness.contents = 0.8
                            material.roughness.contents = 0.2
                        }
                    }
                }
                
                // Add rotation
                let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 3)
                let repeatRotate = SCNAction.repeatForever(rotateAction)
                enemyNode.runAction(repeatRotate)
                
                return enemyNode
            } catch {
                print("Failed to load UFO model: \(error)")
            }
        }
        
        // Fallback to procedural UFO-style ship
        let enemyNode = SCNNode()
        
        // UFO-style saucer
        let saucerGeometry = SCNCylinder(radius: 2, height: 0.8)
        saucerGeometry.firstMaterial?.diffuse.contents = UIColor.gray
        saucerGeometry.firstMaterial?.metalness.contents = 0.9
        saucerGeometry.firstMaterial?.roughness.contents = 0.1
        let saucer = SCNNode(geometry: saucerGeometry)
        enemyNode.addChildNode(saucer)
        
        // Top dome
        let domeGeometry = SCNSphere(radius: 1)
        domeGeometry.firstMaterial?.diffuse.contents = UIColor.darkGray
        domeGeometry.firstMaterial?.transparency = 0.7
        let dome = SCNNode(geometry: domeGeometry)
        dome.position = SCNVector3(0, 0.8, 0)
        dome.scale = SCNVector3(1, 0.6, 1)
        enemyNode.addChildNode(dome)
        
        // Lights around the rim
        for i in 0..<8 {
            let angle = Float(i) * Float.pi / 4
            let lightGeometry = SCNSphere(radius: 0.1)
            lightGeometry.firstMaterial?.emission.contents = UIColor.red
            let light = SCNNode(geometry: lightGeometry)
            light.position = SCNVector3(cos(angle) * 1.8, 0, sin(angle) * 1.8)
            enemyNode.addChildNode(light)
        }
        
        // Add rotation
        let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 3)
        let repeatRotate = SCNAction.repeatForever(rotateAction)
        enemyNode.runAction(repeatRotate)
        
        return enemyNode
    }
    
    // MARK: - Input Handling
    func handleInput(keyCode: UInt16, isPressed: Bool) {
        switch keyCode {
        case 13: // W
            isMovingForward = isPressed
        case 1: // S
            isMovingBackward = isPressed
        case 0: // A
            isMovingLeft = isPressed
        case 2: // D
            isMovingRight = isPressed
        case 12: // Q
            isMovingUp = isPressed
        case 14: // E
            isMovingDown = isPressed
        case 49: // Space
            if isPressed { fireBullet() }
        default:
            break
        }
    }
    
    private func fireBullet() {
        let bullet = createBulletNode()
        bullet.position = playerShip.position
        bullet.eulerAngles = playerShip.eulerAngles
        
        bullet.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        
        bullets.append(bullet)
        rootNode.addChildNode(bullet)
        
        // Add muzzle flash effect
        let flash = SCNParticleSystem()
        flash.particleLifeSpan = 0.2
        flash.birthRate = 100
        flash.particleColor = UIColor.cyan
        flash.particleSize = 0.5
        playerShip.addParticleSystem(flash)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.playerShip.removeParticleSystem(flash)
        }
    }
    
    private func fireEnemyBullet(from enemy: SCNNode) {
        let bullet = createEnemyBulletNode()
        bullet.position = enemy.position
        bullet.look(at: playerShip.position)
        bullet.name = "enemy_bullet"
        
        bullet.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.enemyBullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        bullets.append(bullet)
        rootNode.addChildNode(bullet)
    }
    
    private func createBulletNode() -> SCNNode {
        let bulletGeometry = SCNCylinder(radius: 0.05, height: 1)
        bulletGeometry.firstMaterial?.emission.contents = UIColor.cyan
        let bullet = SCNNode(geometry: bulletGeometry)
        bullet.eulerAngles = SCNVector3(CGFloat.pi/2, 0, 0)
        return bullet
    }
    
    private func createEnemyBulletNode() -> SCNNode {
        let bulletGeometry = SCNSphere(radius: 0.1)
        bulletGeometry.firstMaterial?.emission.contents = UIColor.red
        return SCNNode(geometry: bulletGeometry)
    }
}