//
//  ReceiveViewController.swift
//  PlusWallet
//
//  Created by Zan on 2018-7-23.
//  Copyright © 2018 PlusWallet LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

private let qrSize: CGFloat = 120.0
private let smallButtonHeight: CGFloat = 32.0
private let buttonPadding: CGFloat = 20.0
private let smallSharePadding: CGFloat = 12.0
private let largeSharePadding: CGFloat = 20.0
private let buttonSize: CGFloat = 44.0
typealias PresentShare = (String, UIImage) -> Void

class ReceiveViewController : UIViewController, UIScrollViewDelegate, Subscriber, Trackable {

    // MARK: - Public
    var presentEmail: PresentShare?
    var presentText: PresentShare?

    init(currency: CurrencyDef, isRequestAmountVisible: Bool) {
        self.currency = currency
        self.isRequestAmountVisible = isRequestAmountVisible
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Private
    private let currency: CurrencyDef
    private var address : String = ""
    private let scrollView = UIScrollView()
    private let subView = GradientView()
    private let rightViewBig = UIView()
    private let leftViewBig = UIView()
    private let rightView = UIView(color: .white)
    private let leftView = UIView(color: .white)
    private let header = UIView()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    private let close = UIButton.close
    private let headerTitlelbl: UILabel = {
       let lbl = UILabel()
        lbl.textColor = .white
        lbl.text = S.ReceiveViewController.receive
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        return lbl
    }()
    private let subHeaderTitlelbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.text = S.ReceiveViewController.receivePage
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        return lbl
    }()
    private let symbolHeader: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = C.padding[2]
        img.clipsToBounds = true
        img.layer.borderWidth = 1.5
        img.layer.borderColor = UIColor.white.cgColor
        return img
    }()
    private let symbol: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = C.padding[2]
        img.clipsToBounds = true
        img.layer.borderWidth = 1
        img.layer.borderColor = UIColor.white.cgColor
        return img
    }()
    private let nameCurrency = UILabel(font: UIFont.boldSystemFont(ofSize: 16), color: .white)
    private let avatar = UIImageView()
    private let name: UILabel = {
       let name  = UILabel()
        name.text = Store.state.userState.userName
        name.textAlignment = .center
        name.textColor = .white
        return name
    }()
    private var avatarIconConstraint = [NSLayoutConstraint]()
    private var avatarGallaryConstraint = [NSLayoutConstraint]()

    private let qrCode = UIImageView()
    private let addresslbl = UILabel(font: .customBody(size: 14.0))
    private let addressPopout = InViewAlert(type: .primary)
    private let share = ShadowButton(title: S.ReceiveViewController.shareQRCode, type: .greenPlus) //S.Receive.share
    private let copyAddressButton = ShadowButton(title: S.ReceiveViewController.copyQRCode, type:.greenPlus)
    private let attentionlbl : UILabel = {
        let lbl = UILabel()
        lbl.text = "※このアドレスは通貨の受け取り専用です。\n他の人に教えても通貨を盗まれることはありません。"
        lbl.numberOfLines = 2
        lbl.font = UIFont.customBody(size: 14)
        lbl.textColor = UIColor.gray
        lbl.textAlignment = .center
        return lbl
    }()
    private let sharePopout = InViewAlert(type: .secondary)
    private let border = UIView()
    private let request = ShadowButton(title: S.Receive.request, type: .secondary)
    private let addressButton = UIButton(type: .system)
    private var topSharePopoutConstraint: NSLayoutConstraint?
    fileprivate let isRequestAmountVisible: Bool
    private var requestTop: NSLayoutConstraint?
    private var requestBottom: NSLayoutConstraint?

    override func viewDidLoad() {
        scrollView.delegate = self
        addSubviews()
        addConstraints()
        setStyle()
        addActions()
        setupCopiedMessage()
        setupShareButtons()
        Store.subscribe(self, selector: { $0[self.currency]?.receiveAddress != $1[self.currency]?.receiveAddress }, callback: { _ in
            self.setReceiveAddress()
        })
    }

    private func addSubviews() {
        view.addSubview(header)
        header.addSubview(subHeaderTitlelbl)
        header.addSubview(close)
        view.addSubview(scrollView)
        scrollView.addSubview(subView)
        subView.addSubview(symbol)
        subView.addSubview(nameCurrency)
//        subView.addSubview(name)
        subView.addSubview(addresslbl)
        subView.addSubview(leftViewBig)
        subView.addSubview(rightViewBig)
        subView.addSubview(leftView)
        subView.addSubview(rightView)
        leftView.addSubview(avatar)
        leftView.addSubview(name)
        rightView.addSubview(qrCode)

//        view.addSubview(qrCode)
//        view.addSubview(address)
        scrollView.addSubview(addressPopout)
        scrollView.addSubview(share)
        scrollView.addSubview(copyAddressButton)
        scrollView.addSubview(sharePopout)
        //view.addSubview(border)
        scrollView.addSubview(attentionlbl)
       // view.addSubview(addressButton)
        
        stackView.addArrangedSubview(symbolHeader)
        stackView.addArrangedSubview(headerTitlelbl)
        
        header.addSubview(stackView)
        header.addSubview(subHeaderTitlelbl)
    }
    private func addConstraints() {
       
        header.constrain([
            header.topAnchor.constraint(equalTo: view.topAnchor ),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor ),
            header.heightAnchor.constraint(equalToConstant: E.isIPhoneX ? 150 : 138 )
            ])
        
        close.constrain([
            close.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -70),
            close.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -C.padding[2]),
            close.widthAnchor.constraint(equalToConstant: buttonSize),
            close.heightAnchor.constraint(equalToConstant: buttonSize)
            ])
        
        stackView.constrain([
            stackView.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: subHeaderTitlelbl.topAnchor, constant: -15)
            ])
        symbolHeader.constrain([
            symbolHeader.widthAnchor.constraint(equalToConstant: C.padding[4]),
            symbolHeader.heightAnchor.constraint(equalToConstant: C.padding[4] )
            ])

        subHeaderTitlelbl.constrain([
            subHeaderTitlelbl.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -20),
            subHeaderTitlelbl.centerXAnchor.constraint(equalTo: header.centerXAnchor)
            ])
        scrollView.constrain([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        subView.constrain([
            subView.topAnchor.constraint(equalTo: scrollView.topAnchor , constant: C.padding[3]),
            subView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            subView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1] ),
            subView.heightAnchor.constraint(equalToConstant: 250 )
            ])

        symbol.constrain([
            symbol.topAnchor.constraint(equalTo: subView.topAnchor, constant: C.padding[2] ),
            symbol.leadingAnchor.constraint(equalTo: subView.leadingAnchor, constant: C.padding[2]),
            symbol.widthAnchor.constraint(equalToConstant: C.padding[4]),
            symbol.heightAnchor.constraint(equalToConstant: C.padding[4] )
            ])

        nameCurrency.constrain([
            nameCurrency.topAnchor.constraint(equalTo: symbol.topAnchor, constant: 5),
            nameCurrency.leadingAnchor.constraint(equalTo: symbol.trailingAnchor, constant: C.padding[1])
            ])
        
        leftViewBig.constrain([
            leftViewBig.topAnchor.constraint(equalTo: symbol.bottomAnchor ),
            leftViewBig.leadingAnchor.constraint(equalTo: subView.leadingAnchor),
            leftViewBig.widthAnchor.constraint(equalTo: subView.widthAnchor, multiplier: 1/2),
            leftViewBig.heightAnchor.constraint(equalToConstant: 180)
            ])
        rightViewBig.constrain([
            rightViewBig.topAnchor.constraint(equalTo: leftViewBig.topAnchor),
            rightViewBig.trailingAnchor.constraint(equalTo: subView.trailingAnchor),
            rightViewBig.leadingAnchor.constraint(equalTo: leftViewBig.trailingAnchor),
            rightViewBig.bottomAnchor.constraint(equalTo: leftViewBig.bottomAnchor)
            ])
        rightView.constrain([
            rightView.topAnchor.constraint(equalTo: rightViewBig.topAnchor ),
            rightView.centerXAnchor.constraint(equalTo: rightViewBig.centerXAnchor, constant: -C.padding[1]),
            rightView.heightAnchor.constraint(equalToConstant: 160 ),
            rightView.widthAnchor.constraint(equalTo: rightView.heightAnchor)
            ])
        leftView.layer.cornerRadius = 50
        leftView.constrain([
           leftView.centerYAnchor.constraint(equalTo: leftViewBig.centerYAnchor, constant: -10),
           leftView.centerXAnchor.constraint(equalTo: leftViewBig.centerXAnchor),
           leftView.heightAnchor.constraint(equalToConstant: 100 ),
           leftView.widthAnchor.constraint(equalTo: leftView.heightAnchor)
            ])
        qrCode.constrain([
            qrCode.constraint(.width, constant: qrSize),
            qrCode.constraint(.height, constant: qrSize),
            qrCode.centerXAnchor.constraint(equalTo: rightView.centerXAnchor),
            qrCode.centerYAnchor.constraint(equalTo: rightView.centerYAnchor)
            ])
        avatar.constrain([
           avatar.centerXAnchor.constraint(equalTo: leftView.centerXAnchor),
           avatar.centerYAnchor.constraint(equalTo: leftView.centerYAnchor)
            ])
        avatarIconConstraint = [
            avatar.widthAnchor.constraint(equalToConstant: 70),
            avatar.heightAnchor.constraint(equalToConstant: 70)
        ]
        avatarGallaryConstraint = [
        avatar.widthAnchor.constraint(equalToConstant: 100),
        avatar.heightAnchor.constraint(equalToConstant: 100)
        ]
        name.constrain([
            name.topAnchor.constraint(equalTo: leftView.bottomAnchor, constant: C.padding[1]),
            name.centerXAnchor.constraint(equalTo: avatar.centerXAnchor)
            ])
        addresslbl.constrain([
            addresslbl.constraint(toBottom: rightView, constant: C.padding[1]),
            addresslbl.constraint(.leading, toView: subView),
            addresslbl.constraint(.trailing, toView: subView )])
        addressPopout.heightConstraint = addressPopout.constraint(.height, constant: 0.0)
        addressPopout.constrain([
            addressPopout.constraint(toBottom: addresslbl, constant: 0.0),
            addressPopout.constraint(.centerX, toView: view),
            addressPopout.constraint(.width, toView: view),
            addressPopout.heightConstraint ])
        share.constrain([
            share.topAnchor.constraint(equalTo: addressPopout.bottomAnchor, constant: 40),
            share.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            share.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/2, constant: -30),
            share.constraint(.height, constant: smallButtonHeight) ])
        copyAddressButton.constrain([
        copyAddressButton.topAnchor.constraint(equalTo: share.topAnchor),
        copyAddressButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        copyAddressButton.widthAnchor.constraint(equalTo: share.widthAnchor),
        copyAddressButton.heightAnchor.constraint(equalToConstant: smallButtonHeight)
        ])
        sharePopout.heightConstraint = sharePopout.constraint(.height, constant: 0.0)
        topSharePopoutConstraint = sharePopout.constraint(toBottom: share, constant: largeSharePadding)
        sharePopout.constrain([
            topSharePopoutConstraint,
            sharePopout.constraint(.centerX, toView: view),
            sharePopout.constraint(.width, toView: view),
            sharePopout.heightConstraint ])
