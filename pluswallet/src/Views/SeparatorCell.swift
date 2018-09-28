//
//  SeparatorCell.swift
//  pluswallet
//
//  Created by Zan on 2017-04-01.
//  Copyright © 2017 pluswallet LLC. All rights reserved.
//

import UIKit

class SeparatorCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separator = UIView()
        let separator2 = UIView()
        separator.backgroundColor = UIColor.white
        separator2.backgroundColor = UIColor.white
        addSubview(separator)
        addSubview(separator2)
        contentView.backgroundColor = .clear
        backgroundColor = .transparentCellBackground
        selectedBackgroundView = UIView.init(color: UIColor.navigationTint.withAlphaComponent(0.7))
        separator.constrain([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 3.0) ])
        separator2.constrain([
            separator2.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator2.topAnchor.constraint(equalTo: topAnchor),
            separator2.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator2.heightAnchor.constraint(equalToConstant: 7.0) ])

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
