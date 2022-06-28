//
//  UIColor+Extensions.swift
//  HelloTamnaAR
//
//  Created by Hyeonsoo Kim on 2022/06/28.
//

import Foundation
import UIKit

extension UIColor {
    
    static func random() -> UIColor {
        UIColor(displayP3Red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1), alpha: 1)
    }
    
}
