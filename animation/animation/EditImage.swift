//
//  EditImage.swift
//  animation
//
//  Created by Thomas Liang on 8/11/18.
//  Copyright © 2018 Thomas Liang. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit
import CoreGraphics

class EditImage: SKScene {
    
    var image: UIImage!
    var imageView: SKSpriteNode!
    
    var xDiff: CGFloat = 0.0
    var yDiff: CGFloat = 0.0
    //0: x, 1: y
    var used = -1
    
    var loading = false
    
    var lastDraw = CGPoint(x: 0, y: 0)
    
    var use: Button!
    
    override func didMove(to view: SKView) {
        use = Button(text: "Use", size: CGSize(width: 100, height: 50), position: CGPoint(x: self.frame.width-120, y: self.frame.height-60))
        self.addChild(use)
        
        self.backgroundColor = .darkGray
        
        let displaySize: CGRect = self.view!.frame
        let width = displaySize.width//*0.67
        let height = displaySize.height//*0.67
        
        var texture = SKTexture(cgImage: image!.cgImage!)
        imageView = SKSpriteNode(texture: texture)
        
        xDiff = width*0.8/image.size.width
        yDiff = height*0.8/image.size.height
        
        
        if (xDiff < 1 || yDiff < 1) {
            if (image.size.width-self.frame.width*0.8 >= image.size.height-height*0.8) {
                used = 0
                /*print(xDiff)
                imageView.size = CGSize(width: width*0.8, height: image.size.height*xDiff)
                print(imageView.size)*/
                imageView.xScale *= xDiff
                imageView.yScale *= xDiff
            } else {
                used = 1
                /*imageView.size = CGSize(width: image.size.width*yDiff, height: height*0.8)
                print(yDiff)
                print(imageView.size)*/
                imageView.xScale *= yDiff
                imageView.yScale *= yDiff
            }
        } else {
            imageView.size = CGSize(width: image.size.width, height: image.size.height)
            imageView.run(SKAction.setTexture(texture, resize: true))
        }
        
        image = resizedImage(image: image, newSize: CGSize(width: imageView.size.width/2, height: imageView.size.height/2))
        texture = SKTexture(cgImage: image.cgImage!)
        imageView = SKSpriteNode(texture: texture)
        
        imageView.position = CGPoint(x: /*(width)/2*/width/2, y: /*(displaySize.height-150)*/height/2)
        
        imageView.zPosition = 0
        self.addChild(imageView)
    }
    
    func resizedImage(image: UIImage, newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return image }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func clear (image: UIImage) -> UIImage? {
        guard let inputCGImage = image.cgImage else {
            print("unable to get cgImage")
            return nil
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = inputCGImage.width
        let height = inputCGImage.height
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        for r in 0 ..< Int(height) {
            for c in 0 ..< Int(width) {
                let offset = r * Int(width) + c
                pixelBuffer[offset] = .clear
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        return outputImage
    }
    
    func processPixels(in image: UIImage, from: CGPoint) -> UIImage? {
        guard let inputCGImage = image.cgImage else {
            print("unable to get cgImage")
            return nil
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = inputCGImage.width
        let height = inputCGImage.height
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        var row = CGFloat(-(from.y-(imageView.position.y+imageView.size.height/2)))
        var column = CGFloat(from.x-(imageView.position.x-imageView.size.width/2))
        
        let offset = Int(row)*Int(width)+Int(column)
        //print(String(describing: row) + ", " + String(describing: column) + ": " + String(describing: offset))
        //pixelBuffer[offset] = .black
        
        for r in Int(row)-15 ... Int(row)+15 {
            for c in Int(column)-15 ... Int(column)+15 {
                let o = r * width + c
                if (o >= 0 && o < width*height) {
                    let d = sqrt(pow(CGFloat(c-Int(column)), 2) + pow(CGFloat(r-Int(row)), 2))
                    if (d <= 15) {
                        if (pixelBuffer[o] != .clear) {
                            pixelBuffer[o] = .clear
                        }
                    }
                }
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        return outputImage
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
    
    func inBetween (from: CGPoint) {
        
        let d = sqrt(pow(from.x-lastDraw.x, 2) + pow(from.y-lastDraw.y, 2))
        
        //print(from)
        
        for i in 0...Int(d) {
            let x = (lastDraw.x+((from.x-lastDraw.x)*(CGFloat(i)/d)))
            let y = (lastDraw.y+((from.y-lastDraw.y)*(CGFloat(i)/d)))
            
            //print(String(describing: lastDraw.x) + "," + String(describing: x) + ", " + String(describing: from.x))
            
            let point = CGPoint(x: x, y: y)
            image = processPixels(in: image, from: point)
            imageView.texture = SKTexture(cgImage: image.cgImage!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let p = t.location(in: self)
            
            if (use.pressed(p: p)) {
                let scene: GameScene = GameScene(size: self.size)
                scene.scaleMode = .resizeFill
                scene.imageFrom = image
                self.view?.presentScene(scene, transition: .reveal(with: .left, duration: 0.2))
            }
            
            if (imageView.contains(p)) {
                image = processPixels(in: image, from: p)!
                imageView.texture = SKTexture(cgImage: image.cgImage!)
                lastDraw = p
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let p = t.location(in: self)
            
            if (imageView.contains(p)) {
                inBetween(from: p)
                lastDraw = p
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let p = t.location(in: self)
            lastDraw = CGPoint(x: 0, y: 0)
        }
    }
}
