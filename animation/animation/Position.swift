//
//  Position.swift
//  animation
//
//  Created by Thomas Liang on 7/11/18.
//  Copyright © 2018 Thomas Liang. All rights reserved.
//

import Foundation
import SpriteKit

class Position {
    var topX: CGFloat
    var topY: CGFloat
    var bottomX: CGFloat
    var bottomY: CGFloat
    var leftX: CGFloat
    var leftY: CGFloat
    var rightX: CGFloat
    var rightY: CGFloat
    
    init(topx: CGFloat, topy: CGFloat, bottomx: CGFloat, bottomy: CGFloat, leftx: CGFloat, lefty: CGFloat, rightx: CGFloat, righty: CGFloat) {
        topX = topx
        topY = topy
        bottomX = bottomx
        bottomY = bottomy
        leftX = leftx
        leftY = lefty
        rightX = rightx
        rightY = righty
    }
    
    func getTopPoint() -> CGPoint {
        return CGPoint(x: topX, y: topY)
    }
    
    func getBottomPoint() -> CGPoint {
        return CGPoint(x: bottomX, y: bottomY)
    }
    
    func getLeftPoint() -> CGPoint {
        return CGPoint(x: leftX, y: leftY)
    }
    
    func getRightPoint() -> CGPoint {
        return CGPoint(x: rightX, y: rightY)
    }
    
    func setTopPoint(to: CGPoint) {
        topX = to.x
        topY = to.y
    }
    
    func setBottomPoint(to: CGPoint) {
        bottomX = to.x
        bottomY = to.y
    }
    
    func setLeftPoint(to: CGPoint) {
        leftX = to.x
        leftY = to.y
    }
    
    func setRightPoint(to: CGPoint) {
        rightX = to.x
        rightY = to.y
    }
    
    func toString() -> String {
        let top = "("+String(describing: topX)+", "+String(describing: topY)+")"
        let bottom = "("+String(describing: bottomX)+", "+String(describing: bottomY)+")"
        let left = "("+String(describing: leftX)+", "+String(describing: leftY)+")"
        let right = "("+String(describing: rightX)+", "+String(describing: rightY)+")"
        return top + ", " + bottom + ", " + left + ", " + right
    }
}
