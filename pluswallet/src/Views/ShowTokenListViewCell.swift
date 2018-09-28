//
//  ShowTokenListViewCell.swift
//  pluswallet
//
//  Created by 株式会社エンジ on 2018/07/12.
//  Copyright © 2018年 breadwallet LLC. All rights reserved.
//

import UIKit

class ShowTokenCell: UITableViewCell {

    private let header = UILabel(font: .customBold(size: 18.0), color: UIColor.fromHex("546875"))
    private let subheader = UILabel(font: .customBody(size: 16.0), color: UIColor.fromHex("546875"))
    private let icon = UIImageView()
    private var identifier: String = ""
    private var isCurrencyHidden = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    func set(currency: CurrencyDef, isHidden: Bool) {
        header.text = currency.code
        subheader.text = currency.name
        icon.image = UIImage(named: currency.code.lowercased())
        self.isCurrencyHidden = isHidden
        if let token = currency as? ERC20Token {
            self.identifier = token.address
        } else {
            self.identifier = currency.code
        }
    }

    private func setupViews() {
        addSubviews()
        addConstraints()
        setInitialData()
    }

    private func addSubviews() {
        contentView.addSubview(header)
        contentView.addSubview(subheader)
        contentView.addSubview(icon)

    }

    private func addConstraints() {
        icon.constrain([
            icon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: C.padding[1]),
            icon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -C.padding[1]),
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: C.padding[2]),
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            icon.heightAnchor.constraint(equalToConstant: 40.0),
            icon.widthAnchor.constraint(equalToConstant: 40.0)])
        header.constrain([
            header.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: C.padding[1]),
            header.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 1.0)])
        subheader.constrain([
            subheader.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: C.padding[1]),
            subheader.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1.0)])

    }

    private func setInitialData() {
        selectionStyle = .gray
        icon.contentMode = .scaleAspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
