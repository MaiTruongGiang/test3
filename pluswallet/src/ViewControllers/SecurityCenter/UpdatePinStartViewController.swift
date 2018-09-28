//
//  UpdatePinStartViewController.swift
//  PlusWallet
//
//  Created by Zan on 2018/07/06.
//  Copyright © 2018年 PlusWallet LLC. All rights reserved.
//

import UIKit
import LocalAuthentication
import IQKeyboardManagerSwift

class UpdatePinStartViewController: UIViewController, UITextFieldDelegate, Subscriber {

    let nametxt: UITextField = {
        let name = UITextField()
        name.placeholder = "ユーザー名を入力"
        name.font = UIFont.boldSystemFont(ofSize: 15)
        name.borderStyle = .roundedRect
        name.layer.backgroundColor = #colorLiteral(red: 0.9234612944, green: 0.9234612944, blue: 0.9234612944, alpha: 1)
        name.autocapitalizationType = .none
        name.autocorrectionType = .no
        name.font = UIFont.customBody(size: 16.0)
        name.textColor = .darkText
        name.layer.cornerRadius = 5.0

        return name

    }()
    let contentTerm = TermAndConditionView()
    private let walletStartbtn = ShadowButton(title: "同意して、PLus Walletを始める", type: .primary)
    // MARK: - Public
    var setPinSuccess: ((String) -> Void)?
    var resetFromDisabledSuccess: (() -> Void)?
    var resetFromDisabledWillSucceed: (() -> Void)?

