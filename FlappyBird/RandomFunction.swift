//
//  RandomFunction.swift
//  FlappyBird
//
//  Created by Dong fenfang on 8/14/18.
//  Copyright © 2018 Dong fenfang. All rights reserved.
//

import Foundation
import CoreGraphics
public extension CGFloat{
    
    public static func random() ->CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    public static func random(min : CGFloat, max: CGFloat) -> CGFloat{
        return CGFloat.random() * (max - min) + min
    }
}
