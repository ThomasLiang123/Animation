//
//  Rig.swift
//  animation
//
//  Created by Thomas Liang on 6/26/18.
//  Copyright © 2018 Thomas Liang. All rights reserved.
//

import Foundation
import SpriteKit

class Rig {
    let red: SKShapeNode
    let blue: SKShapeNode
    let green: SKShapeNode
    let purple: SKShapeNode
    
    let topLeft: SKShapeNode
    let topRight: SKShapeNode
    let bottomLeft: SKShapeNode
    let bottomRight: SKShapeNode
    
    var widthToHeight: CGFloat = 0
    
    
    //ADD IMAGE
    var image: SKSpriteNode
    
    
    //which rig is attached to this
    var leading = [Rig]()
    
    //which rig this is attachted to
    var following: Rig?
    
    var attachType = -1
    /*types:
     1: Red to red
     2: Red to blue
     3: Blue to red
     4: Blue to blue
     */
    
    var texture: UIImage?
    
    var pos: Position
    
    var originTouch = CGPoint(x: 0, y: 0)
    
    var setFrames = [Int]()
    
    var middle: SKShapeNode
    //0: untouched; 1: red; 2: blue; 3: middle
    var touch = 0
    var selected = false
    
    //-1: none, 0: red, 1: blue
    var dontMove = -1
    
    var merged = false
    
    init(scene: SKScene) {
        pos = Position(topx: (((scene.view?.frame.width)!)/2)-150, topy: (((scene.view?.frame.height)!)/2)+130, bottomx: (((scene.view?.frame.width)!)/2)-150, bottomy: ((scene.view?.frame.height)!/2)+70, leftx: 0, lefty: 0, rightx: 0, righty: 0)
        
        red = SKShapeNode(rectOf: CGSize(width: 12, height: 12))
        red.position = pos.getTopPoint()
        red.fillColor = SKColor.red
        red.strokeColor = SKColor.gray
        red.zPosition = 10
        
        blue = SKShapeNode(rectOf: CGSize(width: 12, height: 12))
        blue.position = pos.getBottomPoint()
        blue.fillColor = SKColor.blue
        blue.strokeColor = SKColor.gray
        blue.zPosition = 5
        
        green = SKShapeNode(rectOf: CGSize(width: 12, height: 12))
        green.position = CGPoint(x: 0, y: 0)
        green.fillColor = SKColor.green
        green.strokeColor = SKColor.gray
        green.zPosition = 10
        green.isHidden = true
        
        purple = SKShapeNode(rectOf: CGSize(width: 12, height: 12))
        purple.position = CGPoint(x: 0, y: 0)
        purple.fillColor = SKColor.purple
        purple.strokeColor = SKColor.gray
        purple.zPosition = 5
        purple.isHidden = true
        
        topLeft = SKShapeNode(circleOfRadius: 6)
        topLeft.position = pos.getTopPoint()
        topLeft.fillColor = SKColor.orange
        topLeft.strokeColor = SKColor.gray
        topLeft.zPosition = 10
        topLeft.isHidden = true
        
        topRight = SKShapeNode(circleOfRadius: 6)
        topRight.position = pos.getTopPoint()
        topRight.fillColor = SKColor.orange
        topRight.strokeColor = SKColor.gray
        topRight.zPosition = 10
        topRight.isHidden = true
        
        bottomLeft = SKShapeNode(circleOfRadius: 6)
        bottomLeft.position = pos.getBottomPoint()
        bottomLeft.fillColor = SKColor.orange
        bottomLeft.strokeColor = SKColor.gray
        bottomLeft.zPosition = 10
        bottomLeft.isHidden = true
        
        bottomRight = SKShapeNode(circleOfRadius: 6)
        bottomRight.position = pos.getTopPoint()
        bottomRight.fillColor = SKColor.orange
        bottomRight.strokeColor = SKColor.gray
        bottomRight.zPosition = 10
        bottomRight.isHidden = true
        
        middle = SKShapeNode(rectOf: CGSize(width: 5, height: 60))
        middle.position = CGPoint(x: (scene.view?.frame.width)!/2, y: (scene.view?.frame.height)!/2)
        middle.fillColor = SKColor.gray
        middle.strokeColor = SKColor.gray
        middle.zPosition = 0
        
        image = SKSpriteNode(imageNamed: "")
        image.isHidden = true
        image.position = CGPoint(x: 0, y: 0)
        image.size = CGSize(width: 60, height: 60)
        image.zPosition = -5
        
        scene.addChild(image)
        scene.addChild(red)
        scene.addChild(blue)
        scene.addChild(green)
        scene.addChild(purple)
        scene.addChild(middle)
        scene.addChild(topLeft)
        scene.addChild(topRight)
        scene.addChild(bottomLeft)
        scene.addChild(bottomRight)
        following = nil
        
        set()
    }
    
