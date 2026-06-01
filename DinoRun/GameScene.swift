import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameData: GameData?
    
    private var groundNode = SKNode()
    private var backgroundNode = SKNode()
    private var obstacleNode = SKNode()
    private var collectibleNode = SKNode()
    
    private var dino: SKSpriteNode!
    private var moon: SKSpriteNode!
    private var splatNode: SKSpriteNode?
    private var groundNodes: [SKSpriteNode] = []
    
    private var isJumping = false
    private var lastUpdateTime: TimeInterval = 0
    private var scoreTimer: TimeInterval = 0
    private var timeSinceLastSpawn: TimeInterval = 0
    private var cloudTimer: TimeInterval = 0
    private var spawnRate: TimeInterval = 1.5
    
    private var groundSpeed: CGFloat = 500.0
    private let cloudSpeed: CGFloat = 80.0
    private var groundWidth: CGFloat = 0
    
    private let groundY: CGFloat = 140
    private let dinoStartX: CGFloat = 180
    private let obstacleTypes = ["cactus1", "cactus2", "cactus3", "doubleCactus", "tripleCactus", "flyer"]
    
    private let groundCategory: UInt32 = 1 << 0
    private let dinoCategory: UInt32 = 1 << 1
    private let obstacleCategory: UInt32 = 1 << 2
    private let collectibleCategory: UInt32 = 1 << 3
    
    private var runAnimation: SKAction!
    private let jumpSound = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    private let dieSound = SKAction.playSoundFileNamed("die.wav", waitForCompletion: false)
    private let riseSound = SKAction.playSoundFileNamed("rise.wav", waitForCompletion: false)
    private let splatSound = SKAction.playSoundFileNamed("splat.wav", waitForCompletion: false)
    private let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    private let shootSound = SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false)
    
    private var isShoeActive = false
    private var shoeTimer: TimeInterval = 0
    private var isStickActive = false
    private var stickDistance: CGFloat = 0
    private var splatTimer: TimeInterval = 0
    
    private var skillButton: SKShapeNode?
    private var isSkillReady = true
    private var isShieldActive = false
    private var isLaserActive = false
    private var shieldEffect: SKSpriteNode?
    private var requiredJumpsForCD = 0
    private var currentJumpsSinceSkill = 0
    private var laserDistance: CGFloat = 0.0
    
    private var curSpeed: CGFloat = 1.0
    
    private let invertShader = SKShader(source: """
    void main() {
        vec4 color = SKDefaultShading();
        float brightness = (color.r + color.g + color.b) / 3.0;
        float newAlpha = (1.0 - brightness) * color.a;
        gl_FragColor = vec4(newAlpha, newAlpha, newAlpha, newAlpha);
    }
    """)
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.contactDelegate = self
        
        addChild(backgroundNode)
        addChild(groundNode)
        addChild(obstacleNode)
        addChild(collectibleNode)
        
        createGround()
        createMoon()
        createDino()
        
        if let eq = gameData?.equippedItem, eq != "None" {
            let btn = SKShapeNode(circleOfRadius: 45)
            btn.name = "skillButton"
            btn.fillColor = UIColor(red: 1.00, green: 0.70, blue: 0.00, alpha: 1.0)
            btn.strokeColor = .white
            btn.lineWidth = 4
            btn.glowWidth = 4
            btn.position = CGPoint(x: size.width - 100, y: size.height / 2)
            btn.zPosition = 100
            
            let icon = SKSpriteNode(imageNamed: eq.lowercased())
            icon.size = CGSize(width: 50, height: 50)
            btn.addChild(icon)
            
            addChild(btn)
            skillButton = btn
        }
        trackPlayingState()
    }
    
    func trackPlayingState() {
        guard let data = gameData else { return }

        withObservationTracking {
            let state = data.playingState
            
            if state == .paused {
                self.speed = 0.0
                self.physicsWorld.speed = 0.0
                self.isPaused = true
            } else if state == .starting {
                self.speed = curSpeed
                self.physicsWorld.speed = 1.0
                self.isPaused = false
            }
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                self?.trackPlayingState()
            }
        }
    }
    
    private func createGround() {
        let tex = SKTexture(imageNamed: "ground")
        tex.filteringMode = .nearest
        groundWidth = tex.size().width
        
        let floorBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: groundY), to: CGPoint(x: size.width * 2, y: groundY))
        floorBody.categoryBitMask = groundCategory
        floorBody.collisionBitMask = dinoCategory | obstacleCategory
        self.physicsBody = floorBody
        
        for i in 0..<3 {
            let ground = SKSpriteNode(texture: tex)
            ground.anchorPoint = CGPoint(x: 0, y: 0)
            ground.position = CGPoint(x: CGFloat(i) * groundWidth, y: groundY - tex.size().height + 35)
            ground.zPosition = 1
            groundNode.addChild(ground)
            groundNodes.append(ground)
        }
    }
    
    private func createMoon() {
        let tex = SKTexture(imageNamed: "moon")
        tex.filteringMode = .nearest
        moon = SKSpriteNode(texture: tex)
        moon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        moon.setScale(3.0)
        moon.position = CGPoint(x: size.width * 0.8, y: size.height + moon.size.height)
        moon.zPosition = 0
        backgroundNode.addChild(moon)
    }
    
    private func createDino() {
        let tex1 = SKTexture(imageNamed: "dinoLeft")
        let tex2 = SKTexture(imageNamed: "dinoRight")
        tex1.filteringMode = .nearest
        tex2.filteringMode = .nearest
        runAnimation = SKAction.animate(with: [tex1, tex2], timePerFrame: 0.12)
        
        dino = SKSpriteNode(texture: tex1)
        dino.anchorPoint = CGPoint(x: 0.5, y: 0)
        dino.position = CGPoint(x: dinoStartX, y: groundY)
        dino.zPosition = 2
        dino.setScale(4.0)
        
        let dinoBodySize = CGSize(width: dino.size.width * 0.6, height: dino.size.height * 0.85)
        dino.physicsBody = SKPhysicsBody(rectangleOf: dinoBodySize, center: CGPoint(x: 0, y: dino.size.height / 2))
        dino.physicsBody?.isDynamic = true
        dino.physicsBody?.allowsRotation = false
        dino.physicsBody?.mass = 1.0
        dino.physicsBody?.categoryBitMask = dinoCategory
        dino.physicsBody?.collisionBitMask = groundCategory
        dino.physicsBody?.contactTestBitMask = obstacleCategory
        addChild(dino)
        
        dino.run(SKAction.repeatForever(runAnimation), withKey: "run")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gd = gameData, gd.currentHP > 0 else { return }
        if self.isPaused { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            if let btn = skillButton, btn.contains(location) {
                if isSkillReady {
                    activateSkill(itemName: gd.equippedItem)
                }
                return
            }
        }
        
        if !isJumping {
            dino.removeAction(forKey: "run")
            dino.physicsBody?.velocity = CGVector(dx: 0, dy: 700)
            isJumping = true
//            run(jumpSound)
            if !isSkillReady {
                currentJumpsSinceSkill += 1
                if currentJumpsSinceSkill >= requiredJumpsForCD {
                    isSkillReady = true
                    skillButton?.alpha = 1.0
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let gd = gameData, gd.currentHP > 0 else { return }
        if let view = self.view, view.isPaused { return }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            timeSinceLastSpawn = currentTime
            return
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if gameData?.playingState == .paused { return }
        else if gameData?.playingState == .starting {
            gameData?.playingState = .playing
            return
        }
        
        
        if self.speed < 2.5 {
            curSpeed += 0.01 * CGFloat(deltaTime)
            self.speed = curSpeed
        }
        groundSpeed += 2.5 * CGFloat(deltaTime)
        
        if isShoeActive {
            shoeTimer -= deltaTime
            if shoeTimer <= 0 {
                isShoeActive = false
            }
        }

        if splatTimer > 0 {
            splatTimer -= deltaTime
            if splatTimer <= 0 {
                splatNode?.removeFromParent()
                splatTimer = 0
            }
        }

        let activeSpeed = isShoeActive ? groundSpeed * 1.5 : groundSpeed

        if isStickActive {
            stickDistance += activeSpeed * CGFloat(deltaTime)
            if stickDistance > gd.stickMaxDistance {
                isStickActive = false
            }
        }
        
        if isLaserActive {
            laserDistance += activeSpeed * CGFloat(deltaTime)
            if laserDistance > gd.laserMaxDistance {
                isLaserActive = false
            }
        }
        
        let isNight = (gd.currentScore / 100) % 2 == 1
        let targetBgColor = isNight ? UIColor(white: 0.15, alpha: 1.0) : UIColor(white: 0.98, alpha: 1.0)
        self.backgroundColor = targetBgColor
        
        let targetMoonY = isNight ? size.height * 0.75 : size.height + moon.size.height
        moon.position.y += (targetMoonY - moon.position.y) * 0.1
        
        for ground in groundNodes {
            ground.shader = isNight ? invertShader : nil
            ground.position.x -= activeSpeed * CGFloat(deltaTime)
        }
        
        let overlap: CGFloat = 1
        
        if groundNodes[0].position.x <= -groundWidth {
            groundNodes[0].position.x = groundNodes[2].position.x + groundWidth - overlap
        }
        if groundNodes[1].position.x <= -groundWidth {
            groundNodes[1].position.x = groundNodes[0].position.x + groundWidth - overlap
        }
        if groundNodes[2].position.x <= -groundWidth {
            groundNodes[2].position.x = groundNodes[1].position.x + groundWidth - overlap
        }
        
        for child in obstacleNode.children {
            child.position.x -= activeSpeed * CGFloat(deltaTime)
            if child.position.x < -150 {
                child.removeFromParent()
            }
        }
        
        for child in collectibleNode.children {
            child.position.x -= activeSpeed * CGFloat(deltaTime)
            if child.position.x < -150 {
                child.removeFromParent()
            }
        }
        
        for child in backgroundNode.children where child.name == "cloud" {
            child.position.x -= cloudSpeed * CGFloat(deltaTime)
            if child.position.x < -200 {
                child.removeFromParent()
            }
        }
        
        if isJumping {
            if let body = dino.physicsBody, body.velocity.dy <= 0.1, dino.position.y <= groundY + 8 {
                isJumping = false
                dino.run(SKAction.repeatForever(runAnimation), withKey: "run")
            }
        }
        
        scoreTimer += deltaTime
        if scoreTimer >= 0.15 {
            scoreTimer = 0
            gd.currentScore += 1
        }
        
        if currentTime - timeSinceLastSpawn > spawnRate {
            timeSinceLastSpawn = currentTime
            
            if isStickActive {
                spawnRate = Double.random(in: 0.4...0.8)
                spawnObstacle()
            } else {
                spawnRate = Double.random(in: 1.2...2.5)
                if Int.random(in: 1...10) <= 2 {
                    spawnCollectible(x: size.width + 50, type: "road", refY: groundY, refHeight: 0)
                } else {
                    spawnObstacle()
                }
            }
        }
        
        cloudTimer += deltaTime
        if cloudTimer >= 3.5 {
            cloudTimer = 0
            spawnCloud()
        }
    }
    
    private func spawnObstacle() {
        let type = obstacleTypes.randomElement() ?? "cactus1"
        let isFlyer = (type == "flyer")
        
        if isStickActive {
            let obsY: CGFloat
            let obsH: CGFloat
            if isFlyer {
                let flyerHeights: [CGFloat] = [groundY + 30, groundY + 130, groundY + 240]
                obsY = flyerHeights.randomElement() ?? groundY + 130
                obsH = 60
            } else {
                obsY = groundY + 40
                obsH = 100
            }
            
            if !isLaserActive {
                spawnCollectible(x: size.width + 50, type: "exact", refY: obsY, refHeight: 0)
            }
                
            if Int.random(in: 1...10) <= 5 {
                spawnCollectible(x: size.width + 50, type: isFlyer ? "flyer" : "cactus", refY: obsY, refHeight: obsH)
            }
            return
        }
        
        let texName = isFlyer ? "flyer1" : type
        let tex = SKTexture(imageNamed: texName)
        tex.filteringMode = .nearest
        let obstacle = SKSpriteNode(texture: tex)
        
        obstacle.anchorPoint = CGPoint(x: 0.5, y: 0)
        obstacle.zPosition = 2
        
        if isFlyer {
            obstacle.setScale(3.0)
            let tex2 = SKTexture(imageNamed: "flyer2")
            tex2.filteringMode = .nearest
            let flap = SKAction.animate(with: [tex, tex2], timePerFrame: 0.15)
            obstacle.run(SKAction.repeatForever(flap))

            let flyerHeights: [CGFloat] = [groundY + 30, groundY + 130, groundY + 240]
            obstacle.position = CGPoint(x: size.width + obstacle.size.width, y: flyerHeights.randomElement() ?? groundY + 130)
        } else {
            obstacle.setScale(3.0)
            obstacle.position = CGPoint(x: size.width + obstacle.size.width, y: groundY)
        }
        
        let contactBox = CGSize(width: obstacle.size.width * 0.7, height: obstacle.size.height * 0.8)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: contactBox, center: CGPoint(x: 0, y: obstacle.size.height / 2))
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.collisionBitMask = 0
        obstacle.physicsBody?.contactTestBitMask = dinoCategory
        
        if !isLaserActive {
            obstacleNode.addChild(obstacle)
        }
        if Int.random(in: 1...10) <= 5 {
            spawnCollectible(x: obstacle.position.x, type: isFlyer ? "flyer" : "cactus", refY: obstacle.position.y, refHeight: obstacle.size.height)
        }
    }
    
    private func spawnCloud() {
        let tex = SKTexture(imageNamed: "cloud")
        tex.filteringMode = .nearest
        let cloud = SKSpriteNode(texture: tex)
        cloud.name = "cloud"
        cloud.setScale(3.0)
        cloud.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        cloud.position = CGPoint(x: size.width + cloud.size.width, y: CGFloat.random(in: 500...650))
        cloud.zPosition = 0
        backgroundNode.addChild(cloud)
    }
    
    private func spawnCollectible(x: CGFloat, type: String, refY: CGFloat, refHeight: CGFloat) {
        let isCoin = Int.random(in: 1...10) <= 8 || isStickActive
        let texName = isCoin ? "coin1" : ["heart", "stick", "shoe", "splat1"].randomElement()!
        let tex = SKTexture(imageNamed: texName)
        tex.filteringMode = .nearest
        let collectible = SKSpriteNode(texture: tex)
        collectible.name = isCoin ? "coin" : texName
        if isCoin {
            collectible.setScale(2.5)
        }
        else {
            collectible.size = CGSize(width: 75, height: 75)
            if texName == "splat1" {
                collectible.color = [.black, .blue, .red].randomElement()!
                collectible.colorBlendFactor = 1.0
            }
        }
        
        
        var finalY = groundY
        if type == "road" {
            finalY = groundY + 30
        } else if type == "flyer" {
            if refY > groundY + 80 {
                finalY = groundY + 30
            } else {
                finalY = refY + refHeight + 40
            }
        } else if type == "exact" {
            finalY = refY
        } else {
            finalY = refY + refHeight + 40
        }
        
        collectible.position = CGPoint(x: x, y: finalY)
        collectible.zPosition = 2
        
        let contactBox = CGSize(width: collectible.size.width * 0.6, height: collectible.size.height * 0.6)
        collectible.physicsBody = SKPhysicsBody(rectangleOf: contactBox, center: CGPoint(x: 0, y: collectible.size.height / 2))
        collectible.physicsBody?.isDynamic = false
        collectible.physicsBody?.categoryBitMask = collectibleCategory
        collectible.physicsBody?.collisionBitMask = 0
        collectible.physicsBody?.contactTestBitMask = dinoCategory
        
        if isCoin {
            var textures: [SKTexture] = []
            for i in 1...8 {
                let t = SKTexture(imageNamed: "coin\(i)")
                t.filteringMode = .nearest
                textures.append(t)
            }
            collectible.run(SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.1)))
        }
        
        collectibleNode.addChild(collectible)
    }
    
    private func activateSkill(itemName: String) {
        guard let gd = gameData else { return }
        isSkillReady = false
        skillButton?.alpha = 0.3
        currentJumpsSinceSkill = 0
        
        if itemName == "Laser" {
            requiredJumpsForCD = gd.laserCDJumps
            isLaserActive = true
            let laserNode = SKSpriteNode(color: .cyan, size: CGSize(width: size.width, height: 30))
            laserNode.position = CGPoint(x: size.width / 2, y: dino.position.y + 30)
            laserNode.zPosition = 5
            addChild(laserNode)
            
            for child in obstacleNode.children {
                child.removeFromParent()
            }
            
            laserNode.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
            
        } else if itemName == "Shield" {
            requiredJumpsForCD = gd.shieldCDJumps
            isShieldActive = true
            let shieldTex = SKTexture(imageNamed: "shield_effect")
            shieldTex.filteringMode = .nearest
            shieldEffect = SKSpriteNode(texture: shieldTex)
            shieldEffect?.size = CGSize(width: 75, height: 75)
            shieldEffect?.zPosition = 3
            dino.addChild(shieldEffect!)
            
            let wait = SKAction.wait(forDuration: gd.shieldDuration)
            let endShield = SKAction.run {
                self.isShieldActive = false
                self.shieldEffect?.removeFromParent()
            }
            run(SKAction.sequence([wait, endShield]))
        }
    }
    
    private func applyItemEffect(itemName: String, itemColor: UIColor) {
        guard let gd = gameData else { return }
        
        switch itemName {
        case "heart":
            if gd.currentHP < gd.maxHP {
                gd.currentHP += 1
            }
        case "shoe":
            isShoeActive = true
            shoeTimer = gd.shoeDuration
        case "splat1":
            splatNode?.removeFromParent()
            let randomSplat = "splat\(Int.random(in: 1...4))"
            let tex = SKTexture(imageNamed: randomSplat)
            tex.filteringMode = .nearest
            let node = SKSpriteNode(texture: tex)
            node.zPosition = 100
            node.position = CGPoint(x: size.width / 2, y: size.height / 2)
            let targetHeight = size.height * 1.1
            let calculatedScale = targetHeight / tex.size().height
            node.setScale(calculatedScale)
            node.color = itemColor
            node.colorBlendFactor = 1.0
            splatNode = node
            addChild(node)
            splatTimer = gd.splatDuration
        case "stick":
            isStickActive = true
            stickDistance = 0
        default:
            break
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let gd = gameData, gd.currentHP > 0 else { return }
        
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if mask == (dinoCategory | obstacleCategory) {
            let obstacle = contact.bodyA.categoryBitMask == obstacleCategory ? contact.bodyA.node : contact.bodyB.node
            if obstacle?.parent != nil {
                obstacle?.removeFromParent()
                if !isShieldActive {
//                    run(dieSound)
                    if gd.currentHP > 0 {
                        gd.currentHP -= 1
                    }
                }
            }
        } else if mask == (dinoCategory | collectibleCategory) {
            let collectible = contact.bodyA.categoryBitMask == collectibleCategory ? contact.bodyA.node : contact.bodyB.node
            if collectible?.parent != nil {
                let itemName = collectible?.name ?? ""
                
                if itemName == "coin" {
                    gd.coins += isShoeActive ? 2 : 1
                } else {
                    if let itemColor = (collectible as? SKSpriteNode)?.color {
                        applyItemEffect(itemName: itemName, itemColor: itemColor)
                    } else {
                        applyItemEffect(itemName: itemName, itemColor: .black)
                    }
                }
                collectible?.removeFromParent()
            }
        }
    }
}
