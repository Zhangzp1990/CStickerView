//
//  UIColor+Extension.swift
//
//  Created by zhangzp on 2023/7/15.
//

import Foundation
import UIKit

extension UIColor {
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}
