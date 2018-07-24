//
//  GameScene.swift
//  GroebeBallGame
//
//  Created by Sean Groebe on 5/22/18.
//  Copyright © 2018 DePaul University. All rights reserved.
//

import SpriteKit
import CoreMotion

// Used to determine what the type of the object is. Certain obejcts are bad, certain are good.
enum CollisionTypes: UInt32 {
	case player = 1
	case finish = 2
	case star = 4
	case wall = 8
	case skull = 16
}
class GameScene: SKScene, SKPhysicsContactDelegate {

	var motionManager = CMMotionManager()
	var lastTouchPosition: CGPoint?
	var isGameOver = false
	var scoreLabel: SKLabelNode!
	var livesLabel: SKLabelNode!

	
	var player = SKSpriteNode()
	var finish = SKSpriteNode()
	var playerLives = 5 {
		didSet {
			livesLabel.text = "Lives: \(playerLives)"
		}
	}
	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		
		}
	}
    
    override func didMove(to view: SKView) {

		// creates score label to update with game progress
		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.text = "Score: 0"
		scoreLabel.horizontalAlignmentMode = .left
		scoreLabel.position = CGPoint(x: 16, y: 16)
		addChild(scoreLabel)
		
		//indicates how many lives are remaining for player
		livesLabel = SKLabelNode(fontNamed: "Chalkduster")
		livesLabel.position = CGPoint(x: 100, y: 100)
		addChild(livesLabel)

		createStar()
		createSkull()
		createFinishLine()
		createPlayer()
		
		motionManager.startAccelerometerUpdates()
		motionManager.accelerometerUpdateInterval = 0.1
		
		motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
			self.physicsWorld.gravity = CGVector(dx: (data?.acceleration.x)! * 50, dy: (data?.acceleration.y)! * -50)
			self.physicsWorld.contactDelegate = self

		}
		
		
    }
	
	func createStar() {
		let star = SKSpriteNode(imageNamed: "star")
		star.name = "star"
		star.position = CGPoint(x: RandomDouble(min: -850, max: 850), y: RandomDouble(min: -400, max: 400))
		//star.position = randomPosition()
		star.physicsBody = SKPhysicsBody(circleOfRadius: star.size.width)
		star.physicsBody?.isDynamic = false
		
		star.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
		star.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		star.physicsBody?.collisionBitMask = 0
		addChild(star)
	}
	
	func createSkull() {
		let skull = SKSpriteNode(imageNamed: "skull")
		skull.name = "skull"
		skull.position = CGPoint(x: RandomDouble(min: -850, max: 850), y: RandomDouble(min: -400, max: 400))
		skull.physicsBody = SKPhysicsBody(circleOfRadius: skull.size.width)
		skull.physicsBody?.isDynamic = false
		
		skull.physicsBody?.categoryBitMask = CollisionTypes.skull.rawValue
		skull.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		skull.physicsBody?.collisionBitMask = 0
		addChild(skull)
	}
	
	func createFinishLine() {
		finish = SKSpriteNode(imageNamed: "finish")
		finish.name = "finish"
		finish.position = CGPoint(x: 862.689, y: -431.179)
		finish.physicsBody = SKPhysicsBody(circleOfRadius: finish.size.width)
		finish.physicsBody?.isDynamic = false
		
		finish.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
		finish.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
		finish.physicsBody?.collisionBitMask = 0
		addChild(finish)
	}
	
	func createPlayer() {
		player = SKSpriteNode(imageNamed: "player")
		player.position = CGPoint(x: -867.94, y: 322.929)
		player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width)
		player.physicsBody?.allowsRotation = false
		player.physicsBody?.linearDamping = 0.5
		
		//Sets player to Int value so collisions with various objects will be handled
		player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
		player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue
		addChild(player)
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let location = touch.location(in: self)
			lastTouchPosition = location
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let location = touch.location(in: self)
			lastTouchPosition = location
		}
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		lastTouchPosition = nil
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		lastTouchPosition = nil
	}
	
	
	
    override func update(_ currentTime: TimeInterval) {
		guard isGameOver == false else {return}
		
		//if else used to allow testing on simulator and adjusts physics accordingly.
		#if (simulator)
		if let currentTouch = lastTouchPosition {
			let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
			physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
		}
		#else
		if let accelerometerData = motionManager.accelerometerData {
			physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
		}
		#endif

	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		if contact.bodyA.node == player {
			collidedWith(with: contact.bodyB.node!)
		} else if contact.bodyB.node == player {
			collidedWith(with: contact.bodyA.node!)
		}
	}
	
	
	func collidedWith(with node: SKNode) {
		if node.name == "skull" {
			player.physicsBody?.isDynamic = false // stops player node when collision w/ skull occurs
			playerLives -= 1
			if playerLives == 0 {
				self.isGameOver = true
				let gameOver = SKSpriteNode(imageNamed: "gameOver")
				gameOver.position = CGPoint(x: 512, y: 384)
				addChild(gameOver)
				return
			}
			
			// creates a sequence of actions to place player back at beginning to retry
			let move = SKAction.move(to: node.position, duration: 0.25)
			let scale = SKAction.scale(to: 0.0001, duration: 0.25)
			let remove = SKAction.removeFromParent()
			let sequence = SKAction.sequence([move, scale, remove])
			
			player.run(sequence) { [unowned self] in
				self.createPlayer()
				// MARK: TODO - Create new init of random objects
				self.isGameOver = false
			}
			
		} else if node.name == "star" {
			node.removeFromParent()
			score += 1
		} else if node.name == "finish" {
			player.physicsBody?.isDynamic = false
			score += 10
			
			//creates similar sequence to when player dies, to indicate new level
			let move = SKAction.move(to: node.position, duration: 0.25)
			let scale = SKAction.scale(to: 0.0001, duration: 0.25)
			let remove = SKAction.removeFromParent()
			let sequence = SKAction.sequence([move, scale, remove])
			
			player.run(sequence) { [unowned self] in
				self.createSkull()
				self.createStar()
				self.createPlayer()
			}
			
		}
	}
	
	func RandomDouble(min: Double, max: Double) -> Double {
		return (Double(arc4random()) / Double(UInt32.max)) * (max - min) + min
	}
	
	
}



