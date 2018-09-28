//
//  TokenListTableViewCell.swift
//  PlusWallet
//
//  Created by 株式会社エンジ on 2018/07/11.
//  Copyright © 2018年 PlusWallet LLC. All rights reserved.
//

import UIKit

class TokenListTableViewCell: UITableViewCell, Subscriber {

    static let cellIdentifier = "TokenListCell"

    private let currencyName = UILabel(font: .customBold(size: 16.0), color: .white)
    private let tokenBalance = UILabel(font: .customBold(size: 20.0), color: .white)
    private let price = UILabel(font: .customBold(size: 14.0), color: UIColor.white)
    private let fiatBalance = UILabel(font: .customBold(size: 18.0), color: .white)
    private let container  = Background()
    private let symbol = UIImageView()
    private let syncIndicator = SyncingIndicator(style: .home)

    private var isSyncIndicatorVisible: Bool = false {
        didSet {
            UIView.crossfade(tokenBalance, syncIndicator, toRight: isSyncIndicatorVisible, duration: isSyncIndicatorVisible == oldValue ? 0.0 : 0.3)
            fiatBalance.textColor = isSyncIndicatorVisible ? .disabledWhiteText : .white
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    private func setupViews() {
        addSubviews()
        addConstraints()
        setupStyle()
    }
    func set(viewModel: AssetListViewModel) {
        accessibilityIdentifier = viewModel.currency.name
        container.currency = viewModel.currency
        currencyName.text = viewModel.currency.name
        tokenBalance.text = viewModel.tokenBalance
        price.text = viewModel.exchangeRate
        fiatBalance.text = viewModel.fiatBalance
        container.setNeedsDisplay()

        guard let code: String = viewModel.currency.code.lowercased() else { return  }
        symbol.image = UIImage(named: code)

        Store.subscribe(self, selector: { $0[viewModel.currency]?.syncState != $1[viewModel.currency]?.syncState },
                        callback: { state in
                            guard let syncState = state[viewModel.currency]?.syncState else { return }
                            switch syncState {
                            case .connecting:
                                self.isSyncIndicatorVisible = true
                                self.syncIndicator.text = S.SyncingView.connecting
                            case .syncing:
                                self.isSyncIndicatorVisible = true
                                self.syncIndicator.text = S.SyncingView.syncing
                            case .success:
                                self.isSyncIndicatorVisible = false
                            }
        })

        Store.subscribe(self, selector: {
            return $0[viewModel.currency]?.lastBlockTimestamp != $1[viewModel.currency]?.lastBlockTimestamp },
                        callback: { state in
                            if let progress = state[viewModel.currency]?.syncProgress {
                                self.syncIndicator.progress = CGFloat(progress)
                            }
        })

    }

    private func addSubviews() {
        contentView.addSubview(container)
        container.addSubview(currencyName)
        container.addSubview(price)
        container.addSubview(tokenBalance)
        container.addSubview(symbol)
        container.addSubview(syncIndicator)
        container.addSubview(fiatBalance)

        syncIndicator.isHidden = true

    }
    func refreshAnimations() {
        syncIndicator.pulse()
    }
    private func addConstraints() {

        container.constrain(toSuperviewEdges: UIEdgeInsets(top: C.padding[1]*0.5,
                                                           left: C.padding[2],
                                                           bottom: -C.padding[1],
                                                           right: -C.padding[2]))
        symbol.constrain([
            symbol.topAnchor.constraint(equalTo: container.topAnchor, constant: C.padding[2]),
            symbol.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: C.padding[2]),
            symbol.heightAnchor.constraint(equalToConstant: 40),
            symbol.widthAnchor.constraint(equalToConstant: 40)
            ])

        currencyName.constrain([
            currencyName.topAnchor.constraint(equalTo: symbol.topAnchor),
            currencyName.leadingAnchor.constraint(equalTo: symbol.trailingAnchor, constant: 20)
            ])
        tokenBalance.constrain([
            tokenBalance.topAnchor.constraint(equalTo: currencyName.bottomAnchor, constant: 8),
            tokenBalance.leadingAnchor.constraint(equalTo: currencyName.leadingAnchor)
            ])
        price.constrain([
            price.topAnchor.constraint(equalTo: tokenBalance.bottomAnchor, constant: 8),
            price.leadingAnchor.constraint(equalTo: currencyName.leadingAnchor)

            ])
        fiatBalance.constrain([
            fiatBalance.topAnchor.constraint(equalTo: container.topAnchor, constant: C.padding[1]),
            fiatBalance.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -C.padding[2]),
            fiatBalance.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1/2)
            ])
        syncIndicator.constrain([
            syncIndicator.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -C.padding[2]),
            syncIndicator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -C.padding[1]),
            syncIndicator.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 2/5)
            ])
    }

    override func prepareForReuse() {
        Store.unsubscribe(self)
    }

    deinit {
        Store.unsubscribe(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    func refreshAnimations() {
//        syncIndicator.pulse()
//    }
    private func setupStyle() {
        selectionStyle = .none
        backgroundColor = .clear
        fiatBalance.textAlignment = .right
        container.clipsToBounds = true
        container.layer.cornerRadius = 7
    }

}
