//
//  UIView+Extension.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

import Foundation
import UIKit

extension UIView{
    
    
    func applyCornerRadius(radius: CGFloat = 10.0) {
        layoutIfNeeded()
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func onlyBottomCornerRadius(withRadius radius:CGFloat = 10.0){
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
}
