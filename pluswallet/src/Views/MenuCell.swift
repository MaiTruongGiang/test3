//
//  MenuCell.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2018-01-31.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    static let cellIdentifier = "MenuCell"

    private let container = UIView(color: .whiteBackground)
    private let iconView = UIImageView()
    private let label = UILabel(font: .customBold(size: 16.0), color: .darkText)
    private let arrow = UIImageView(image: #imageLiteral(resourceName: "right_green").withRenderingMode(.alwaysOriginal))

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    func set(title: String, icon: UIImage) {
        label.text = title

        iconView.image = icon.withRenderingMode(.alwaysOriginal)

    }

    private func setup() {
        addSubviews()
        addConstraints()
        setupStyle()
    }

    private func addSubviews() {
        contentView.addSubview(container)
        container.addSubview(iconView)
        container.addSubview(label)
        container.addSubview(arrow)
    }

    private func addConstraints() {
        container.constrain(toSuperviewEdges: UIEdgeInsets(top: 0.0,
                                                           left: 0.0,
                                                           bottom: 0.0,
                                                           right: 0.0))

        iconView.constrain([
            iconView.widthAnchor.constraint(equalToConstant: 32.0),
            iconView.heightAnchor.constraint(equalToConstant: 32.0),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: C.padding[2]),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])

        label.constrain([
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: C.padding[1]),
            label.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: C.padding[1]),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])

        arrow.constrain([
//            arrow.widthAnchor.constraint(equalToConstant: 24.0),
//            arrow.heightAnchor.constraint(equalTo: arrow.widthAnchor),
            arrow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -C.padding[1]),
            arrow.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
    }

    private func setupStyle() {
        selectionStyle = .blue
        contentView.backgroundColor = .whiteBackground
//        iconView.tintColor = .darkGray
//        arrow.tintColor = .darkGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
