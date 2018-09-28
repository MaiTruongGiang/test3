//
//  MenuSettingItem.swift
//  pluswallet
//
//  Created by zan on 2018/08/03.
//  Copyright © 2018年 株式会社エンジ. All rights reserved.
//

import UIKit

struct MenuSettingItem {
    let title: String
    let icon: UIImage?
    let accessoryText :(() -> String)?
    let callback : () -> Void

    init(title: String, icon: UIImage? = nil, accessoryText : (() -> String)? = nil, callback : @escaping () -> Void) {
        self.title = title
        self.icon = icon?.withRenderingMode(.alwaysTemplate)
        self.accessoryText = accessoryText
        self.callback = callback
    }

    init(title: String, icon: UIImage? = nil, subMenu: [MenuSettingItem], rootNav: UINavigationController) {
        let subMenuVC = MenuSettingViewController(items: subMenu, title: title)
        self.init(title: title, icon: icon, accessoryText: nil) {
            rootNav.pushViewController(subMenuVC, animated: true)
        }
    }
}
