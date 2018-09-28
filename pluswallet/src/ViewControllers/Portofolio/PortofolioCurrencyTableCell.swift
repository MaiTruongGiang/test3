//
//  PortofolioCurrencyTableCell.swift
//  pluswallet
//
//  Created by 株式会社エンジ on 2018/07/26.
//  Copyright © 2018年 PlusWallet LLC. All rights reserved.
//

import UIKit

class PortofolioCurrencyTableCell: UITableViewCell, Subscriber {

    static let cellIdentifier = "PortofolioCurrencyList"

    private let currencyName = UILabel(font: .systemFont(ofSize: 16))
    private let tokenBalance = UILabel(font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium))
    private let fiatBalance = UILabel(font: .systemFont(ofSize: 16.0))
    private let price = UILabel(font: .systemFont(ofSize: 16))
    private let container  = UIView()
    private let subView = UIView()
    private let symbol = UIImageView()
    private let updownIcon = UIImageView(image: UIImage(named: "portofolio_up"))
    private let updownlbl = UILabel(font: .systemFont(ofSize: 15), color: .green)
    private let underView = UIView(color: UIColor.lightGray)
    private let syncIndicator = SyncingIndicator(style: .portofolio)

        private var isSyncIndicatorVisible: Bool = false {
            didSet {
                UIView.crossfade(tokenBalance, syncIndicator, toRight: isSyncIndicatorVisible, duration: isSyncIndicatorVisible == oldValue ? 0.0 : 0.3)
                fiatBalance.textColor = isSyncIndicatorVisible ? .disabledWhiteText : .black
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
        //container.currency = viewModel.currency
        currencyName.text = viewModel.currency.name
        tokenBalance.text = viewModel.tokenBalance
        price.text = viewModel.exchangeRate
        fiatBalance.text = viewModel.fiatBalance
        let updownPercent = viewModel.updownPercent
        if updownPercent < 0 {
            updownIcon.image = UIImage(named: "portofolio_down")
            updownlbl.textColor = .pink
        }
        updownlbl.text = String(fabs(updownPercent)) + "%" // fabs tri tuyet doi Double

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
    func refreshAnimations() {
        syncIndicator.pulse()
    }

    private func addSubviews() {
        contentView.addSubview(container)
        container.addSubview(currencyName)
        subView.addSubview(price)
        subView.addSubview(syncIndicator)
        container.addSubview(tokenBalance)
        container.addSubview(symbol)
        container.addSubview(subView)
        container.addSubview(fiatBalance)
        subView.addSubview(updownlbl)
        subView.addSubview(updownIcon)
        container.addSubview(underView)

    }
    private func addConstraints() {

        container.constrain(toSuperviewEdges: nil)
        symbol.constrain([
            //symbol.topAnchor.constraint(equalTo: container.topAnchor, constant: C.padding[2]),
            symbol.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            symbol.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: C.padding[2]),
            symbol.heightAnchor.constraint(equalToConstant: 40),
            symbol.widthAnchor.constraint(equalToConstant: 40)
            ])

        currencyName.constrain([
            currencyName.topAnchor.constraint(equalTo: container.topAnchor, constant: C.padding[2]),
            currencyName.leadingAnchor.constraint(equalTo: symbol.trailingAnchor, constant: 20)
            ])
        tokenBalance.constrain([
            tokenBalance.topAnchor.constraint(equalTo: currencyName.bottomAnchor, constant: 8),
            tokenBalance.leadingAnchor.constraint(equalTo: currencyName.leadingAnchor)
            ])
        price.constrain([
            price.centerYAnchor.constraint(equalTo: subView.centerYAnchor),
            price.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: -C.padding[1]),
            price.leadingAnchor.constraint(equalTo: subView.leadingAnchor)
            ])
        subView.constrain([
            subView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            subView.topAnchor.constraint(equalTo: container.topAnchor),
            subView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            subView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1/3)
            ])
        fiatBalance.constrain([
            fiatBalance.topAnchor.constraint(equalTo: tokenBalance.bottomAnchor, constant: C.padding[1]),
            fiatBalance.leadingAnchor.constraint(equalTo: currencyName.leadingAnchor)
            ])
        updownlbl.constrain([
            updownlbl.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: -C.padding[1]),
            updownlbl.topAnchor.constraint(equalTo: subView.topAnchor, constant: C.padding[1])
            ])
        updownIcon.constrain([
            updownIcon.topAnchor.constraint(equalTo: updownlbl.topAnchor),
            updownIcon.trailingAnchor.constraint(equalTo: updownlbl.leadingAnchor, constant: -2),
            updownIcon.bottomAnchor.constraint(equalTo: updownlbl.bottomAnchor),
            updownIcon.widthAnchor.constraint(equalTo: updownlbl.heightAnchor)
            ])
        underView.constrain([
            underView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            underView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            underView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            underView.heightAnchor.constraint(equalToConstant: 1)
            ])
        syncIndicator.constrain([
            syncIndicator.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: -C.padding[1]),
            syncIndicator.leadingAnchor.constraint(equalTo: subView.leadingAnchor),
            syncIndicator.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -C.padding[2])
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

    private func setupStyle() {
        selectionStyle = .none
        backgroundColor = .clear
        container.backgroundColor = .whiteBackground
        symbol.layer.cornerRadius = 20
        symbol.contentMode = .scaleAspectFill
        symbol.layer.masksToBounds = true
        subView.backgroundColor = .whiteBackground
        price.textAlignment = .right
        price.numberOfLines = 2
        updownlbl.textAlignment = .right
        syncIndicator.progressBar.backgroundColor = .blue

    }

}
