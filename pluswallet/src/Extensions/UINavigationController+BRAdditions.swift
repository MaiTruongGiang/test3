//  UINavigationController+BRAdditions.swift
//  PlusWallet
//
//  Created by Chien Kieu on 2018/07/11.
//  Copyright © 2018年 株式会社エンジ. All rights reserved.
//

import UIKit

extension UINavigationController {

    func setDefaultStyle() {
        setClearNavbar()
        navigationBar.tintColor = .mediumGray
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.customBold(size: 16.0)
        ]
    }

    func setWhiteStyle() {
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.customBold(size: 16.0)
        ]
    }

    func setGrayStyle() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = .whiteBackground
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.customBold(size: 16.0)
        ]
    }

    func setGradientBlueStyle() {
        navigationBar.applyNavigationGradient(colors: [UIColor.gradientStart, UIColor.gradientEnd])
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = .whiteBackground
        navigationBar.tintColor = .whiteBackground
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.customBold(size: 16.0)
        ]
    }

    func setClearNavbar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }

    func setNormalNavbar() {
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
    }
    func setGradient() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.applyNavigationGradient(colors: [UIColor.gradientStart, UIColor.gradientEnd])
        navigationController?.navigationBar.tintColor = .white
    }
}
