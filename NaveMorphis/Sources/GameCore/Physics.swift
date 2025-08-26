import SpriteKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let enemy: UInt32 = 1 << 1
    static let laserPlayer: UInt32 = 1 << 2
    static let laserEnemy: UInt32 = 1 << 3
    static let mothership: UInt32 = 1 << 4
    static let powerUp: UInt32 = 1 << 5
    static let shield: UInt32 = 1 << 6
    static let boundary: UInt32 = 1 << 7
    static let all: UInt32 = UInt32.max
}

class PhysicsHelper {
    static func configureBody(for node: SKPhysicsBody, category: UInt32, contact: UInt32, collision: UInt32) {
        node.categoryBitMask = category
        node.contactTestBitMask = contact
        node.collisionBitMask = collision
        node.affectedByGravity = false
        node.allowsRotation = false
    }
    
    static func createCircleBody(radius: CGFloat) -> SKPhysicsBody {
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.affectedByGravity = false
        body.allowsRotation = false
        return body
    }
    
    static func createRectangleBody(size: CGSize) -> SKPhysicsBody {
        let body = SKPhysicsBody(rectangleOf: size)
        body.affectedByGravity = false
        body.allowsRotation = false
        return body
    }
    
    static func createTextureBody(texture: SKTexture, size: CGSize) -> SKPhysicsBody {
        let body = SKPhysicsBody(texture: texture, size: size)
        body.affectedByGravity = false
        body.allowsRotation = false
        return body
    }
}