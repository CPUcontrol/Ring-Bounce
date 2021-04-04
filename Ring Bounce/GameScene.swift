//
//  GameScene.swift
//  Ring Bounce
//
//  Created by Eric Pu Jing on 1/6/17.
//  Copyright © 2017 CPUcontrol. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Ball   : UInt32 = 0b1       // 1
        static let Block: UInt32 = 0b10      // 2
        static let Paddle: UInt32 = 0b100
    }
    
    private var touchStart: CGPoint = CGPoint()
    
    let ringCenter = SKNode()
    let blockLayer = SKNode()
    let startText = SKLabelNode(fontNamed: "Helvetica")
    let highScore = SKLabelNode(fontNamed: "Helvetica")
    
    let ball = SKShapeNode(circleOfRadius: 10.0)
    let paddle = SKShapeNode(rectOf: CGSize(width: 10, height: 200))
    
    var blocksDodged = 0
    var framesSinceSpawn = 0
    var gameStarted = false
    var isOver = false
    var viewController: GameViewController!
    
    override func didMove(to view: SKView) {
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "High Score") == nil{
            defaults.set(0, forKey: "High Score")
            defaults.synchronize()
        }
        
        backgroundColor = UIColor.white
        
        startText.text = "Touch to start"
        startText.fontSize = 40
        startText.fontColor = SKColor.black
        startText.position = CGPoint(x: 0, y: 175)
        addChild(startText)
        
        let storedScore = defaults.object(forKey: "High Score")! as! Int
        
        highScore.text = "High Score: " + storedScore.description
        highScore.fontSize = 20
        highScore.fontColor = SKColor.black
        highScore.position = CGPoint(x: 0, y: -100)
        addChild(highScore)
        
        ball.fillColor = UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)
        ball.strokeColor = UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)
        paddle.fillColor = UIColor.darkGray
        paddle.strokeColor = UIColor.darkGray
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10.0)
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.restitution = 1.005
        
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Block
        
        paddle.position = CGPoint(x: 150, y: 0)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 200))
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.restitution = 1.005
        paddle.physicsBody?.categoryBitMask = PhysicsCategory.Paddle
        paddle.physicsBody?.contactTestBitMask = PhysicsCategory.None
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.Block
        physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        
        physicsWorld.gravity = CGVector(dx:0,dy:0)
        physicsWorld.contactDelegate = self
        
        ringCenter.addChild(paddle)
        
        let ring = SKShapeNode(circleOfRadius: 150.0)
        ring.strokeColor = UIColor(white: 0.8, alpha: 1.0)
        ring.fillColor = UIColor.clear
        ring.lineWidth = 10
        
        addChild(ring)
        addChild(blockLayer)
        addChild(ringCenter)
        addChild(ball)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask & PhysicsCategory.Ball != 0 &&
            secondBody.categoryBitMask & PhysicsCategory.Block != 0{
            isOver = true
            blockLayer.removeAllChildren()
            ringCenter.removeAllChildren()
            ball.physicsBody = nil
            ball.run(SKAction.group([
                SKAction.scale(by: 20.0, duration: TimeInterval(1.0)),
                SKAction.fadeOut(withDuration: TimeInterval(1.0))
                ]), completion: gameOver)

        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        if gameStarted == false{
            gameStarted = true
            ball.physicsBody?.velocity = (CGVector(dx: 275.0, dy: 0.0))
            startText.removeFromParent()
            highScore.removeFromParent()
        }
        
        touchStart = touch.location(in: self)
        ringCenter.zRotation = pointToAngle(point: touchStart)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        touchStart = touch.location(in: self)
        ringCenter.zRotation = pointToAngle(point: touchStart)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameStarted == false || isOver == true{
            return
        }
        
        if framesSinceSpawn > 60 + 360 / (blocksDodged + 3){
            spawnBlock()
            framesSinceSpawn = 0
        }
        else {
            framesSinceSpawn += 1
        }
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func spawnBlock(){
        
        let blockSize = CGSize(width: 40, height: 40)
        let block = SKShapeNode(rectOf: blockSize)
        
        block.position = CGPoint(x: random(min: -size.width / 4, max: size.width / 4), y: size.height / 2 + 40)
        block.fillColor = UIColor.red
        block.strokeColor = UIColor.red
        
        block.physicsBody = SKPhysicsBody(rectangleOf: blockSize)
        block.physicsBody?.isDynamic = false
        block.physicsBody?.categoryBitMask = PhysicsCategory.Block
        block.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        blockLayer.addChild(block)
        
        
        block.run(SKAction.sequence([
            SKAction.moveTo(y: CGFloat(-size.height / 2 - 40), duration: TimeInterval(random(min: 5, max: 8))),
            SKAction.run {
                self.blocksDodged += 1
            },
            SKAction.removeFromParent()
            ]))
    }
    
    func gameOver(){
        run(
        SKAction.run() {
            
            let reveal = SKTransition.fade(with: UIColor.white, duration: TimeInterval(1.0))
            let scene = GameOverScene(size: self.size, score: self.blocksDodged)
            scene.viewController = self.viewController
            self.view?.presentScene(scene, transition:reveal)
        }
        )
    }
    
    func pointToAngle(point: CGPoint)->CGFloat{
        if point.x == 0 && point.y == 0{
            return 0
        }
        else if point.x == 0 && point.y > 0{
            return CGFloat(M_PI_2)
        }
        else if point.x == 0 && point.y < 0{
            return CGFloat(3 * M_PI_2)
        }
        else{
            var res = atan(point.y / point.x)
            
            if point.x < 0{
                res += CGFloat(M_PI)
            }
            
            return res
        }
        
        
    }
}
