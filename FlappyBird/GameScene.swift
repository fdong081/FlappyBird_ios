//
//  GameScene.swift
//  FlappyBird
//
//  Created by Dong fenfang on 8/11/18.
//  Copyright © 2018 Dong fenfang. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCatagory {
    static let Ghost : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Ghost = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    var gameStarts = Bool()
    var score = Int()
    let scoreLbl = SKLabelNode()
    var collision = Bool()
    var restartBtn = SKSpriteNode()
    
    func restartScene(){
        
        self.removeAllChildren()
        self.removeAllActions()
        
        gameStarts = false
        collision = false
        score = 0
        createScene()
        
    }
    
    func createScene(){
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2{
            let background = SKSpriteNode(imageNamed: "Background")
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = self.frame.size;
            self.addChild(background)
            
        }
        
        
        scoreLbl.position = CGPoint(x: 0, y: self.frame.height / 3 )
        scoreLbl.fontName = "FlappyBirdy"
        scoreLbl.fontSize = 100
        scoreLbl.text = "Score: "+"\(score)"
        scoreLbl.zPosition = 4
        self.addChild(scoreLbl)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(1.5)
        Ground.position = CGPoint(x:0, y: 0 - self.frame.height / 2 + Ground.frame.height / 2)
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCatagory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        Ground.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        Ground.zPosition = 3
        
        Ghost = SKSpriteNode(imageNamed: "Ghost")
        Ghost.size = CGSize(width: 100, height: 120)
        Ghost.position = CGPoint(x: 0 - Ghost.frame.width, y: 0)
        Ghost.physicsBody = SKPhysicsBody(circleOfRadius: Ghost.frame.height / 2)
        Ghost.physicsBody?.categoryBitMask = PhysicsCatagory.Ghost
        Ghost.physicsBody?.collisionBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall
        Ghost.physicsBody?.contactTestBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall | PhysicsCatagory.Score
        Ghost.physicsBody?.affectedByGravity = false
        Ghost.physicsBody?.isDynamic = true
        Ghost.zPosition = 2
        self.addChild(Ground)
        self.addChild(Ghost)
    }
    override func didMove(to view: SKView) {
        createScene()
    }
    func createBtn(){
        restartBtn = SKSpriteNode(imageNamed: "RestartBtn")
        restartBtn.position = CGPoint(x: 0, y: 0)
        restartBtn.zPosition = 5
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.7))
    }
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        if firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.Ghost{
            score += 1
            scoreLbl.text = "Score: "+"\(score)"
            firstBody.node?.removeFromParent()
        }
        else if firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Score {
            score += 1
            scoreLbl.text = "Score: "+"\(score)"
            secondBody.node?.removeFromParent()
        }
        else if firstBody.categoryBitMask ==  PhysicsCatagory.Wall && secondBody.categoryBitMask == PhysicsCatagory.Ghost || firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Wall{
            
            enumerateChildNodes(withName: "wallPair", using:{
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            })
            if collision == false{
                collision = true
                createBtn()
            }
   
         }
        else if firstBody.categoryBitMask ==  PhysicsCatagory.Ground && secondBody.categoryBitMask == PhysicsCatagory.Ghost || firstBody.categoryBitMask == PhysicsCatagory.Ghost && secondBody.categoryBitMask == PhysicsCatagory.Ground{
            
            enumerateChildNodes(withName: "wallPair", using:{
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            })
            if collision == false{
                collision = true
                createBtn()
            }
            
        }
        
    }
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarts == false{
            gameStarts = true
            Ghost.physicsBody?.affectedByGravity = true
            let spawn = SKAction.run({
                () in
                
                self.createWalls()
                
            })
            let delay = SKAction.wait(forDuration: TimeInterval(3))
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width )
            let movePipes = SKAction.moveBy(x: -distance, y: 0.0, duration: TimeInterval(0.01 * distance))
            
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
        }
        else{
            if collision == false{
                Ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                Ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
            }
        }
        
        for touch in touches{
            let location = touch.location(in: self)
            if collision == true{
                if restartBtn.contains(location){
                    restartScene()
                }
            }
        }
       
    }
    func createWalls(){
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.setScale(0.7)
        bottomWall.setScale(0.7)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCatagory.Ghost
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.isDynamic = false
        
        topWall.zRotation = CGFloat(Double.pi)
       
        topWall.position = CGPoint(x: self.frame.width / 2 + wallPair.frame.width / 2, y: self.frame.height / 2 - 170)
        bottomWall.position = CGPoint(x: self.frame.width / 2 + wallPair.frame.width / 2, y: 0 - self.frame.height / 2 + 170)
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.zPosition = 1
        
        var randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        scoreNode.position = CGPoint(x: self.frame.width / 2 + wallPair.frame.width / 2, y: 0 )
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.Ghost
        
        wallPair.addChild(scoreNode)
        wallPair.run(moveAndRemove)
        self.addChild(wallPair)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameStarts == true{
            if collision == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    var bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 20, y: bg.position.y)
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x: bg.position.x + 2 * self.frame.width, y: bg.position.y)
                    }
                }))
            }
        }
    }
}
