//
//  UIView+Extension.swift
//  indogo
//
//  Created by mac on 2020/9/5.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

private let layoutAwareIndoGoGradientName = "layoutAwareIndoGoGradient"

extension UIView {
    func installLayoutAwareIndoGoGradient() {
        guard layer.sublayers?.contains(where: {
            $0.name == layoutAwareIndoGoGradientName
        }) != true else {
            return
        }
        
        clipsToBounds = true
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = layoutAwareIndoGoGradientName
        gradientLayer.colors = [
            Color_Gradient_Right.cgColor,
            Color_Gradient_Left.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        layer.insertSublayer(gradientLayer, at: 0)
        updateLayoutAwareIndoGoGradientFrame()
    }
    
    // 可重複執行，但只更新同一個 layer 的尺寸
    func updateLayoutAwareIndoGoGradientFrame() {
        guard let gradientLayer = layer.sublayers?.first(where: {
            $0.name == layoutAwareIndoGoGradientName
        }) as? CAGradientLayer else {
            return
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        CATransaction.commit()
    }
    
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