    init(walletManager: BTCWalletManager, type: UpdatePinType, showsBackButton: Bool = true, phrase: String? = nil) {
        self.walletManager = walletManager
        self.phrase = phrase// lan dau bang nil
        self.pinView = PinView(style: .create, length: Store.state.pinLength)
        self.showsBackButton = showsBackButton
        self.faq = UIButton.buildFaqButton(articleId: ArticleIds.setPin)
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Private
    // private let header = UILabel.wrapping(font: .customBold(size: 26.0), color: .darkText)
    // private let instruction = UILabel.wrapping(font: .customBody(size: 14.0), color: .darkText)
    private let header = UIView()
    private let headerStep1: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    private let headerStep2: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    private let headerStep3: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    private let headerStep4: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()

    private let instruction: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    private let caption = UILabel.wrapping(font: .customBody(size: 13.0), color: .secondaryGrayText)
    private var pinView: PinView
    private let pinPad = PinPadViewController(style: .white, keyboardType: .pinPad, maxDigits: 0)
    private let spacer = UIView()
    private let walletManager: BTCWalletManager
    private let faq: UIButton
    private var step: Step = .verify {
        didSet {
            switch step {
            case .verify:
                instruction.text = isCreatingPin ? S.UpdatePin.createInstruction : S.UpdatePin.enterCurrent
                caption.isHidden = true
            case .new:
                //let instructionText = isCreatingPin ? S.UpdatePin.createInstruction : S.UpdatePin.enterNew
                self.navigationItem.title = "暗証番号の設定"
                let instructionText = "お客様の資産を守るために６桁の暗証番号を設定してください"
                if instruction.text != instructionText {
                    instruction.pushNewText(instructionText)
                }
                //header.text = S.UpdatePin.createTitle
                caption.isHidden = false
                self.addSubviews()
                self.addConstraints()
                nametxt.isHidden = true
                addHeaderStep2()
                headerStep3.isHidden = true
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.hidesBackButton = false

            case .confirmNew:
                self.navigationItem.title = "暗証番号の設定"
                caption.isHidden = true
                //                if isCreatingPin {
                //                 header.text = S.UpdatePin.createTitleConfirm
                //                } else {
                instruction.pushNewText("確認のため、先ほど設定した６桁の暗証番号をもう一度入力してください")
                addHeaderStep3()
                //                }
                self.navigationItem.hidesBackButton = true
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Back"), style: UIBarButtonItemStyle.done, target: self, action: #selector(self.comeback))
            case .enterName :
                self.navigationItem.title = "ユーザー名を入力"
                instruction.pushNewText("ユーザー名を入力してください。\n この名前は送金相手などに表示されます")
                addHeaderStep1()
                addEnterName()

            case .agreeCondition :
                self.navigationItem.title = "利用規約"
                instruction.pushNewText("Plus Wallet を利用するにあたり、以下の点を読んでチェックしてください")
                addHeaderStep4()
                contentTerm.view.isHidden = false
                walletStartbtn.isHidden = false
                addAgreeCondition()
            }
        }
    }
    private var currentPin: String?
    private var newPin: String?
    private var phrase: String?
    private let type: UpdatePinType
    private var isCreatingPin: Bool {
        return type != .update
    }
    private let newPinLength = 6
    private let showsBackButton: Bool

    private enum Step {
        case verify
        case enterName
        case new
        case confirmNew
        case agreeCondition

    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        nametxt.delegate = self
        setData()
        navigationController?.navigationBar.applyNavigationGradient(colors: [UIColor.gradientStart , UIColor.gradientEnd])
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
        nametxt.keyboardToolbar.doneBarButton.setTarget(self, action:#selector(self.doneAction(_:)) )
    }

    private func addSubviews() {
        view.addSubview(header)
        view.addSubview(instruction)
        view.addSubview(caption)
        view.addSubview(pinView)
        //view.addSubview(faq)
        view.addSubview(spacer)
        //view.addSubview(icon)
    }

    private func addConstraints() {

        header.constrain([
            header.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: C.padding[2]),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 20)
            ])
        instruction.constrain([
            instruction.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: C.padding[6]),
            instruction.topAnchor.constraint(equalTo: header.bottomAnchor, constant: C.padding[2]),
            instruction.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -C.padding[6]) ])
        pinView.constrain([
            pinView.centerYAnchor.constraint(equalTo: spacer.centerYAnchor),
            pinView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinView.widthAnchor.constraint(equalToConstant: pinView.width),
            pinView.heightAnchor.constraint(equalToConstant: pinView.itemSize) ])
        if E.isIPhoneX {
            addChildViewController(pinPad, layout: {
                pinPad.view.constrainBottomCorners(sidePadding: 0.0, bottomPadding: 0.0)
                pinPad.view.constrain([pinPad.view.heightAnchor.constraint(equalToConstant: pinPad.height),
                                       pinPad.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -C.padding[3])])
            })
        } else {
            addChildViewController(pinPad, layout: {
                pinPad.view.constrainBottomCorners(sidePadding: 0.0, bottomPadding: 0.0)
                pinPad.view.constrain([pinPad.view.heightAnchor.constraint(equalToConstant: pinPad.height)])
            })
        }
        spacer.constrain([
            spacer.topAnchor.constraint(equalTo: instruction.bottomAnchor),
            spacer.bottomAnchor.constraint(equalTo: caption.topAnchor) ])
        //        faq.constrain([
        //            faq.topAnchor.constraint(equalTo: header.topAnchor),
        //            faq.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
        //            faq.constraint(.height, constant: 44.0),
        //            faq.constraint(.width, constant: 44.0)])
        caption.constrain([
            caption.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            caption.bottomAnchor.constraint(equalTo: pinPad.view.topAnchor, constant: -C.padding[2]),
            caption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]) ])
    }
    private func addHeaderStep1() {
        header.addSubview(headerStep1)
        headerStep1.constrain([
            headerStep1.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 10),
            headerStep1.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            //headerStep1.widthAnchor.constraint(equalTo: view.widthAnchor , multiplier: 1/4),
            headerStep1.heightAnchor.constraint(equalToConstant: 5),
            headerStep1.widthAnchor.constraint(equalToConstant: ((view.frame.width - 10) / 4) - 10)
            ])
    }
    private func addHeaderStep2() {
        headerStep2.isHidden = false
        header.addSubview(headerStep2)
        headerStep2.constrain([
            headerStep2.leadingAnchor.constraint(equalTo: headerStep1.trailingAnchor, constant: 10),
            headerStep2.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            //headerStep1.widthAnchor.constraint(equalTo: view.widthAnchor , multiplier: 1/4),
            headerStep2.heightAnchor.constraint(equalToConstant: 5),
            headerStep2.widthAnchor.constraint(equalToConstant: ((view.frame.width - 10) / 4) - 10)
            ])
    }
    private func addHeaderStep3() {
        headerStep3.isHidden = false
        header.addSubview(headerStep3)
        headerStep3.constrain([
            headerStep3.leadingAnchor.constraint(equalTo: headerStep2.trailingAnchor, constant: 10),
            headerStep3.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            //headerStep1.widthAnchor.constraint(equalTo: view.widthAnchor , multiplier: 1/4),
            headerStep3.heightAnchor.constraint(equalToConstant: 5),
            headerStep3.widthAnchor.constraint(equalToConstant: ((view.frame.width - 10) / 4) - 10)
            ])
    }
    private func addHeaderStep4() {
        headerStep4.isHidden = false
        header.addSubview(headerStep4)
        headerStep4.constrain([
            headerStep4.leadingAnchor.constraint(equalTo: headerStep3.trailingAnchor, constant: 10),
            headerStep4.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            //headerStep1.widthAnchor.constraint(equalTo: view.widthAnchor , multiplier: 1/4),
            headerStep4.heightAnchor.constraint(equalToConstant: 5),
            headerStep4.widthAnchor.constraint(equalToConstant: ((view.frame.width - 10) / 4) - 10)
            ])
    }
    private func addEnterName() {
        view.addSubview(nametxt)
        view.addSubview(header)
        view.addSubview(instruction)
        header.addSubview(headerStep1)
        header.constrain([
            header.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: C.padding[2]),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 20)
            ])
        instruction.constrain([
            instruction.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: C.padding[6]),
            instruction.topAnchor.constraint(equalTo: header.bottomAnchor, constant: C.padding[2]),
            instruction.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -C.padding[6]) ])
        nametxt.constrain([
            nametxt.topAnchor.constraint(equalTo: instruction.bottomAnchor, constant: 40),
            nametxt.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nametxt.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4),
            nametxt.heightAnchor.constraint(equalToConstant: 35)])
    }
    private func addAgreeCondition() {
        view.addSubview(contentTerm.view)
        view.addSubview(walletStartbtn)
        pinPad.view.isHidden = true
        pinView.isHidden = true
        spacer.isHidden = true
        caption.isHidden = true
        walletStartbtn.tap = didSetNewPin
        contentTerm.view.constrain([
            contentTerm.view.topAnchor.constraint(equalTo: instruction.bottomAnchor, constant: 30),
            contentTerm.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            contentTerm.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            contentTerm.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 3/5)
            ])

        if E.isIPhoneX {
            walletStartbtn.constrain([
                walletStartbtn.heightAnchor.constraint(equalToConstant: 40),
                walletStartbtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                walletStartbtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                walletStartbtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70)

                ])
        } else {
            walletStartbtn.constrain([
                walletStartbtn.heightAnchor.constraint(equalToConstant: 40),
                walletStartbtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                walletStartbtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                walletStartbtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
                ])
        }
    }
    private func setData() {
        caption.text = S.UpdatePin.caption
        view.backgroundColor = .whiteTint
        //header.text = isCreatingPin ? S.UpdatePin.createTitle : S.UpdatePin.updateTitle
        instruction.text = isCreatingPin ? S.UpdatePin.createInstruction : S.UpdatePin.enterCurrent
        pinPad.ouputDidUpdate = { [weak self] text in
            guard let step = self?.step else { return }
            switch step {
            case .verify:
                self?.didUpdateForCurrent(pin: text)
            case .new :
                self?.didUpdateForNew(pin: text)
            case .confirmNew:
                self?.didUpdateForConfirmNew(pin: text)

            case .enterName :
                print(self?.nametxt.text ?? "chua co gia tri")
            case .agreeCondition :
                print("Da dc roi")
            }
        }

        if isCreatingPin { // neu lan dau tao vi Step = .new, h thay doi bang Nhap ten
            //            if type == .creationWithPhrase {
            //                 step = .new
            //                 caption.isHidden = false
            //            } else{
            step = .enterName
            caption.isHidden = false
            //            }
        } else {
            caption.isHidden = true
        }

        if !showsBackButton {
            navigationItem.leftBarButtonItem = nil
            navigationItem.hidesBackButton = true

        }
    }
    @objc func doneAction(_ sender : UITextField) {
        Store.perform(action: ProfileChange.setUsername(nametxt.text!))
        pushNewStep(.new)
    }
    @objc func comeback() {
        pushNewStep(.new)
        contentTerm.view.isHidden = true
        walletStartbtn.isHidden = true
        headerStep4.isHidden = true
        headerStep3.isHidden = true
        pinPad.view.isHidden = false
        pinView.isHidden = false

    }

    private func didUpdateForCurrent(pin: String) {
        pinView.fill(pin.utf8.count)
        if pin.utf8.count == Store.state.pinLength {
            if walletManager.authenticate(pin: pin) {
                pushNewStep(.new)
                currentPin = pin
                replacePinView()
            } else {
                if walletManager.walletDisabledUntil > 0 {
                    dismiss(animated: true, completion: {
                        Store.perform(action: RequireLogin())
                    })
                } else {
                    clearAfterFailure()
                }
            }
        }
    }

    private func didUpdateForNew(pin: String) {
        pinView.fill(pin.utf8.count)
        if pin.utf8.count == newPinLength {
            newPin = pin
            pushNewStep(.confirmNew)
        }
    }

    private func didUpdateForConfirmNew(pin: String) {
        guard let newPin = newPin else { return }
        pinView.fill(pin.utf8.count)
        if pin.utf8.count == newPinLength {
            if pin == newPin {
                pinView.removeFromSuperview()
                pushNewStep(.agreeCondition)
            } else {
                clearAfterFailure()
                //pushNewStep(.confirmNew)
            }
        }
    }

    private func clearAfterFailure() {
        pinPad.view.isUserInteractionEnabled = false
        pinView.shake { [weak self] in
            self?.pinPad.view.isUserInteractionEnabled = true
            self?.pinView.fill(0)
        }
        pinPad.clear()
    }

    private func replacePinView() {
        pinView.removeFromSuperview()
        pinView = PinView(style: .create, length: newPinLength)
        view.addSubview(pinView)
        pinView.constrain([
            pinView.centerYAnchor.constraint(equalTo: spacer.centerYAnchor),
            pinView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinView.widthAnchor.constraint(equalToConstant: pinView.width),
            pinView.heightAnchor.constraint(equalToConstant: pinView.itemSize) ])
    }

    private func pushNewStep(_ newStep: Step) {
        step = newStep
        pinPad.clear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.pinView.fill(0)
        }
    }

    private func didSetNewPin() {
        DispatchQueue.walletQueue.async { [weak self] in
            guard let newPin = self?.newPin else { return }
            var success: Bool? = false
            if let seedPhrase = self?.phrase {
                //print("Chac la dang nhap bang 12 cum tu ")
                success = self?.walletManager.forceSetPin(newPin: newPin, seedPhrase: seedPhrase)
            } else if let currentPin = self?.currentPin { // update pin
               // print("Chac la cap nhat ma pin ")
                success = self?.walletManager.changePin(newPin: newPin, pin: currentPin)
                DispatchQueue.main.async { Store.trigger(name: .didUpgradePin) }
            } else if self?.type == .creationNoPhrase {
              //  print("Chac la lan dau tao ma pin ")
                success = self?.walletManager.forceSetPin(newPin: newPin)

            }

            DispatchQueue.main.async {
                if let success = success, success == true {
                    if self?.resetFromDisabledSuccess != nil {
                        self?.resetFromDisabledWillSucceed?()
                        Store.perform(action: Alert.Show(.pinSet(callback: { [weak self] in
                            self?.dismiss(animated: true, completion: {
                                self?.resetFromDisabledSuccess?()
                            })
                        })))
                    } else {// xet mk lan dau
                        Store.perform(action: Alert.Show(.pinSet(callback: { [weak self] in
                            self?.setPinSuccess?(newPin)
                            if self?.type != .creationNoPhrase {
                                self?.parent?.dismiss(animated: true, completion: nil)
                            }
                        })))
                    }

                } else {
                    let alert = UIAlertController(title: S.UpdatePin.updateTitle, message: S.UpdatePin.setPinError, preferredStyle: .alert) // Thong bao loi k the update
                    alert.addAction(UIAlertAction(title: S.Button.ok, style: .default, handler: { [weak self] _ in
                        self?.clearAfterFailure()
                        self?.pushNewStep(.new)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        Store.perform(action: ProfileChange.setUsername(nametxt.text!))
//        UserDefaults.profileUsername = nametxt.text!
        pushNewStep(.new)
        return true
    }

}
