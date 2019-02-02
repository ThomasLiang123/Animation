//
//  Button.swift
//  animation
//
//  Created by Thomas Liang on 7/21/18.
//  Copyright © 2018 Thomas Liang. All rights reserved.
//

import Foundation
import SpriteKit

class Button: SKNode {
    var label: SKLabelNode
    var back: SKShapeNode
    
    init(text: String, size: CGSize, position: CGPoint) {
        back = SKShapeNode(rectOf: size)
        label = SKLabelNode(text: text)
        
        super.init()
        
        label.zPosition = 10
        label.fontSize = 30
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = position
        label.fontColor = SKColor.blue
        self.addChild(label)
        
        back.fillColor = SKColor.lightGray
        back.strokeColor = SKColor.clear
        back.zPosition = 5
        back.position = position
        self.addChild(back)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pressed (p: CGPoint) -> Bool {
        if back.contains(p) {
            return true
        }
        
        return false
    }
}
