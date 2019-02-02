//
//  File.swift
//  animation
//
//  Created by Thomas Liang on 6/27/18.
//  Copyright © 2018 Thomas Liang. All rights reserved.
//

import Foundation
import SpriteKit

class Frame {
    var rigs = [Position]()
    
    init() {
    }

    func addRig(r: Position) {
        let p = Position(topx: r.topX, topy: r.topY, bottomx: r.bottomX, bottomy: r.bottomY, leftx: 0, lefty: 0, rightx: 0, righty: 0)
        rigs.append(p)
    }
    
    func setRig(at: Int, to: Position) {
        let p = Position(topx: to.topX, topy: to.topY, bottomx: to.bottomX, bottomy: to.bottomY, leftx: 0, lefty: 0, rightx: 0, righty: 0)
        rigs[at] = p
    }
    
    func removeAll() {
        rigs.removeAll()
    }
    
    func remove(at: Int) {
        //print(rigs.count)
        //print(at)
        rigs.remove(at: at)
    }
    
    func toString () -> [String] {
        var ret = [String]()
        for p in rigs {
            ret.append(p.toString())
        }
        
        return ret
    }
}
