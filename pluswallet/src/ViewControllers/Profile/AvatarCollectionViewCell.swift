//
//  AvatarCollectionViewCell.swift
//  pluswallet
//
//  Created by Kieu Quoc Chien on 2018/07/23.
//  Copyright © 2018 株式会社エンジ LLC. All rights reserved.
//

import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "AvatarCollectionCell"

    let imageView = UIImageView()
    let imageTicked = UIImageView(image: #imageLiteral(resourceName: "icon_check_circle"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubviews()
        addConstraints()
        setupStyle()
    }

    private func addSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(imageTicked)
    }

    private func addConstraints() {
        imageView.constrain([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor) ])

        imageTicked.constrain([
            imageTicked.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            imageTicked.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            imageTicked.widthAnchor.constraint(equalTo: imageView.widthAnchor, constant: C.padding[1]),
            imageTicked.heightAnchor.constraint(equalTo: imageView.heightAnchor, constant: C.padding[1]) ])
        imageTicked.isHidden = true
    }

    private func setupStyle() {
        //selectionStyle = .none
        backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit

        bringSubview(toFront: imageTicked)
    }

}
