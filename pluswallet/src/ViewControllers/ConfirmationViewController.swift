//
//  ConfirmationViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-07-28.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit
import LocalAuthentication
import PLCore
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

class ConfirmationViewController: UIViewController, UIScrollViewDelegate, ContentBoxPresenter {

    init(amount: Amount, fee: Amount, feeType: FeeLevel, address: String, isUsingBiometrics: Bool, currency: CurrencyDef) {
        self.amount = amount
        self.feeAmount = fee
        self.feeType = feeType
        self.addressText = address
        self.isUsingBiometrics = isUsingBiometrics
        self.currency = currency
        super.init(nibName: nil, bundle: nil)
    }

    private let amount: Amount
    private let feeAmount: Amount
    private let feeType: FeeLevel
    private let addressText: String
    private let isUsingBiometrics: Bool
    private let currency: CurrencyDef
    private let scrollView = UIScrollView()

    //ContentBoxPresenter
    let contentBox = UIView(color: .white)
    let blurView = UIVisualEffectView()
    let effect = UIBlurEffect(style: .dark)

    var successCallback: (() -> Void)?
    var cancelCallback: (() -> Void)?

    //private let header = ModalHeaderView(title: S.Confirmation.title, style: .dark)
    private let header = UIView()
    private let close = UIButton.close
    private let titlelbl = UILabel(font: UIFont.boldSystemFont(ofSize: 20), color: .white)
    private let subHeaderTitlelbl = UILabel(font: UIFont.boldSystemFont(ofSize: 20), color: .white)
    private let symbolHeader: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = C.padding[2]
        img.clipsToBounds = true
        img.layer.borderWidth = 1.5
        img.layer.borderColor = UIColor.white.cgColor
        return img
    }()
    private let stackView = UIStackView()
    private let subView = GradientView()
    private let leftView = UIView(color: .white)
    private let symbol: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = C.padding[2]
        img.clipsToBounds = true
        img.layer.borderWidth = 1
        img.layer.borderColor = UIColor.white.cgColor
        return img
    }()
    private let nameCurrency = UILabel(font: UIFont.boldSystemFont(ofSize: 16), color: .white)
    private let avatar: UIImageView = {
        let img = UIImageView()
//        let imgPath = Bundle.main.path(forResource: "アセット 56", ofType: "png")
//        img.image = UIImage(contentsOfFile: imgPath!)
        img.image = UIImage(named: "plus_wallet_icoin1")
        img.layer.masksToBounds = true
        return img
    }()
    private let name: UILabel = {
        let name  = UILabel()
        name.text = "Guest"
        name.textAlignment = .center
        name.textColor = .white
        return name
    }()

    private let notification: UILabel = {
        let lbl = UILabel()
        lbl.text = "※送る通貨にお間違いがないかご確認ください。"
        lbl.numberOfLines = 2
        lbl.textAlignment = .center
        lbl.font = UIFont.customBody(size: 17)
        return lbl
    }()

    private let cancel = ShadowButton(title: S.Button.cancel, type: .secondary)
    private let sendButton = ShadowButton(title: S.Confirmation.send, type: .primary, image: (LAContext.biometricType() == .face ? #imageLiteral(resourceName: "FaceId") : #imageLiteral(resourceName: "TouchId")))

    private let payLabel = UILabel(font: .customBody(size: 15.0), color: UIColor.orange)
    private let toLabel = UILabel(font: .customBody(size: 15.0), color: UIColor.orange)
    private let amountLabel = UILabel(font: .customBody(size: 17.0), color: .white)
    private let address = UILabel(font: .customBody(size: 17.0), color: .white)

    private let processingTime = UILabel.wrapping(font: .customBody(size: 15.0), color: UIColor.orange)
    private let sendLabel = UILabel(font: .customBody(size: 15.0), color: .white)
    private let feeLabel = UILabel(font: .customBody(size: 15.0), color: .white)
    private let totalLabel = UILabel(font: .customMedium(size: 15.0), color: .white)

    private let send = UILabel(font: .customBody(size: 15.0), color: .white)
    private let fee = UILabel(font: .customBody(size: 15.0), color: .white)
    private let total = UILabel(font: .customMedium(size: 15.0), color: .white)

    private var avatarIconConstraint = [NSLayoutConstraint]()
    private var avatarGallaryConstraint = [NSLayoutConstraint]()

    private let buttonSize: CGFloat = 44.0

    override func viewDidLoad() {
        scrollView.delegate = self
        addSubviews()
        addConstraints()
        setInitialData()
        setStyle()
        loadContactProfile()
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(header)

        stackView.addArrangedSubview(symbolHeader)
        stackView.addArrangedSubview(titlelbl)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        header.addSubview(stackView)
        header.addSubview(close)
        header.addSubview(subHeaderTitlelbl)
        
        scrollView.addSubview(subView)
        subView.addSubview(symbol)
        subView.addSubview(nameCurrency)
        leftView.addSubview(avatar)
        subView.addSubview(name)
        subView.addSubview(leftView)
        subView.addSubview(payLabel)
        subView.addSubview(toLabel)
        subView.addSubview(amountLabel)
        subView.addSubview(address)
        subView.addSubview(processingTime)
        subView.addSubview(sendLabel)
        subView.addSubview(feeLabel)
        subView.addSubview(totalLabel)
        subView.addSubview(send)
        subView.addSubview(fee)
        subView.addSubview(total)
        scrollView.addSubview(notification)
        scrollView.addSubview(cancel)
        scrollView.addSubview(sendButton)
    }

    private func addConstraints() {
//        contentBox.constrain([
//            contentBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            contentBox.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            contentBox.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -C.padding[6] ) ])
        scrollView.constrain(toSuperviewEdges: nil)
        header.constrain([
            header.topAnchor.constraint(equalTo: scrollView.topAnchor ),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor ),
            header.heightAnchor.constraint(equalToConstant: E.isIPhoneX ? 120 : 98 )
            ])
        close.constrain([
            close.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -50),
            close.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -C.padding[2]),
            close.widthAnchor.constraint(equalToConstant: buttonSize),
            close.heightAnchor.constraint(equalToConstant: buttonSize)
            ])
        stackView.constrain([
            stackView.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: subHeaderTitlelbl.topAnchor, constant: -C.padding[1])
            ])
        symbolHeader.constrain([
            symbolHeader.widthAnchor.constraint(equalToConstant: C.padding[4]),
            symbolHeader.heightAnchor.constraint(equalToConstant: C.padding[4] )
            ])

        subHeaderTitlelbl.constrain([
            subHeaderTitlelbl.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -C.padding[2]),
            subHeaderTitlelbl.centerXAnchor.constraint(equalTo: header.centerXAnchor)
            ])

        //subview
        subView.constrain([
            subView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: C.padding[2]),
            subView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[1]),
            subView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1] )
            //subView.heightAnchor.constraint(equalToConstant: 250 )
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
        leftView.layer.cornerRadius = 50
        leftView.constrain([
            leftView.topAnchor.constraint(equalTo: subView.topAnchor, constant: 30),
            leftView.centerXAnchor.constraint(equalTo: subView.centerXAnchor),
            leftView.heightAnchor.constraint(equalToConstant: 100 ),
            leftView.widthAnchor.constraint(equalTo: leftView.heightAnchor)
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

        //information
        payLabel.constrain([
            payLabel.leadingAnchor.constraint(equalTo: subView.leadingAnchor, constant: C.padding[2]),
            payLabel.topAnchor.constraint(equalTo: name.bottomAnchor, constant: C.padding[2]) ])
        amountLabel.constrain([
            amountLabel.leadingAnchor.constraint(equalTo: payLabel.leadingAnchor),
            amountLabel.topAnchor.constraint(equalTo: payLabel.bottomAnchor)])
        toLabel.constrain([
            toLabel.leadingAnchor.constraint(equalTo: amountLabel.leadingAnchor),
            toLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: C.padding[2]) ])
        address.constrain([
            address.leadingAnchor.constraint(equalTo: toLabel.leadingAnchor),
            address.topAnchor.constraint(equalTo: toLabel.bottomAnchor),
            address.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: -C.padding[2]) ])
        processingTime.constrain([
            processingTime.leadingAnchor.constraint(equalTo: address.leadingAnchor),
            processingTime.topAnchor.constraint(equalTo: address.bottomAnchor, constant: C.padding[2]),
            processingTime.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: -C.padding[2]) ])
        sendLabel.constrain([
            sendLabel.leadingAnchor.constraint(equalTo: processingTime.leadingAnchor),
            sendLabel.topAnchor.constraint(equalTo: processingTime.bottomAnchor, constant: C.padding[2]),
            sendLabel.trailingAnchor.constraint(lessThanOrEqualTo: send.leadingAnchor) ])
        send.constrain([
            send.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: -C.padding[2]),
            sendLabel.firstBaselineAnchor.constraint(equalTo: send.firstBaselineAnchor) ])
        feeLabel.constrain([
            feeLabel.leadingAnchor.constraint(equalTo: sendLabel.leadingAnchor),
            feeLabel.topAnchor.constraint(equalTo: sendLabel.bottomAnchor) ])
        fee.constrain([
            fee.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: -C.padding[2]),
            fee.firstBaselineAnchor.constraint(equalTo: feeLabel.firstBaselineAnchor) ])
        totalLabel.constrain([
            totalLabel.leadingAnchor.constraint(equalTo: feeLabel.leadingAnchor),
            totalLabel.topAnchor.constraint(equalTo: feeLabel.bottomAnchor) ])
        total.constrain([
            total.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: -C.padding[2]),
            total.firstBaselineAnchor.constraint(equalTo: totalLabel.firstBaselineAnchor),
            total.bottomAnchor.constraint(equalTo: subView.bottomAnchor, constant: -C.padding[2])])
        notification.constrain([
            notification.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            notification.topAnchor.constraint(equalTo: subView.bottomAnchor, constant: C.padding[2]),
            notification.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2])
            ])
        cancel.constrain([
            cancel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            cancel.topAnchor.constraint(equalTo: notification.bottomAnchor, constant: C.padding[2]),
            cancel.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -C.padding[1]),
            cancel.heightAnchor.constraint(equalToConstant: 40)
           // cancel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -C.padding[2])
            ])
        sendButton.constrain([
            sendButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: C.padding[1]),
            sendButton.topAnchor.constraint(equalTo: notification.bottomAnchor, constant: C.padding[2]),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            sendButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -C.padding[2])
            ])
    }

    private func setInitialData() {

       // view.backgroundColor = .clear
        view.backgroundColor = .white
        payLabel.text = S.Confirmation.send

        let displayTotal = Amount(amount: amount.rawValue + feeAmount.rawValue,
                                  currency: currency,
                                  rate: amount.rate,
                                  minimumFractionDigits: amount.minimumFractionDigits)

        amountLabel.text = amount.combinedDescription

        toLabel.text = S.Confirmation.to
        address.text = addressText
        address.lineBreakMode = .byTruncatingMiddle

        if currency is Bitcoin {
            switch feeType {
            case .regular:
                processingTime.text = String(format: S.Confirmation.processingTime, S.FeeSelector.regularTime)
            case .economy:
                processingTime.text = String(format: S.Confirmation.processingTime, S.FeeSelector.economyTime)
            }
        } else {
            processingTime.text = String(format: S.Confirmation.processingTime, S.FeeSelector.ethTime)
        }

        sendLabel.text = S.Confirmation.amountLabel
        sendLabel.adjustsFontSizeToFitWidth = true
        send.text = amount.description
        feeLabel.text = S.Confirmation.feeLabel
        fee.text = feeAmount.description

        totalLabel.text = S.Confirmation.totalLabel
        total.text = displayTotal.description

        if currency is ERC20Token {
            totalLabel.isHidden = true
            total.isHidden = true
        }

        cancel.tap = strongify(self) { myself in
            myself.dismiss(animated: true, completion: myself.cancelCallback)
        }
        close.tap = strongify(self) { myself in
            myself.dismiss(animated: true, completion: myself.cancelCallback)
        }
        sendButton.tap = strongify(self) { myself in
            myself.dismiss(animated: true, completion: myself.successCallback)
        }

//        contentBox.layer.cornerRadius = 6.0
//        contentBox.layer.masksToBounds = true

        if !isUsingBiometrics {
            sendButton.image = nil
        }
    }
    private func setStyle() {
        header.backgroundColor = currency.colors.0
        close.tintColor = .white
        symbolHeader.image = UIImage(named: currency.code.lowercased())
        titlelbl.text = S.Send.title
        subHeaderTitlelbl.text = S.Confirmation.title
        symbol.image = UIImage(named: currency.code.lowercased())
        nameCurrency.text = currency.name

        subView.layer.cornerRadius = 10
        subView.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    /////////////////////information profile
    private func setAvatar(image: UIImage, isIcon: Bool) {
        self.avatar.image = image
        if isIcon {
            NSLayoutConstraint.activate(self.avatarIconConstraint)
            NSLayoutConstraint.deactivate(self.avatarGallaryConstraint)
        } else {
            NSLayoutConstraint.activate(self.avatarGallaryConstraint)
            NSLayoutConstraint.deactivate(self.avatarIconConstraint)
            self.avatar.contentMode = .scaleAspectFill
            self.avatar.layer.cornerRadius = 50
        }

    }
    private func loadContactProfile() {
        FirebaseManager.fetchUserInfoByAddress(tag: self.currency.code,
                                               address: self.addressText,
                                               completion: { data in
            // Create reference to the file whose metadata we want to retrieve
            if let username = data["username"] {
                self.name.text = username as? String
            }
            if let imageUrl: String = data["userimage"] as? String {
                let isIcon = imageUrl.range(of: "http") == nil
                if isIcon {
                    self.setAvatar(image: UIImage(named: imageUrl)!, isIcon: true)
                    return
                }
                let storageRef = Storage.storage().reference()
                // Create a reference to the file you want to download
                let imageRef = storageRef.child(imageUrl)

                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                        print("Error fetching image: \(error)")
                    } else {
                        self.setAvatar(image: UIImage(data: data!)!, isIcon: isIcon)
                    }
                }
            }
        })
    }
}
