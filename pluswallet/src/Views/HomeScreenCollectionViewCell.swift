//
//  HomeScreenCollectionViewCell.swift
//  PlusWallet
//
//  Created by Zan on 2018/07/15.
//  Copyright © 2018年 PlusWallet LLC. All rights reserved.
//

import UIKit

class HomeScreenCollectionViewCell: UICollectionViewCell, Subscriber {
    static let cellIdentifier = "HomeScreenCell"
    private let currencyName = UILabel(font: .customBold(size: 22.0), color: .white)
    private let price = UILabel(font: .customBold(size: 14.0), color: .transparentWhiteText)
    private let fiatBalance = UILabel(font: .customBold(size: 18.0), color: .white)
    private let tokenBalance = UILabel(font: .customBold(size: 14.0), color: .transparentWhiteText)// số dư BTC
    private let syncIndicator = SyncingIndicator(style: .home)
    private let container = Background()
    private let symbol = UIImageView()
    private let sendbtn = ShadowButton(title: S.Button.send, type: .greenPlus)
    private let receivebtn = ShadowButton(title: S.Button.receive, type: .bluePlus)

    private let footerView = UIView()

    private var isSyncIndicatorVisible: Bool = false {
        didSet {
            UIView.crossfade(tokenBalance, syncIndicator, toRight: isSyncIndicatorVisible, duration: 0.3)
            fiatBalance.textColor = isSyncIndicatorVisible ? .disabledWhiteText : .white
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func set(viewModel: AssetListViewModel) {
        accessibilityIdentifier = viewModel.currency.name

        container.currency = viewModel.currency
        currencyName.text = viewModel.currency.name
        price.text = viewModel.exchangeRate
        fiatBalance.text = viewModel.fiatBalance
        tokenBalance.text = viewModel.tokenBalance
        sendbtn.tap = { Store.perform(action: RootModalActions.Present(modal: .send(currency: viewModel.currency))) }
        receivebtn.tap = { Store.perform(action: RootModalActions.Present(modal: .receive(currency: viewModel.currency))) }
//        footerView.sendCallback = { Store.perform(action: RootModalActions.Present(modal: .send(currency: viewModel.currency))) }
//        footerView.receiveCallback = { Store.perform(action: RootModalActions.Present(modal: .receive(currency: viewModel.currency))) }
//        footerView.buyCallback = { Store.perform(action: RootModalActions.Present(modal: .buy(currency: viewModel.currency))) }
//        footerView.sellCallback = { Store.perform(action: RootModalActions.Present(modal: .sell(currency: viewModel.currency))) }
//        icon.text = viewModel.currency.symbol
        container.setNeedsDisplay()
  //      print(viewModel)

        //viet them thuoc tinh anh

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

    private func setupViews() {
        addSubviews()
        addConstraints()
        setupStyle()

    }

    private func addSubviews() {
        contentView.addSubview(container)
        container.addSubview(currencyName)
        container.addSubview(price)
        container.addSubview(fiatBalance)
        container.addSubview(tokenBalance)
        container.addSubview(syncIndicator)
        container.addSubview(symbol)
        container.addSubview(footerView)
        footerView.addSubview(sendbtn)
        footerView.addSubview(receivebtn)
        syncIndicator.isHidden = true
    }

    private func addConstraints() {
        container.constrain(toSuperviewEdges: UIEdgeInsets(top: C.padding[1]*0.5,
                                                           left: C.padding[2],
                                                           bottom: -C.padding[1],
                                                           right: -C.padding[1]))
        symbol.constrain([
            symbol.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: C.padding[3]),
            symbol.topAnchor.constraint(equalTo: container.topAnchor, constant: C.padding[3]),
            symbol.heightAnchor.constraint(equalToConstant: C.padding[10]),
            symbol.widthAnchor.constraint(equalToConstant: C.padding[10])
            ])
        currencyName.constrain([
            currencyName.leadingAnchor.constraint(equalTo: symbol.trailingAnchor, constant: C.padding[2]),
            currencyName.topAnchor.constraint(equalTo: container.topAnchor, constant: C.padding[2])
            ])

        price.constrain([
            price.leadingAnchor.constraint(equalTo: currencyName.leadingAnchor),
            price.topAnchor.constraint(equalTo: currencyName.bottomAnchor, constant: C.padding[1]),
            price.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -C.padding[2] )
            ])

        fiatBalance.constrain([
            fiatBalance.leadingAnchor.constraint(equalTo: currencyName.leadingAnchor),
            fiatBalance.topAnchor.constraint(equalTo: price.bottomAnchor, constant: C.padding[1]),
            fiatBalance.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -C.padding[2] )
            ])

        tokenBalance.constrain([
            tokenBalance.leadingAnchor.constraint(equalTo: currencyName.leadingAnchor),
            tokenBalance.topAnchor.constraint(equalTo: fiatBalance.bottomAnchor, constant: C.padding[1]),
            tokenBalance.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -C.padding[2])
            ])

        syncIndicator.constrain([
            syncIndicator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            //syncIndicator.topAnchor.constraint(equalTo: tokenBalance.bottomAnchor, constant: C.padding[1] ),
            syncIndicator.bottomAnchor.constraint(equalTo: footerView.topAnchor, constant: -C.padding[2]),
            syncIndicator.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1/2)
            ])
        footerView.constrain([
            footerView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: -C.padding[1]),
            footerView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: C.padding[1]),
            footerView.heightAnchor.constraint(equalToConstant: accountFooterHeight)
            ])
        sendbtn.constrain([
            sendbtn.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10),
            sendbtn.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -10),
            sendbtn.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: C.padding[4]),
            sendbtn.widthAnchor.constraint(equalTo: footerView.widthAnchor, multiplier: 1/3)
            ])
        receivebtn.constrain([
            receivebtn.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10),
            receivebtn.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -10),
            receivebtn.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -C.padding[4]),
            receivebtn.widthAnchor.constraint(equalTo: footerView.widthAnchor, multiplier: 1/3)
            ])
    }

    private func setupStyle() {
        sendbtn.clipsToBounds = true
        sendbtn.layer.cornerRadius = 7
        sendbtn.layer.borderWidth = 2
        sendbtn.layer.borderColor = UIColor.lightGray.cgColor
        receivebtn.clipsToBounds = true
        receivebtn.layer.cornerRadius = 7
        receivebtn.layer.borderWidth = 2
        receivebtn.layer.borderColor = UIColor.lightGray.cgColor
        container.layer.cornerRadius = 10
        container.clipsToBounds = true
        //selectionStyle = .none
        footerView.backgroundColor = UIColor.black
        backgroundColor = .clear
    }

    override func prepareForReuse() {
        Store.unsubscribe(self)
    }

    deinit {
        Store.unsubscribe(self)
    }

}
