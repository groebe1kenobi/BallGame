//
//  NodeObject.swift
//  GroebeBallGame
//
//  Created by Sean Groebe on 5/24/18.
//  Copyright © 2018 DePaul University. All rights reserved.
//

import UIKit
import SpriteKit

class NodeObject: SKNode {
	var nodeObj: SKSpriteNode!
	
	var isVisible = false
	var madeContact = false
	
	func configure(at position: CGPoint) {
		self.position = position
		
		
	}
	
}
