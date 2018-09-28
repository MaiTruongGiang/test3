//
//  MenuSettingCell.swift
//  pluswallet
//
//  Created by zan on 2018/08/03.
//  Copyright © 2018年 pluswallet LLC. All rights reserved.
//

import UIKit

class MenuSettingCell: SeparatorCell {

    static let cellIdentifier = "MenuSettingCell"

    func set(item: MenuSettingItem) {
        backgroundColor = UIColor.whiteTint
        textLabel?.text = item.title
        textLabel?.font = UIFont.customBody(size: 17.0)
        textLabel?.textColor = UIColor.darkText

        imageView?.image = item.icon
        imageView?.tintColor = .blue

        if let accessoryText = item.accessoryText?() { // accessoryText tra ve la kieu String
            let lable = UILabel(font: .customMedium(size: 16.0), color: UIColor.grayText)
            lable.text = accessoryText
            lable.sizeToFit()
            accessoryView = lable
        } else {
            accessoryView = nil
            accessoryType = .none

        }
    }

}
