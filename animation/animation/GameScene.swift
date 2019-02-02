//
//  GameScene.swift
//  animation
//
//  Created by Thomas Liang on 6/26/18.
//  Copyright © 2018 Thomas Liang. All rights reserved.
//


import GameplayKit
import SpriteKit
class GameScene: SKScene, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var defaults: UserDefaults = UserDefaults.standard
    
    var set: Button!
    var add: Button!
    var delete: Button!
    var setImage: Button!
    var merge: Button!
    
    var attach: Button!
    var attachFrom: Button!
    var attachTo: Button!
    var attaching = false
    var type = -1
    
    var bottomBar: SKShapeNode!
    var keys: SKShapeNode!
    var dividers: SKSpriteNode!
    var slider: SKShapeNode!
    var numberOfFrames = 30
    var touchingSlider = false
    var frameAt = 0
    var frames = [Frame]()
    var rigs = [Rig]()
    
    var imageFrom: UIImage? = nil
    
    var sideBar: SKShapeNode!
    var selected = 0
    
    var mainView: SKShapeNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        sideBar = SKShapeNode(rectOf: CGSize(width: 300, height: (self.view?.frame.height)!))
        sideBar.fillColor = SKColor.darkGray
        sideBar.strokeColor = SKColor.lightGray
        sideBar.lineWidth = 3
        sideBar.position = CGPoint(x: ((self.view?.frame.width))!-150, y: (self.view?.frame.height)!/2)
        self.addChild(sideBar)
        
        bottomBar = SKShapeNode(rectOf: CGSize(width: (self.view?.frame.width)!-300, height: 200))
        bottomBar.fillColor = SKColor.darkGray
        bottomBar.strokeColor = SKColor.lightGray
        bottomBar.lineWidth = 3
        bottomBar.position = CGPoint(x: (((self.view?.frame.width))!/2)-150, y: 100)
        self.addChild(bottomBar)
        
        mainView = SKShapeNode(rectOf: CGSize(width: (self.view?.frame.width)!-300, height: (self.view?.frame.height)!-200))
        mainView.fillColor = SKColor.white
        mainView.position = CGPoint(x: (((self.view?.frame.width))!/2)-150, y: ((self.view?.frame.height)!/2)+100)
        self.addChild(mainView)
        
        
        if (UserDefaults.standard.array(forKey: "Frames") != nil) {
            for r in UserDefaults.standard.array(forKey: "Frames") as! [[String]] {
                var frame = Frame()
                
                for p in r {
                    var position = p
                    position = position.replacingOccurrences(of: "(", with: "")
                    position = position.replacingOccurrences(of: ")", with: "")
                    
                    let values = position.components(separatedBy: ", ")
                    let pos = Position(topx: CGFloat(Double(values[0])!), topy: CGFloat(Double(values[1])!), bottomx: CGFloat(Double(values[2])!), bottomy: CGFloat(Double(values[3])!), leftx: CGFloat(Double(values[4])!), lefty: CGFloat(Double(values[5])!), rightx: CGFloat(Double(values[6])!), righty: CGFloat(Double(values[7])!))
                    
                    frame.addRig(r: pos)
                }
                
                frames.append(frame)
            }
        } else {
            for i in 0...35 {
                let frame = Frame()
                frames.append(frame)
            }
        }
        
        if (UserDefaults.standard.array(forKey: "Rigs") != nil) { //doesnt save attachments
            var c = 0
            for r in UserDefaults.standard.array(forKey: "Rigs") as! [[Any]] {
                let rig = Rig(scene: self)
                rigs.append(rig)
                rig.fromData(from: r)
                rig.move(to: loadFrame(index: c))
                
                c += 1
            }
        }
        
        if (UserDefaults.standard.string(forKey: "Selected") != nil) {
            selected = Int(UserDefaults.standard.string(forKey: "Selected")!)!
            if (selected != -1) {
                rigs[selected].selected = true
                rigs[selected].changeZ(to: 5)
                
                if (imageFrom != nil) {
                    rigs[selected].setImage(to: imageFrom!)
                    imageFrom = nil
                }
                
                rigs[selected].middle.fillColor = UIColor.green
            }
        }
        
        
        keys = SKShapeNode(rectOf: CGSize(width: bottomBar.frame.width-40, height: 100))
        keys.position = CGPoint(x: (bottomBar.frame.width/2)-2, y: (bottomBar.frame.height/2)+25)
        keys.fillColor = SKColor.lightGray
        keys.strokeColor = SKColor.gray
        self.addChild(keys)
        
        let rect = CGRect(origin: .zero, size: keys.frame.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let color = UIColor.clear
        color.setFill()
        UIRectFill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        image = setDividers(amount: numberOfFrames, image: image!)
        let cgImage = image?.cgImage
        
        dividers = SKSpriteNode(texture: SKTexture(cgImage: cgImage!))
        dividers.size = CGSize(width: keys.frame.size.width, height: keys.frame.size.height-10)
        dividers.position = keys.position
        self.addChild(dividers)
        
        slider = SKShapeNode()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: keys.position.x-(keys.frame.width/2), y: keys.position.y+(keys.frame.height/2)))
        path.addLine(to: CGPoint(x: keys.position.x-(keys.frame.width/2)-10, y: keys.position.y+(keys.frame.height/2)+20))
        path.addLine(to: CGPoint(x: keys.position.x-(keys.frame.width/2)+10, y: keys.position.y+(keys.frame.height/2)+20))
        slider.path = path.cgPath
        slider.lineWidth = 2
        slider.strokeColor = .red
        slider.fillColor = .red
        self.addChild(slider)
        
        
        
        add = Button(text: "Add New", size: CGSize(width: 250, height: 70), position: CGPoint(x: sideBar.position.x, y: 730))
        self.addChild(add)
        
        delete = Button(text: "Delete", size: CGSize(width: 250, height: 70), position: CGPoint(x: sideBar.position.x, y: 100))
        self.addChild(delete)
        
        set = Button(text: "Set Location", size: CGSize(width: 250, height: 70), position: CGPoint(x: sideBar.position.x, y: 615))
        self.addChild(set)
        
        setImage = Button(text: "Set Image", size: CGSize(width: 250, height: 70), position: CGPoint(x: sideBar.position.x, y: 340))
        self.addChild(setImage)
        
        attach = Button(text: "Attach To", size: CGSize(width: 250, height: 70), position: CGPoint(x: sideBar.position.x, y: 500))
        self.addChild(attach)
        
        attachFrom = Button(text: "Red", size: CGSize(width: 100, height: 35), position: CGPoint(x: sideBar.position.x-75, y: 440))
        attachFrom.label.fontSize = 22
        attachFrom.label.fontColor = SKColor.red
        self.addChild(attachFrom)
        
        attachTo = Button(text: "Red", size: CGSize(width: 100, height: 35), position: CGPoint(x: sideBar.position.x+75, y: 440))
        attachTo.label.fontSize = 22
        attachTo.label.fontColor = SKColor.red
        self.addChild(attachTo)
        
        merge = Button(text: "Merge Image", size: CGSize(width: 250, height: 70), position: CGPoint(x: sideBar.position.x, y: 225))
        self.addChild(merge)
        
        let toLabel = SKLabelNode(text: "To")
        toLabel.fontColor = SKColor.white
        toLabel.fontSize = 18
        toLabel.position = CGPoint(x: sideBar.position.x, y: 434)
        self.addChild(toLabel)
    }
    
    func loadFrame(index: Int) -> (Position) {
        if (rigs[index].setFrames.contains(frameAt)) {
            return frames[frameAt].rigs[index]
        }
        
        if (rigs[index].setFrames.count > 1) {
            rigs[index].setFrames.sort()
            var before = rigs[index].setFrames[rigs[index].setFrames.count-1]
            var after = rigs[index].setFrames[0]
            for i in 0...rigs[index].setFrames.count-2 {
                if (rigs[index].setFrames[i] < frameAt && rigs[index].setFrames[i+1] > frameAt) {
                    before = rigs[index].setFrames[i]
                    after = rigs[index].setFrames[i+1]
                }
            }
            
            
            
            if (before == rigs[index].setFrames[rigs[index].setFrames.count-1]) {
                return frames[before].rigs[index]
            } else {
                let topX = (frames[after].rigs[index].topX-frames[before].rigs[index].topX)*(CGFloat(frameAt-before)/CGFloat(after-before))
                let topY = (frames[after].rigs[index].topY-frames[before].rigs[index].topY)*(CGFloat(frameAt-before)/CGFloat(after-before))
                let bottomX = (frames[after].rigs[index].bottomX-frames[before].rigs[index].bottomX)*(CGFloat(frameAt-before)/CGFloat(after-before))
                let bottomY = (frames[after].rigs[index].bottomY-frames[before].rigs[index].bottomY)*(CGFloat(frameAt-before)/CGFloat(after-before))
                
                let leftX = (frames[after].rigs[index].leftX-frames[before].rigs[index].leftX)*(CGFloat(frameAt-before)/CGFloat(after-before))+frames[before].rigs[index].leftX
                let leftY = (frames[after].rigs[index].leftY-frames[before].rigs[index].leftY)*(CGFloat(frameAt-before)/CGFloat(after-before))+frames[before].rigs[index].leftY
                let rightX = (frames[after].rigs[index].rightX-frames[before].rigs[index].rightX)*(CGFloat(frameAt-before)/CGFloat(after-before))+frames[before].rigs[index].rightX
                let rightY = (frames[after].rigs[index].rightY-frames[before].rigs[index].rightY)*(CGFloat(frameAt-before)/CGFloat(after-before))+frames[before].rigs[index].rightY
                
                let position = Position(topx: topX+frames[before].rigs[index].topX, topy: topY+frames[before].rigs[index].topY, bottomx: bottomX+frames[before].rigs[index].bottomX, bottomy: bottomY+frames[before].rigs[index].bottomY, leftx: leftX, lefty: leftY, rightx: rightX, righty: rightY)
                //print(position.toString())
                return position
            }
        } else if (rigs[index].setFrames.count > 0) {
            return frames[rigs[index].setFrames[0]].rigs[index]
        }
        
        return Position(topx: (self.view?.frame.width)!/2, topy: ((self.view?.frame.height)!/2)+30, bottomx: (self.view?.frame.width)!/2, bottomy: ((self.view?.frame.height)!/2)-30, leftx: 0, lefty: 0, rightx: 0, righty: 0)
    }
    
    func save() {
        var f = [[String]]()
        for frame in frames {
            f.append(frame.toString())
        }
        
        UserDefaults.standard.set(f, forKey: "Frames")
        
        var r = [[Any]]()
        for rig in rigs {
            r.append(rig.toData())
        }
        
        UserDefaults.standard.set(r, forKey: "Rigs")
        
        UserDefaults.standard.set(String(describing: selected), forKey: "Selected")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let p = t.location(in: self)
            if (rigs.count > 0) {
                if (attaching == false) {
                    for i in 0...rigs.count-1 {
                        let r = rigs[i]
                        r.changeZ(to: 0)
                        r.middle.fillColor = UIColor.gray
                        r.selected = false
                        if (r.select(p: p)) {
                            selected = i
                        }
                    }
                    
                    if (selected != -1) {
                        rigs[selected].selected = true
                        rigs[selected].changeZ(to: 5)
                        
                        rigs[selected].middle.fillColor = UIColor.green
                    }
                    
                    for r in rigs {
                        r.checkTouch(p: p)
                    }
                } else {
                    for i in 0...rigs.count-1 {
                        let r = rigs[i]
                        if (r.middle.contains(p) || r.red.contains(p) || r.blue.contains(p)) {
                            rigs[selected].attachTo(rig: rigs[i], type: type)
                            attaching = false
                        }
                    }
                }
            }
            
            if (set.pressed(p: p)) {
                if (rigs.count > 0) {
                    if (selected != -1) {
                        rigs[selected].setFrame(scene: self)
                    }
                }
                save()
            }
            
            if (setImage.pressed(p: p)) {
                if (selected != -1) {
                    save()
                    
                    getPhotoFromSource(source: UIImagePickerControllerSourceType.photoLibrary)
                }
                save()
            }
            
            if (add.pressed(p: p)) {
                let r = Rig(scene: self)
                rigs.append(r)
                
                for i in 0...35 {
                    let frame = frames[i]
                    frame.addRig(r: r.pos)
                }
                
                
                save()
            }
            
            if (delete.pressed(p: p)) {
                if (rigs.count > 0) {
                    if (selected != -1) {
                        let r = rigs[selected]
                        
                        rigs.remove(at: selected)
                        for i in 0...frames.count-1 {
                            let frame = frames[i]
                            frame.remove(at: selected)
                        }
                        
                        r.remove()
                        selected = -1
                    }
                }
                save()
            }
            
            if (attach.pressed(p: p)) {
                if (attaching == false) {
                    if (attachFrom.label.text == "Red") {
                        if (attachTo.label.text == "Red") {
                            type = 1
                        } else {
                            type = 2
                        }
                    } else {
                        if (attachTo.label.text == "Red") {
                            type = 3
                        } else {
                            type = 4
                        }
                    }
                    
                    attaching = true
                //rigs[0].attachTo(rig: rigs[1], type: type)
                } else {
                    attaching = false
                }
                save()
            }
            
            if (attachTo.pressed(p: p)) {
                if (attachTo.label.text == "Red") {
                    attachTo.label.text = "Blue"
                    attachTo.label.fontColor = SKColor.blue
                } else {
                    attachTo.label.text = "Red"
                    attachTo.label.fontColor = SKColor.red
                }
                save()
            }
            
            if (attachFrom.pressed(p: p)) {
                if (attachFrom.label.text == "Red") {
                    attachFrom.label.text = "Blue"
                    attachFrom.label.fontColor = SKColor.blue
                } else {
                    attachFrom.label.text = "Red"
                    attachFrom.label.fontColor = SKColor.red
                }
                save()
            }
            
            if (merge.pressed(p: p)) {
                if (selected != -1) {
                    if (rigs[selected].texture != nil) {
                        //rigs[selected].setImage(to: bendImage(in: rigs[selected].texture!)!)
                        if (rigs[selected].following != nil && rigs[selected].texture != nil) {
                            rigs[selected].merged = true
                            rigs[selected].setImage(to: rigs[selected].bendImage(in: rigs[selected].texture!)!)
                        }
                    }
                }
            }
            
            if (slider.contains(p)) {
                /*if (rigs.count > 0) {
                    rigs[selected].selected = true
                    rigs[selected].changeZ(to: 5)
                    rigs[selected].middle.fillColor = UIColor.green
                }*/
                touchingSlider = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let p = t.location(in: self)
            for r in rigs {
                r.moveRed(to: p)
                r.moveBlue(to: p)
                r.moveGreen(to: p)
                r.movePurple(to: p)
                r.moveTopLeft(to: p)
                r.moveTopRight(to: p)
                r.moveBottomLeft(to: p)
                r.moveBottomRight(to: p)
            }
            
            for r in rigs {
                r.follow()
            }
            
            for r in rigs {
                r.moveAll(to: p)
            }
            
            if (touchingSlider == true) {
                if (p.x > keys.position.x-keys.frame.width/2 && p.x < keys.position.x+keys.frame.width/2) {
                    slider.position.x = p.x-15
                    let frameSize = (keys.frame.width)/CGFloat(numberOfFrames)
                    let distance = ((slider.position.x-(keys.position.x-keys.frame.width/2)))
                    frameAt = Int((distance/frameSize)+0.5)
                }
                
                if (rigs.count > 0) {
                    for i in 0...rigs.count-1 {
                        //print(loadFrame(index: i).toString())
                        rigs[i].move(to: loadFrame(index: i))
                    }
                    
                    for r in rigs {
                        r.follow()
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let p = t.location(in: self)
            for r in rigs {
                r.touch = 0
            }
            touchingSlider = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let p = t.location(in: self)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func setDividers(amount: Int, image: UIImage) -> UIImage {
        let rect = CGRect(origin: .zero, size: keys.frame.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let color = UIColor.clear
        color.setFill()
        UIRectFill(rect)
        let imageClear = UIGraphicsGetImageFromCurrentImageContext()
        
        guard let inputCGImage = image.cgImage else {
            print("unable to get cgImage")
            return imageClear!
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = inputCGImage.width
        let height = inputCGImage.height
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * (width)
        let bitmapInfo = RGBA32.bitmapInfo
        
        var values: [Int] = []
        for i in 0...amount-1 {
            values.append((i+1)*Int(round((image.size.width*2)/CGFloat(amount))))
        }
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return imageClear!
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("unable to get context data")
            return imageClear!
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: (width) * height)
        
        for r in 0...height-1 {
            for c in 0...(width)-1 {
                let o = r * (width) + c
                pixelBuffer[o] = .clear
                
                if (values.contains(c) || values.contains(c-1) || values.contains(c+1)) {
                    pixelBuffer[o] = .white
                }
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage)
        
        return outputImage
    }
    
    /*func bendImage(in image: UIImage) -> UIImage? {
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
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: (width) * height)
        
        var resizedPixels = [RGBA32]()
        
        for r in 0...height-1 {
            for c in 0...(width)-1 {
                let o = r * (width) + c
                if (c > width/2) {
                    resizedPixels.append(pixelBuffer[r * (width) + (width/2)+((c-width/2)/2)])
                } else {
                    resizedPixels.append(pixelBuffer[o])
                }
            }
        }
        
        for r in 0...height-1 {
            for c in 0...(width)-1 {
                let o = r * (width) + c
                if (c > width/2) {
                    pixelBuffer[o] = resizedPixels[o]
                }
            }
        }
        
        
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage)
        //outputImage. = CGSize(width: image.size.width+20, height: image.size.height)
        
        return outputImage
    }*/
    
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

struct Pixel {
    var r: Float
    var g: Float
    var b: Float
    var a: Float
    var row: Int
    var col: Int
    
    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8, row: Int, col: Int) {
        self.r = Float(r)
        self.g = Float(g)
        self.b = Float(b)
        self.a = Float(a)
        self.row = row
        self.col = col
    }
    
    var color: UIColor {
        return UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: CGFloat(a/255.0))
    }
    
    var description: String {
        return "RGBA(\(r), \(g), \(b), \(a))"
    }
}

extension GameScene {
    func getPhotoFromSource(source:UIImagePickerControllerSourceType ){
        if UIImagePickerController.isSourceTypeAvailable(source)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.modalPresentationStyle = .currentContext
            imagePicker.delegate = self
            imagePicker.sourceType = source
            imagePicker.allowsEditing = false
            if (source == .camera){
                imagePicker.cameraDevice = .front
            }
            let vc:UIViewController = self.view!.window!.rootViewController!
            vc.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        picker.dismiss(animated: true, completion: nil)
        picker.delegate = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if (picker.sourceType == UIImagePickerControllerSourceType.photoLibrary || picker.sourceType == UIImagePickerControllerSourceType.camera ) {
            //do something with the image we picked
            if let cameraRollPicture = info[UIImagePickerControllerOriginalImage] as? UIImage {
                var scene: EditImage = EditImage(size: self.size)
                scene.image = cameraRollPicture
                scene.scaleMode = .resizeFill
                self.view?.presentScene(scene, transition: .reveal(with: .left, duration: 0.2))
            }
        }
        picker.dismiss(animated: true, completion: nil)
        picker.delegate = nil
    }
}
