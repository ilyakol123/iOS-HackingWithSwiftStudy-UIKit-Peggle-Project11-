//
//  GameScene.swift
//  Peggle(Project11)
//
//  Created by Илья Колесников on 21.02.2025.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    let ballsColors: [String] = ["Blue", "Cyan", "Green", "Grey", "Purple", "Red", "Yellow"]
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var availableBalls: Int = 5 {
        didSet {
            availableBallsLabel.text = "Balls: \(availableBalls)"
            
            if availableBalls == 0 {
                addChild(restartLabel)
            }
            if availableBalls > 0 {
                    restartLabel.removeFromParent()
            }
            
        }
    }
    
    var editLabel: SKLabelNode!
    
    var availableBallsLabel: SKLabelNode!
    
    var restartLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scaleMode = .aspectFit
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        physicsWorld.contactDelegate = self
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        availableBallsLabel = SKLabelNode(fontNamed: "Chalkduster")
        availableBallsLabel.text = "Balls: 5"
        availableBallsLabel.position = CGPoint(x: 512, y: 700)
        addChild(availableBallsLabel)
        
        restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.text = "Restart"
        restartLabel.position = CGPoint(x: 700, y: 700)
        
            
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            if objects.contains(editLabel) {
                editingMode.toggle()
            } else if objects.contains(restartLabel) {
                availableBalls = 5
                score = 0
                restartLabel.removeFromParent()
            } else {
                
                if editingMode {
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    box.name = "box"
                    
                    addChild(box)
                    
                } else {
                    if availableBalls > 0 {
                        let ballColor = "ball\(ballsColors[Int.random(in: 0...ballsColors.count - 1)])"
                        let ball = SKSpriteNode(imageNamed: ballColor)
                        
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                        ball.physicsBody?.restitution = 0.4
                        ball.position = CGPoint(x: location.x, y: 700)
                        ball.name = "ball"
                        
                        if let magicParticles = SKEmitterNode(fileNamed: "MagicParticle") {
                            magicParticles.position = ball.position
                            addChild(magicParticles)
                        }
                        addChild(ball)
                        availableBalls -= 1
                    }
                    
                }
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroyBall(ball)
            score += 1
            availableBalls += 1
        } else if object.name == "bad" {
            destroyBall(ball)
            score -= 1
        } else if object.name == "box" {
            destroyBox(object)
        }
    }
    
    func destroyBall(_ ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func destroyBox(_ box: SKNode) {
        box.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" && nodeB.name != "box" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" && nodeA.name != "box" {
            collisionBetween(ball: nodeB, object: nodeA)
        } else if nodeA.name == "ball" && nodeB.name == "box" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" && nodeA.name == "box" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
}