//        border.constrain([
//            border.constraint(.width, toView: view),
//            border.constraint(toBottom: sharePopout, constant: 0.0),
//            border.constraint(.centerX, toView: view),
//            border.constraint(.height, constant: 1.0) ])
//        requestTop = request.constraint(toBottom: border, constant: C.padding[3])
//        requestBottom = request.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: E.isIPhoneX ? -C.padding[5] : -C.padding[2])
        attentionlbl.constrain([
            attentionlbl.topAnchor.constraint(equalTo: sharePopout.bottomAnchor, constant: C.padding[3]),
            attentionlbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
            attentionlbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            attentionlbl.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -C.padding[3])
//            attentionlbl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: E.isIPhoneX ? -C.padding[5] : -C.padding[2])
            ])
//        addressButton.constrain([
//            addressButton.leadingAnchor.constraint(equalTo: address.leadingAnchor, constant: -C.padding[1]),
//            addressButton.topAnchor.constraint(equalTo: qrCode.topAnchor),
//            addressButton.trailingAnchor.constraint(equalTo: address.trailingAnchor, constant: C.padding[1]),
//            addressButton.bottomAnchor.constraint(equalTo: address.bottomAnchor, constant: C.padding[1]) ])
    }

    private func setStyle() {
        view.backgroundColor = .whiteBackground
    //    avatar.image = UIImage(data: UserDefaults.profileAvatar as Data)
       avatar.image = UIImage(data: Store.state.userState.avatar )
        avatar.layer.masksToBounds = true
        //if UserDefaults.imageFromIcon {
        if !Store.state.userState.imageFromGallery {
            NSLayoutConstraint.activate(avatarIconConstraint)
            NSLayoutConstraint.deactivate(avatarGallaryConstraint)
        } else {
            NSLayoutConstraint.activate(avatarGallaryConstraint)
            NSLayoutConstraint.deactivate(avatarIconConstraint)
            avatar.contentMode = .scaleAspectFill
            avatar.layer.cornerRadius = 50
        }
        header.backgroundColor = currency.colors.0
        subView.layer.cornerRadius = 10
        subView.clipsToBounds = true
        addresslbl.textColor = .white
        addresslbl.textAlignment = .center
        addresslbl.adjustsFontSizeToFitWidth = true
        addresslbl.minimumScaleFactor = 0.7
        border.backgroundColor = .secondaryBorder
//        share.backgroundColor = .gradientEnd
        close.tintColor = .white
        share.isToggleable = true
        if !isRequestAmountVisible {
            border.isHidden = true
            request.isHidden = true
            request.constrain([
                request.heightAnchor.constraint(equalToConstant: 0.0) ])
            requestTop?.constant = 0.0
            requestBottom?.constant = 0.0
        }
        sharePopout.clipsToBounds = true
        symbol.image = UIImage(named: currency.code.lowercased())
        symbolHeader.image = UIImage(named: currency.code.lowercased())
        nameCurrency.text = currency.name

        setReceiveAddress()
    }

    private func setReceiveAddress() {
        guard let addressText = currency.state?.receiveAddress else { return }
        print(addressText)
        address = currency.matches(Currencies.bch) ? addressText.bCashAddr : addressText
        addresslbl.text = address
        qrCode.image = UIImage.qrCode(data: "\(addresslbl.text!)".data(using: .utf8)!, color: CIColor(color: .black))?
            .resize(CGSize(width: qrSize, height: qrSize))!
       // print(addresslbl.text)
    }

    private func addActions() {
        close.tap = {
            self.dismiss(animated: true, completion: nil)
        }
        copyAddressButton.tap = { [weak self] in
            self?.addressTapped()
        }
        request.tap = { [weak self] in
            guard let `self` = self, let modalTransitionDelegate = self.parent?.transitioningDelegate as? ModalTransitionDelegate else { return }
            modalTransitionDelegate.reset()
            self.dismiss(animated: true, completion: {
                Store.perform(action: RootModalActions.Present(modal: .requestAmount(currency: self.currency)))
            })
        }
        share.addTarget(self, action: #selector(ReceiveViewController.shareTapped), for: .touchUpInside)
    }

    private func setupCopiedMessage() {
        let copiedMessage = UILabel(font: .customMedium(size: 14.0))
        copiedMessage.textColor = .white
        copiedMessage.text = S.Receive.copied
        copiedMessage.textAlignment = .center
        addressPopout.contentView = copiedMessage
    }

    private func setupShareButtons() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let email = ShadowButton(title: S.Receive.emailButton, type: .tertiary)
        let text = ShadowButton(title: S.Receive.textButton, type: .tertiary)
        container.addSubview(email)
        container.addSubview(text)
        email.constrain([
            email.constraint(.leading, toView: container, constant: C.padding[2]),
            email.constraint(.top, toView: container, constant: buttonPadding),
            email.constraint(.bottom, toView: container, constant: -buttonPadding),
            email.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -C.padding[1]) ])
        text.constrain([
            text.constraint(.trailing, toView: container, constant: -C.padding[2]),
            text.constraint(.top, toView: container, constant: buttonPadding),
            text.constraint(.bottom, toView: container, constant: -buttonPadding),
            text.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: C.padding[1]) ])
        sharePopout.contentView = container
        email.addTarget(self, action: #selector(ReceiveViewController.emailTapped), for: .touchUpInside)
        text.addTarget(self, action: #selector(ReceiveViewController.textTapped), for: .touchUpInside)
    }

    @objc private func shareTapped() {
        toggle(alertView: sharePopout, shouldAdjustPadding: true)
        if addressPopout.isExpanded {
            toggle(alertView: addressPopout, shouldAdjustPadding: false)
        }
    }

    @objc private func addressTapped() {
        guard let text = addresslbl.text else { return }
        saveEvent("receive.copiedAddress")
        UIPasteboard.general.string = text
        toggle(alertView: addressPopout, shouldAdjustPadding: false, shouldShrinkAfter: true)
        if sharePopout.isExpanded {
            toggle(alertView: sharePopout, shouldAdjustPadding: true)
        }
    }

    @objc private func emailTapped() {
        presentEmail?(addresslbl.text!, qrCode.image!)
    }

    @objc private func textTapped() {
        presentText?(addresslbl.text!, qrCode.image!)
    }

    private func toggle(alertView: InViewAlert, shouldAdjustPadding: Bool, shouldShrinkAfter: Bool = false) {
        share.isEnabled = false
        addresslbl.isUserInteractionEnabled = false

        var deltaY = alertView.isExpanded ? -alertView.height : alertView.height
        if shouldAdjustPadding {
            if deltaY > 0 {
                deltaY -= (largeSharePadding - smallSharePadding)
            } else {
                deltaY += (largeSharePadding - smallSharePadding)
            }
        }

        if alertView.isExpanded {
            alertView.contentView?.isHidden = true
        }

        UIView.spring(C.animationDuration, animations: {
            if shouldAdjustPadding {
                let newPadding = self.sharePopout.isExpanded ? largeSharePadding : smallSharePadding
                self.topSharePopoutConstraint?.constant = newPadding
            }
            alertView.toggle()
            self.parent?.view.layoutIfNeeded()
        }, completion: { _ in
            alertView.isExpanded = !alertView.isExpanded
            self.share.isEnabled = true
            self.addresslbl.isUserInteractionEnabled = true
            alertView.contentView?.isHidden = false
            if shouldShrinkAfter {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    if alertView.isExpanded {
                        self.toggle(alertView: alertView, shouldAdjustPadding: shouldAdjustPadding)
                    }
                })
            }
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReceiveViewController: ModalDisplayable {
    var faqArticleId: String? {
        return ArticleIds.receiveBitcoin
    }

    var faqCurrency: CurrencyDef? {
        return currency
    }

    var modalTitle: String {
        return "\(S.Receive.title) \(currency.code)"
    }
}
