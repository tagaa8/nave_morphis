import SceneKit

extension Game3DScene: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        // Player bullet hits enemy
        if (nodeA.physicsBody?.categoryBitMask == PhysicsCategory.bullet && 
            nodeB.physicsBody?.categoryBitMask == PhysicsCategory.enemy) ||
           (nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy && 
            nodeB.physicsBody?.categoryBitMask == PhysicsCategory.bullet) {
            
            let bullet = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.bullet ? nodeA : nodeB
            let enemy = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy ? nodeA : nodeB
            
            handleBulletHitEnemy(bullet: bullet, enemy: enemy)
        }
        
        // Enemy bullet hits player
        else if (nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemyBullet && 
                 nodeB.physicsBody?.categoryBitMask == PhysicsCategory.player) ||
                (nodeA.physicsBody?.categoryBitMask == PhysicsCategory.player && 
                 nodeB.physicsBody?.categoryBitMask == PhysicsCategory.enemyBullet) {
            
            let bullet = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemyBullet ? nodeA : nodeB
            
            handleEnemyBulletHitPlayer(bullet: bullet)
        }
        
        // Enemy hits player
        else if (nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy && 
                 nodeB.physicsBody?.categoryBitMask == PhysicsCategory.player) ||
                (nodeA.physicsBody?.categoryBitMask == PhysicsCategory.player && 
                 nodeB.physicsBody?.categoryBitMask == PhysicsCategory.enemy) {
            
            let enemy = nodeA.physicsBody?.categoryBitMask == PhysicsCategory.enemy ? nodeA : nodeB
            
            handleEnemyHitPlayer(enemy: enemy)
        }
    }
    
    private func handleBulletHitEnemy(bullet: SCNNode, enemy: SCNNode) {
        // Remove bullet
        bullet.removeFromParentNode()
        if let index = bullets.firstIndex(of: bullet) {
            bullets.remove(at: index)
        }
        
        // Create explosion at enemy position
        createExplosion(at: enemy.position, color: UIColor.orange, size: 3.0)
        
        // Remove enemy
        enemy.removeFromParentNode()
        if let index = enemyShips.firstIndex(of: enemy) {
            enemyShips.remove(at: index)
        }
        
        // Update score
        score += 100
        
        // Play explosion sound effect (placeholder)
        playSound("explosion")
        
        // Add screen shake effect
        addScreenShake()
    }
    
    private func handleEnemyBulletHitPlayer(bullet: SCNNode) {
        // Remove bullet
        bullet.removeFromParentNode()
        if let index = bullets.firstIndex(of: bullet) {
            bullets.remove(at: index)
        }
        
        // Create explosion at player position
        createExplosion(at: playerShip.position, color: UIColor.cyan, size: 2.0)
        
        // Damage player
        takeDamage()
        
        // Play damage sound
        playSound("damage")
        
        // Add strong screen shake
        addScreenShake(intensity: 2.0)
    }
    
    private func handleEnemyHitPlayer(enemy: SCNNode) {
        // Create explosion at collision point
        let midPoint = SCNVector3(
            (enemy.position.x + playerShip.position.x) / 2,
            (enemy.position.y + playerShip.position.y) / 2,
            (enemy.position.z + playerShip.position.z) / 2
        )
        createExplosion(at: midPoint, color: UIColor.red, size: 4.0)
        
        // Remove enemy
        enemy.removeFromParentNode()
        if let index = enemyShips.firstIndex(of: enemy) {
            enemyShips.remove(at: index)
        }
        
        // Heavy damage to player
        takeDamage(amount: 2)
        
        // Play collision sound
        playSound("collision")
        
        // Strong screen shake
        addScreenShake(intensity: 3.0)
    }
    
    private func createExplosion(at position: SCNVector3, color: UIColor, size: Float) {
        let explosion = SCNParticleSystem()
        explosion.particleLifeSpan = 2.0
        explosion.birthRate = 300
        explosion.particleColor = color
        explosion.particleSize = size
        explosion.particleSizeVariation = size * 0.5
        explosion.particleVelocity = 20
        explosion.particleVelocityVariation = 15
        explosion.spreadingAngle = 180
        explosion.emissionDuration = 0.2
        
        // Create temporary node for explosion
        let explosionNode = SCNNode()
        explosionNode.position = position
        explosionNode.addParticleSystem(explosion)
        rootNode.addChildNode(explosionNode)
        
        // Remove explosion node after particles finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            explosionNode.removeFromParentNode()
        }
        
        // Add flash effect
        let flashLight = SCNNode()
        flashLight.light = SCNLight()
        flashLight.light?.type = .omni
        flashLight.light?.color = color
        flashLight.light?.intensity = 2000
        flashLight.position = position
        rootNode.addChildNode(flashLight)
        
        // Fade out flash
        let fadeAction = SCNAction.fadeOpacity(to: 0, duration: 0.5)
        flashLight.runAction(fadeAction) {
            flashLight.removeFromParentNode()
        }
    }
    
    private func takeDamage(amount: Int = 1) {
        lives -= amount
        
        // Player flash effect
        let flashAction = SCNAction.sequence([
            SCNAction.fadeOpacity(to: 0.3, duration: 0.1),
            SCNAction.fadeOpacity(to: 1.0, duration: 0.1)
        ])
        playerShip.runAction(SCNAction.repeat(flashAction, count: 3))
        
        if lives <= 0 {
            gameOver()
        }
    }
    
    private func gameOver() {
        gameState = .gameOver
        
        // Stop all enemy movement and remove them
        for enemy in enemyShips {
            enemy.removeAllActions()
            enemy.removeFromParentNode()
        }
        enemyShips.removeAll()
        
        // Stop all bullets
        for bullet in bullets {
            bullet.removeFromParentNode()
        }
        bullets.removeAll()
        
        // Player explosion
        createExplosion(at: playerShip.position, color: UIColor.yellow, size: 5.0)
        
        // Hide player ship
        playerShip.opacity = 0
        
        // Show game over UI (to be implemented)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showGameOverScreen()
        }
    }
    
    private func showGameOverScreen() {
        // This would be implemented to show a game over overlay
        // For now, just restart the game
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.restartGame()
        }
    }
    
    private func restartGame() {
        // Reset game state
        gameState = .playing
        score = 0
        lives = 3
        wave = 1
        
        // Reset player
        playerShip.opacity = 1.0
        playerShip.position = SCNVector3(0, 0, 10)
        
        // Clear any remaining objects
        enemyShips.forEach { $0.removeFromParentNode() }
        enemyShips.removeAll()
        bullets.forEach { $0.removeFromParentNode() }
        bullets.removeAll()
    }
    
    private func addScreenShake(intensity: Float = 1.0) {
        guard let sceneView = self.sceneView else { return }
        
        let shakeAmount: Float = 0.5 * intensity
        let shakeDuration: TimeInterval = 0.3
        
        let originalTransform = cameraNode.transform
        
        let shakeAction = SCNAction.sequence([
            SCNAction.moveBy(x: CGFloat(Float.random(in: -shakeAmount...shakeAmount)),
                           y: CGFloat(Float.random(in: -shakeAmount...shakeAmount)),
                           z: 0, duration: 0.05),
            SCNAction.moveBy(x: CGFloat(Float.random(in: -shakeAmount...shakeAmount)),
                           y: CGFloat(Float.random(in: -shakeAmount...shakeAmount)),
                           z: 0, duration: 0.05),
            SCNAction.moveBy(x: CGFloat(Float.random(in: -shakeAmount...shakeAmount)),
                           y: CGFloat(Float.random(in: -shakeAmount...shakeAmount)),
                           z: 0, duration: 0.05)
        ])
        
        cameraNode.runAction(shakeAction) {
            // Restore original position
            self.cameraNode.transform = originalTransform
        }
    }
    
    private func playSound(_ soundName: String) {
        // Placeholder for 3D positional audio
        // In a full implementation, you would use AVAudioEngine for 3D audio
        print("Playing sound: \(soundName)")
    }
}