//
//  GradientViewLogin.swift
//  pluswallet
//
//  Created by zan on 2018/08/16.
//  Copyright © 2018年  株式会社エンジ LLC. All rights reserved.
//

import UIKit

@IBDesignable
class GradientViewLogin: UIView {

    var gradientLayer: CAGradientLayer?

    @IBInspectable var topColor: UIColor = UIColor.white {
        didSet {
            setGradation()
        }
    }

    @IBInspectable var bottomColor: UIColor = UIColor.black {
        didSet {
            setGradation()
        }
    }

    private func setGradation() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = CAGradientLayer()
        gradientLayer!.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer!.frame.size = frame.size
        layer.addSublayer(gradientLayer!)
        layer.masksToBounds = true
    }
}
