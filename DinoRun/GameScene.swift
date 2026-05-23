//
//  GameScene.swift
//  DinoRun
//
//  Created by test on 2026/5/16.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameData: GameData?
    
    private var dino: SKSpriteNode!
    private var moon: SKSpriteNode!
    private var groundNodes: [SKSpriteNode] = []
    private var isJumping = false
    private var lastUpdateTime: TimeInterval = 0
    private var scoreTimer: TimeInterval = 0
    private var obstacleTimer: TimeInterval = 0
    private var cloudTimer: TimeInterval = 0
    
    private let groundY: CGFloat = 140
    private let dinoStartX: CGFloat = 180
    private let obstacleTypes = ["cactus1", "cactus2", "cactus3", "doubleCactus", "tripleCactus", "flyer"]
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -35)
        self.physicsWorld.contactDelegate = self
        
        let floorBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: groundY), to: CGPoint(x: size.width, y: groundY))
        floorBody.categoryBitMask = 4
        floorBody.collisionBitMask = 1
        self.physicsBody = floorBody
        
        moon = SKSpriteNode(imageNamed: "moon")
        moon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        moon.position = CGPoint(x: size.width * 0.8, y: size.height + moon.size.height)
        moon.zPosition = 0
        addChild(moon)
        
        for i in 0..<2 {
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.anchorPoint = CGPoint(x: 0, y: 0)
            ground.position = CGPoint(x: CGFloat(i) * size.width, y: groundY - ground.size.height)
            ground.zPosition = 1
            addChild(ground)
            groundNodes.append(ground)
        }
        
        dino = SKSpriteNode(imageNamed: "dinoLeft")
        dino.anchorPoint = CGPoint(x: 0.5, y: 0)
        dino.position = CGPoint(x: dinoStartX, y: groundY)
        dino.zPosition = 2
        dino.setScale(1.6)
        
        let dinoBodySize = CGSize(width: dino.size.width * 0.6, height: dino.size.height * 0.85)
        dino.physicsBody = SKPhysicsBody(rectangleOf: dinoBodySize, center: CGPoint(x: 0, y: dino.size.height / 2))
        dino.physicsBody?.isDynamic = true
        dino.physicsBody?.allowsRotation = false
        dino.physicsBody?.categoryBitMask = 1
        dino.physicsBody?.collisionBitMask = 4
        dino.physicsBody?.contactTestBitMask = 2
        addChild(dino)
        
        let runAnimation = SKAction.animate(with: [SKTexture(imageNamed: "dinoLeft"), SKTexture(imageNamed: "dinoRight")], timePerFrame: 0.12)
        dino.run(SKAction.repeatForever(runAnimation), withKey: "run")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gd = gameData, gd.currentHP > 0 else { return }
        if !isJumping {
            dino.removeAction(forKey: "run")
            dino.physicsBody?.velocity = CGVector(dx: 0, dy: 950)
            isJumping = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let gd = gameData, gd.currentHP > 0 else { return }
        if let view = self.view, view.isPaused { return }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        let isNight = (gd.currentScore / 100) % 2 == 1
        let targetBgColor = isNight ? UIColor(white: 0.15, alpha: 1.0) : UIColor(white: 0.98, alpha: 1.0)
        self.backgroundColor = targetBgColor
        
        let targetMoonY = isNight ? size.height * 0.75 : size.height + moon.size.height
        moon.position.y += (targetMoonY - moon.position.y) * 0.1
        
        for ground in groundNodes {
            ground.position.x -= 420 * CGFloat(deltaTime)
            if ground.position.x <= -size.width {
                ground.position.x += size.width * 2 - 1
            }
        }
        
        if isJumping {
            if let body = dino.physicsBody, body.velocity.dy <= 0.1, dino.position.y <= groundY + 8 {
                isJumping = false
                let runAnimation = SKAction.animate(with: [SKTexture(imageNamed: "dinoLeft"), SKTexture(imageNamed: "dinoRight")], timePerFrame: 0.12)
                dino.run(SKAction.repeatForever(runAnimation), withKey: "run")
            }
        }
        
        scoreTimer += deltaTime
        if scoreTimer >= 0.15 {
            scoreTimer = 0
            gd.currentScore += 1
        }
        
        obstacleTimer += deltaTime
        if obstacleTimer >= 1.8 {
            obstacleTimer = 0
            spawnObstacle()
        }
        
        cloudTimer += deltaTime
        if cloudTimer >= 3.5 {
            cloudTimer = 0
            spawnCloud()
        }
    }
    
    private func spawnObstacle() {
        let type = obstacleTypes.randomElement() ?? "cactus1"
        let obstacle = SKSpriteNode(imageNamed: type == "flyer" ? "flyer1" : type)
        obstacle.anchorPoint = CGPoint(x: 0.5, y: 0)
        obstacle.zPosition = 2
        
        if type == "flyer" {
            let flyerHeights: [CGFloat] = [groundY + 10, groundY + 80, groundY + 160]
            obstacle.position = CGPoint(x: size.width + obstacle.size.width, y: flyerHeights.randomElement() ?? groundY + 80)
            let flyerAnim = SKAction.animate(with: [SKTexture(imageNamed: "flyer1"), SKTexture(imageNamed: "flyer2")], timePerFrame: 0.15)
            obstacle.run(SKAction.repeatForever(flyerAnim))
        } else {
            obstacle.position = CGPoint(x: size.width + obstacle.size.width, y: groundY)
        }
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size, center: CGPoint(x: 0, y: obstacle.size.height / 2))
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = 2
        obstacle.physicsBody?.collisionBitMask = 0
        obstacle.physicsBody?.contactTestBitMask = 1
        addChild(obstacle)
        
        let moveLeft = SKAction.moveBy(x: -(size.width + obstacle.size.width * 2), y: 0, duration: 2.2)
        let remove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveLeft, remove]))
    }
    
    private func spawnCloud() {
        let cloud = SKSpriteNode(imageNamed: "cloud")
        cloud.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        cloud.position = CGPoint(x: size.width + cloud.size.width, y: CGFloat.random(in: 520...660))
        cloud.zPosition = 0
        addChild(cloud)
        
        let moveLeft = SKAction.moveBy(x: -(size.width + cloud.size.width * 2), y: 0, duration: 9.0)
        let remove = SKAction.removeFromParent()
        cloud.run(SKAction.sequence([moveLeft, remove]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let gd = gameData, gd.currentHP > 0 else { return }
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if mask == (1 | 2) {
            let obstacleNode = contact.bodyA.categoryBitMask == 2 ? contact.bodyA.node : contact.bodyB.node
            if obstacleNode?.parent != nil {
                obstacleNode?.removeFromParent()
                if gd.currentHP > 0 {
                    gd.currentHP -= 1
                }
            }
        }
    }
}