    func resizedImage(image: UIImage, newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard image.size != newSize else { return image }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func setImage(to: UIImage) {
        texture = to
        
        widthToHeight = to.size.width/to.size.height
        
        let d = sqrt(pow(pos.topX-pos.bottomX, 2) + pow(pos.topY-pos.bottomY, 2))
        let y = (60 * middle.yScale)/(to.size.height)
        image.size = CGSize(width: to.size.width*y, height: d)
        
        texture = resizedImage(image: texture!, newSize: image.size)
        
        image.texture = SKTexture(cgImage: to.cgImage!)
        image.isHidden = false
        
        topLeft.isHidden = false
        topRight.isHidden = false
        bottomLeft.isHidden = false
        bottomRight.isHidden = false
        
        green.isHidden = false
        purple.isHidden = false
        
        var rot = middle.zRotation
        
        if (red.position.x < blue.position.x) {
            rot = CGFloat.pi+rot
        }
        
        
        let h = CGFloat(sqrt(pow(Double(pos.getTopPoint().x-pos.getBottomPoint().x), 2) + pow(Double(pos.getTopPoint().y-pos.getBottomPoint().y), 2)))
        let w = CGFloat(h)*widthToHeight
        
        topLeft.position = CGPoint(x: (pos.getTopPoint().x)-((w/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getTopPoint().y)-((w/2)*(sin(rot))))
        topRight.position = CGPoint(x: (pos.getTopPoint().x)+((w/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getTopPoint().y)+((w/2)*(sin(rot))))
        bottomLeft.position = CGPoint(x: (pos.getBottomPoint().x)-((w/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getBottomPoint().y)-((w/2)*(sin(rot))))
        bottomRight.position = CGPoint(x: (pos.getBottomPoint().x)+((w/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getBottomPoint().y)+((w/2)*(sin(rot))))
        
        green.position = CGPoint(x: (topLeft.position.x+bottomLeft.position.x)/2, y: (topLeft.position.y+bottomLeft.position.y)/2)
        purple.position = CGPoint(x: (topRight.position.x+bottomRight.position.x)/2, y: (topRight.position.y+bottomRight.position.y)/2)
        
        pos.setLeftPoint(to: green.position)
        pos.setRightPoint(to: purple.position)
        
        
        middle.isHidden = true
    }
    
    /*types:
     1: Red to red
     2: Red to blue
     3: Blue to red
     4: Blue to blue
    */
    func attachTo (rig: Rig, type: Int) {
        attachType = type
        
        following = rig
        rig.leading.append(self)
        
        /*rig.red.zPosition += 5
        rig.middle.zPosition += 5
        rig.image.zPosition += 5
        rig.blue.zPosition += 5
        
        if (rig.following != nil) {
            rig.following!.red.zPosition += 5
            rig.following!.middle.zPosition += 5
            rig.following!.blue.zPosition += 5
            rig.following!.image.zPosition += 5
        }*/
        
        follow()
    }
    
    func follow () {
        if (following != nil) {
            switch attachType {
            case 1:
                dontMove = 0
                
                let xDiff = following!.red.position.x-red.position.x
                let yDiff = following!.red.position.y-red.position.y
                
                red.position.x += xDiff
                red.position.y += yDiff
                
                blue.position.x += xDiff
                blue.position.y += yDiff
                
                middle.position.x += xDiff
                middle.position.y += yDiff
                
                image.position.x += xDiff
                image.position.y += yDiff
                
                pos.setTopPoint(to: red.position)
                pos.setBottomPoint(to: blue.position)
            case 2:
                dontMove = 0
                
                let xDiff = following!.blue.position.x-red.position.x
                let yDiff = following!.blue.position.y-red.position.y
                
                red.position.x += xDiff
                red.position.y += yDiff
                red.isHidden = true
                
                blue.position.x += xDiff
                blue.position.y += yDiff
                
                middle.position.x += xDiff
                middle.position.y += yDiff
                
                image.position.x += xDiff
                image.position.y += yDiff
                
                pos.setTopPoint(to: red.position)
                pos.setBottomPoint(to: blue.position)
            case 3:
                dontMove = 1
                
                let xDiff = following!.red.position.x-blue.position.x
                let yDiff = following!.red.position.y-blue.position.y
                
                red.position.x += xDiff
                red.position.y += yDiff
                blue.isHidden = true
                
                blue.position.x += xDiff
                blue.position.y += yDiff
                
                middle.position.x += xDiff
                middle.position.y += yDiff
                
                image.position.x += xDiff
                image.position.y += yDiff
                
                pos.setTopPoint(to: red.position)
                pos.setBottomPoint(to: blue.position)
            case 4:
                dontMove = 1
                
                let xDiff = following!.blue.position.x-blue.position.x
                let yDiff = following!.blue.position.y-blue.position.y
                
                red.position.x += xDiff
                red.position.y += yDiff
                blue.isHidden = true
                
                blue.position.x += xDiff
                blue.position.y += yDiff
                
                middle.position.x += xDiff
                middle.position.y += yDiff
                
                image.position.x += xDiff
                image.position.y += yDiff
                
                pos.setTopPoint(to: red.position)
                pos.setBottomPoint(to: blue.position)
            default:
                following = nil
                attachType = -1
            }
        }
    }
    
    func changeZ (to: CGFloat) {
        red.zPosition = to + 10
        blue.zPosition = to + 5
        middle.zPosition = to
        image.zPosition = to - 5
    }
    
    func remove() {
        red.removeFromParent()
        blue.removeFromParent()
        middle.removeFromParent()
        image.removeFromParent()
        green.removeFromParent()
        purple.removeFromParent()
        topLeft.removeFromParent()
        topRight.removeFromParent()
        bottomLeft.removeFromParent()
        bottomRight.removeFromParent()
    }
    
    func checkTouch (p: CGPoint) {
        if (selected == true) {
            if (red.contains(p) && (attachType != 1 && attachType != 2)) {
                touch = 1
            } else if (blue.contains(p) && (attachType != 3 && attachType != 4)) {
                touch = 2
            } else if (topLeft.contains(p)) {
                touch = 3
            } else if (topRight.contains(p)) {
                touch = 4
            } else if (bottomLeft.contains(p)) {
                touch = 5
            } else if (bottomRight.contains(p)) {
                touch = 6
            } else if (green.contains(p)) {
                touch = 7
            } else if (purple.contains(p)) {
                touch = 8
            } else if ((image.contains(p) || middle.contains(p)) && !(red.contains(p)) && !(blue.contains(p)) && !(topLeft.contains(p)) && !(topRight.contains(p)) && !(bottomLeft.contains(p)) && !(bottomRight.contains(p))) {
                touch = 9
                originTouch = p
            } else {
                touch = 0
            }
        }
    }
    
    func moveAll (to: CGPoint) {
        if touch == 9 && selected == true {
            middle.position.x += to.x-originTouch.x
            middle.position.y += to.y-originTouch.y
            
            image.position.x += to.x-originTouch.x
            image.position.y += to.y-originTouch.y
            
            if (attachType != 1 || attachType != 2) {
                red.position.x += to.x-originTouch.x
                red.position.y += to.y-originTouch.y
            }
            
            if (attachType != 3 || attachType != 4) {
                blue.position.x += to.x-originTouch.x
                blue.position.y += to.y-originTouch.y
            }
            
            green.position.x += to.x-originTouch.x
            green.position.y += to.y-originTouch.y
            
            purple.position.x += to.x-originTouch.x
            purple.position.y += to.y-originTouch.y
            
            topLeft.position.x += to.x-originTouch.x
            topLeft.position.y += to.y-originTouch.y
            
            topRight.position.x += to.x-originTouch.x
            topRight.position.y += to.y-originTouch.y
            
            bottomLeft.position.x += to.x-originTouch.x
            bottomLeft.position.y += to.y-originTouch.y
            
            bottomRight.position.x += to.x-originTouch.x
            bottomRight.position.y += to.y-originTouch.y
            
            pos.setTopPoint(to: red.position)
            pos.setBottomPoint(to: blue.position)   
            
            originTouch = to
            
            if (following != nil) {
                switch attachType {
                case 1:
                    following!.red.position = red.position
                    following!.pos.setTopPoint(to: red.position)
                    following!.set()
                case 2:
                    following!.blue.position = red.position
                    following!.pos.setBottomPoint(to: red.position)
                    following!.set()
                case 3:
                    following!.red.position = blue.position
                    following!.pos.setTopPoint(to: blue.position)
                    following!.set()
                case 4:
                    following!.blue.position = blue.position
                    following!.pos.setBottomPoint(to: blue.position)
                    following!.set()
                default:
                    print("none")
                }
            }
            
            if (leading.count > 0) {
                lead()
                
            }
        }
    }
    
    func lead () {
        if (leading.count > 0) {
            for l in leading {
                l.follow()
                l.lead()
            }
        }
    }
    
    func moveRed (to: CGPoint) {
        if touch == 1 && selected == true && (attachType != 1 || attachType != 2) && dontMove != 0 {
            pos.setTopPoint(to: to)
            red.position = pos.getTopPoint()
            set()
        }
    }
    
    func moveBlue (to: CGPoint) {
        if touch == 2 && selected == true  && (attachType != 3 || attachType != 4) && dontMove != 1 {
            pos.setBottomPoint(to: to)
            blue.position = pos.getBottomPoint()
            set()
        }
    }
    
    func moveGreen (to: CGPoint) {
        if touch == 7 && selected == true && dontMove != 0 {
            pos.setLeftPoint(to: to)
            green.position = pos.getLeftPoint()
            set()
        }
    }
    
    func movePurple (to: CGPoint) {
        if touch == 8 && selected == true && dontMove != 1 {
            pos.setRightPoint(to: to)
            purple.position = pos.getRightPoint()
            set()
        }
    }
    
    func moveTopLeft (to: CGPoint) {
        if touch == 3 && selected == true && dontMove != 1 {
            let h = CGFloat(sqrt(pow(Double(pos.getTopPoint().x-pos.getBottomPoint().x), 2) + pow(Double(pos.getTopPoint().y-pos.getBottomPoint().y), 2)))
            let w = CGFloat(h)*widthToHeight
            let origin = CGPoint(x: (pos.getTopPoint().x)-((w/2)*(sin((CGFloat.pi/2)-image.zRotation))), y: (pos.getTopPoint().y)-((w/2)*(sin(image.zRotation))))
            
            let distx = to.x-origin.x
            let disty = to.y-origin.y
            let dist = sqrt(pow(distx, 2)+pow(disty, 2))
            
            var totalAngle = atan(abs(distx/disty))
            if (distx > 0) {
                totalAngle = -totalAngle
                if (disty < 0) {
                    totalAngle = -CGFloat.pi-totalAngle
                }
            } else if (disty < 0) {
                totalAngle = CGFloat.pi-totalAngle
            }
            
            
            var partAngle = totalAngle-image.zRotation
            
            let dy = sqrt(pow(topLeft.position.x-bottomLeft.position.x, 2) + pow(topLeft.position.y-bottomLeft.position.y, 2))
            let m = CGPoint(x: (topLeft.position.x+bottomRight.position.x)/2, y: (topLeft.position.y+bottomRight.position.y)/2)
            
            var rot = image.zRotation
            
            
            if (red.position.x < blue.position.x) {
                rot = CGFloat.pi+rot
                
                partAngle = ((CGFloat.pi+image.zRotation)-totalAngle)
                
                pos.setTopPoint(to: CGPoint(x: m.x+(((dy)/2)*sin(image.zRotation)), y: m.y-(((dy)/2)*cos(image.zRotation))))
                
                pos.setBottomPoint(to: CGPoint(x: m.x-(((dy)/2)*sin(image.zRotation)), y: m.y+(((dy)/2)*cos(image.zRotation))))
            }
            
            
            //print(String(describing: totalAngle)+", "+String(describing: partAngle))
            
            topLeft.position = to
            
            
            
            
            let height = dist*cos(partAngle)
            let width = dist*sin(partAngle)
            
            let heightX = height*sin(CGFloat.pi-image.zRotation)
            let heightY = height*cos(CGFloat.pi-image.zRotation)
            
            let initTopRight = CGPoint(x: (pos.getTopPoint().x)+((w/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getTopPoint().y)+((w/2)*(sin(rot))))
            topRight.position.x = initTopRight.x-heightX
            topRight.position.y = initTopRight.y-heightY
            
            let widthX = width*cos(image.zRotation)
            let widthY = width*sin(image.zRotation)
            
            let initBottomLeft = CGPoint(x: (pos.getBottomPoint().x)-((w/2)*(sin((CGFloat.pi/2)-image.zRotation))), y: (pos.getBottomPoint().y)-((w/2)*(sin(image.zRotation))))
            bottomLeft.position.x = initBottomLeft.x-widthX
            bottomLeft.position.y = initBottomLeft.y-widthY
            
            set()
        }
    }
    
    func moveTopRight (to: CGPoint) {
        if touch == 4 && selected == true && dontMove != 1 {
            topRight.position = to
            red.position = pos.getTopPoint()
            set()
        }
    }
    
    func moveBottomLeft (to: CGPoint) {
        if touch == 5 && selected == true && dontMove != 1 {
            bottomLeft.position = to
            blue.position = pos.getBottomPoint()
            set()
        }
    }
    
    func moveBottomRight (to: CGPoint) {
        if touch == 6 && selected == true && dontMove != 1 {
            bottomRight.position = to
            blue.position = pos.getBottomPoint()
            set()
        }
    }
    
    func set () {
        if (touch != 0) {
            let h = CGFloat(sqrt(pow(Double(pos.getTopPoint().x-pos.getBottomPoint().x), 2) + pow(Double(pos.getTopPoint().y-pos.getBottomPoint().y), 2)))
            let w = CGFloat(h)*widthToHeight
            
            var dy = sqrt(pow(pos.topX-pos.bottomX, 2) + pow(pos.topY-pos.bottomY, 2))
            var dx = sqrt(pow(pos.leftX-pos.rightX, 2) + pow(pos.leftY-pos.rightY, 2))
            var m = CGPoint(x: (pos.topX+pos.bottomX)/2, y: (pos.topY+pos.bottomY)/2)
            var r = atan((pos.topY-m.y)/(pos.topX-m.x)) - CGFloat.pi/2
            
            //let y = (60 * middle.yScale)/(image.size.height)
            
            if (touch == 1 || touch == 2) {
                image.size = CGSize(width: image.size.width, height: dy)
            } else if (touch == 3 || touch == 4 || touch == 5 || touch == 6) {
                dx = sqrt(pow(topLeft.position.x-topRight.position.x, 2) + pow(topLeft.position.y-topRight.position.y, 2))
                dy = sqrt(pow(topLeft.position.x-bottomLeft.position.x, 2) + pow(topLeft.position.y-bottomLeft.position.y, 2))
                image.size = CGSize(width: dx, height: dy)
                m = CGPoint(x: (topLeft.position.x+bottomRight.position.x)/2, y: (topLeft.position.y+bottomRight.position.y)/2)
            } else if (touch == 7 || touch == 8) {
                image.size = CGSize(width: dx, height: image.size.height)
                m = CGPoint(x: (green.position.x+purple.position.x)/2, y: (green.position.y+purple.position.y)/2)
                r = atan((pos.leftY-m.y)/(pos.leftX-m.x))
            }
            widthToHeight = image.size.width/image.size.height
            
            if (texture != nil) {
                texture = resizedImage(image: texture!, newSize: image.size)
            }
            
            middle.yScale = dy/60
            middle.position = m
            middle.zRotation = r
            
            image.position = m
            image.zRotation = r
            
            if (touch != 3 && touch != 4 && touch != 5 && touch != 6) {
            
                if (red.position.x >= blue.position.x) {
                    image.yScale = 1
                    image.xScale = 1
                } else {
                    image.yScale = -1
                    image.xScale = -1
                }
            }
            
            var rot = image.zRotation
            
            if (touch == 1 || touch == 2 || touch == 3) {
                if (red.position.x < blue.position.x) {
                    rot = CGFloat.pi+rot
                }
            } else if (touch == 7 || touch == 8) {
                if (green.position.x > purple.position.x) {
                    rot = CGFloat.pi+rot
                    image.xScale = -abs(image.xScale)
                    image.yScale = -abs(image.yScale)
                } else {
                    image.xScale = abs(image.xScale)
                    image.yScale = abs(image.yScale)
                }
            }
            
            if (texture != nil) {
                if (touch == 1 || touch == 2 || touch == 0) {
                    topLeft.position = CGPoint(x: (pos.getTopPoint().x)-((w/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getTopPoint().y)-((w/2)*(sin(rot))))
                    topRight.position = CGPoint(x: (pos.getTopPoint().x)+((w/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getTopPoint().y)+((w/2)*(sin(rot))))
                    bottomLeft.position = CGPoint(x: (pos.getBottomPoint().x)-((w/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getBottomPoint().y)-((w/2)*(sin(rot))))
                    bottomRight.position = CGPoint(x: (pos.getBottomPoint().x)+((w/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getBottomPoint().y)+((w/2)*(sin(rot))))
                } else if (touch == 7 || touch == 8) {
                    topLeft.position = CGPoint(x: (pos.getLeftPoint().x)-((h/2)*(cos((CGFloat.pi/2)-rot))), y: (pos.getLeftPoint().y)+((h/2)*(sin((CGFloat.pi/2)-rot))))
                    topRight.position = CGPoint(x: (pos.getRightPoint().x)-((h/2)*(sin(rot))), y: (pos.getRightPoint().y)+((h/2)*(cos(rot))))
                    bottomLeft.position = CGPoint(x: (pos.getLeftPoint().x)+((h/2)*(cos((CGFloat.pi/2)-rot))), y: (pos.getLeftPoint().y)-((h/2)*(sin((CGFloat.pi/2)-rot))))
                    bottomRight.position = CGPoint(x: (pos.getRightPoint().x)+((h/2)*(sin(rot))), y: (pos.getRightPoint().y)-((h/2)*(cos(rot))))
                }
                
                if (touch != 1 && touch != 2 && touch != 0) {
                    //print("touch")
                    pos.setTopPoint(to: CGPoint(x: m.x-(((dx/widthToHeight)/2)*sin(rot)), y: m.y+(((dx/widthToHeight)/2)*cos(rot))))
                    red.position = pos.getTopPoint()
                    
                    pos.setBottomPoint(to: CGPoint(x: m.x+(((dx/widthToHeight)/2)*sin(rot)), y: m.y-(((dx/widthToHeight)/2)*cos(rot))))
                    blue.position = pos.getBottomPoint()
                }
                
                
                if (touch != 7 && touch != 8) {
                    pos.setRightPoint(to: CGPoint(x: m.x+(((dy*widthToHeight)/2)*cos(rot)), y: m.y+(((dy*widthToHeight/2)*sin(rot)))))
                    purple.position = pos.getRightPoint()
                    
                    pos.setLeftPoint(to: CGPoint(x: m.x-(((dy*widthToHeight)/2)*cos(rot)), y: m.y-(((dy*widthToHeight)/2)*sin(rot))))
                    green.position = pos.getLeftPoint()
                }
            }
        } else {
            let dy = sqrt(pow(pos.topX-pos.bottomX, 2) + pow(pos.topY-pos.bottomY, 2))
            let dx = sqrt(pow(pos.leftX-pos.rightX, 2) + pow(pos.leftY-pos.rightY, 2))
            let m = CGPoint(x: (pos.topX+pos.bottomX)/2, y: (pos.topY+pos.bottomY)/2)
            let r = atan((pos.topY-m.y)/(pos.topX-m.x)) - CGFloat.pi/2
            
            middle.position = m
            middle.yScale = dy/60
            middle.zRotation = r
            
            image.position = m
            image.size = CGSize(width: dx, height: dy)
            image.zRotation = r
            
            if (red.position.x >= blue.position.x) {
                image.yScale = 1
                image.xScale = 1
            } else {
                image.yScale = -1
                image.xScale = -1
            }
            
            let rot = image.zRotation
            
            topLeft.position = CGPoint(x: (pos.getTopPoint().x)-((dx/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getTopPoint().y)-((dx/2)*(sin(rot))))
            topRight.position = CGPoint(x: (pos.getTopPoint().x)+((dx/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getTopPoint().y)+((dx/2)*(sin(rot))))
            bottomLeft.position = CGPoint(x: (pos.getBottomPoint().x)-((dx/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getBottomPoint().y)-((dx/2)*(sin(rot))))
            bottomRight.position = CGPoint(x: (pos.getBottomPoint().x)+((dx/2)*(sin((CGFloat.pi/2)-rot))), y: (pos.getBottomPoint().y)+((dx/2)*(sin(rot))))
        }
    }
    
    func move (to: Position) {
        red.position = to.getTopPoint()
        blue.position = to.getBottomPoint()
        green.position = to.getLeftPoint()
        purple.position = to.getRightPoint()
        
        //print("Move")
        pos.setTopPoint(to: to.getTopPoint())
        pos.setBottomPoint(to: to.getBottomPoint())
        pos.setLeftPoint(to: to.getLeftPoint())
        pos.setRightPoint(to: to.getRightPoint())
        
        set()
    }
    
    func setFrame (scene: GameScene) {
        selected = true
        changeZ(to: 5)
        middle.fillColor = UIColor.green
        
        //print("Frame")
        pos.setTopPoint(to: red.position)
        pos.setBottomPoint(to: blue.position)
        pos.setLeftPoint(to: green.position)
        pos.setRightPoint(to: purple.position)
        print(pos.toString())
        
        scene.frames[scene.frameAt].rigs[scene.selected].setTopPoint(to: pos.getTopPoint())
        scene.frames[scene.frameAt].rigs[scene.selected].setBottomPoint(to: pos.getBottomPoint())
        
        scene.frames[scene.frameAt].rigs[scene.selected].setLeftPoint(to: pos.getLeftPoint())
        scene.frames[scene.frameAt].rigs[scene.selected].setRightPoint(to: pos.getRightPoint())
        
        if !(setFrames.contains(scene.frameAt)) {
            setFrames.append(scene.frameAt)
        }
        
        /*if (leading.count > 0) {
            for l in leading {
                l.setFrame(scene: scene)
            }
        }*/
    }
    
    func select (p: CGPoint) -> Bool {
        if (red.contains(p) && (attachType != 1 && attachType != 2)) {
            return true
        } else if (blue.contains(p) && (attachType != 3 && attachType != 4)) {
            return true
        } else if (middle.contains(p) && !(red.contains(p)) && !(blue.contains(p))) {
            return true
        }
        
        return false
    }
    
    func bendImage(in image: UIImage) -> UIImage? {
        if (merged == true && following != nil) {
            let angleBetween = following!.middle.zRotation-self.middle.zRotation
            let stretch = Double(image.size.width*tan(angleBetween))
            
            guard let inputCGImage = image.cgImage else {
                print("unable to get cgImage")
                return nil
            }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let width = inputCGImage.width
            let height = inputCGImage.height
            let bytesPerPixel = 4
            let bitsPerComponent = 8
            let bytesPerRow = bytesPerPixel * (width/**2*/)
            let bitmapInfo = RGBA32.bitmapInfo
            
            let length = Double(height)*0.5
            
            guard let context = CGContext(data: nil, width: width, height: height+Int(stretch), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
                print("unable to create context")
                return nil
            }
            context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height+Int(stretch)))
            
            guard let buffer = context.data else {
                print("unable to get context data")
                return nil
            }
            
            let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: (width) * (height+Int(stretch)))
            
            var resizedPixels = [RGBA32]()
            
            for r in Int(length)...(height+Int(stretch))-1 {
                for c in 0...(width)-1 {
                    let o = r * (width) + c
                    //print(String(describing: r) + ",")
                    //print((((Double(r)-length)/((stretch+(Double(height)-length))/(Double(height)-length)))+(length)))
                    //resizedPixels.append(pixelBuffer[Int((((Double(r)-length)/((stretch+(Double(height)-length))/(Double(height)-length)))+(length)))*width+c])
                    resizedPixels.append(pixelBuffer[o])
                }
            }
            
            for r in Int(length)...(height+Int(stretch))-1 {
                for c in 0...(width)-1 {
                    let o = r * (width) + c
                    let divide = 2*((stretch+(Double(height)-length))/(Double(height)-length))
                    let row = (Double(r)-length)/divide
                    let counter = (Int(row)*(width)+c)
                    pixelBuffer[o] = resizedPixels[counter]
                }
            }
            
            
            
            let outputCGImage = context.makeImage()!
            let outputImage = UIImage(cgImage: outputCGImage)
            //outputImage. = CGSize(width: image.size.width+20, height: image.size.height)
            
            return outputImage
        } else {
            return image
        }
    }
    
    func fromData (from: [Any]) {
        var position = from[0] as! String
        position = position.replacingOccurrences(of: "(", with: "")
        position = position.replacingOccurrences(of: ")", with: "")
        
        let values = position.components(separatedBy: ", ")
        pos = Position(topx: CGFloat(Double(values[0])!), topy: CGFloat(Double(values[1])!), bottomx: CGFloat(Double(values[2])!), bottomy: CGFloat(Double(values[3])!), leftx: CGFloat(Double(values[4])!), lefty: CGFloat(Double(values[5])!), rightx: CGFloat(Double(values[6])!), righty: CGFloat(Double(values[7])!))
        move(to: pos)
        
        if (from.count > 2) {
            texture = UIImage(data: from[2] as! Data)
            
            image.texture = SKTexture(cgImage: texture!.cgImage!)
        }
        
        setFrames = from[1] as! [Int]
    }
    
    func toData () -> [Any] {
        var ret: [Any]
        if (texture != nil) {
            ret = [pos.toString(), setFrames, UIImagePNGRepresentation(texture!)] as [Any]
        } else {
            ret = [pos.toString(), setFrames] as [Any]
        }
        
        return ret
    }
    
    struct RGBA32: Equatable {
        private var color: UInt32
        
        var redComponent: UInt8 {
            return UInt8((color >> 24) & 255)
        }
        
        var greenComponent: UInt8 {
            return UInt8((color >> 16) & 255)
        }
        
        var blueComponent: UInt8 {
            return UInt8((color >> 8) & 255)
        }
        
        var alphaComponent: UInt8 {
            return UInt8((color >> 0) & 255)
        }
        
        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            let red   = UInt32(red)
            let green = UInt32(green)
            let blue  = UInt32(blue)
            let alpha = UInt32(alpha)
            color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
        }
        
        static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
        static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
        static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
        static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
        static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
        static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
        static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
        static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
        static let clear    = RGBA32(red: 0,   green: 0, blue: 0, alpha: 0)
        
        static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
            return lhs.color == rhs.color
        }
    }
}
