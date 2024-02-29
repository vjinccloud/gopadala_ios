//
//  UIView+Extension.swift
//  indogo
//
//  Created by mac on 2020/9/5.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

extension UIView {
    //對UIView做截圖
    func takeScreenshot() -> UIImage {

        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
    
    func setGradietColor(colorOne: UIColor, colorTwo: UIColor) {
        self.clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        //gradientLayer.locations = [0.0,0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        layer.insertSublayer(gradientLayer, at: 0)
        //return layer
    }
    
    func removeGradienLayer() {
        if self.layer.sublayers == nil {
            return
        }
        for sublayer in self.layer.sublayers! {
            if sublayer is CAGradientLayer {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    func addGradienOfIndoGo() {
        self.setGradietColor(colorOne: Color_Gradient_Right, colorTwo: Color_Gradient_Left)
    }
}

