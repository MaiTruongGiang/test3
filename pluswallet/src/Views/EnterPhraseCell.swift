//
//  EnterPhraseCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-02-24.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

class EnterPhraseCell: UICollectionViewCell {

    // MARK: - Public
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    var index: Int? {
        didSet {
            guard let index = index else { return }
//            label.text = "\(index + 1)"
            textField.placeholder = "\(index + 1)"
        }
    }
    private(set) var text: String?

    var didTapPrevious: (() -> Void)? {
        didSet {
            previousField.tap = didTapPrevious
        }
    }

    var didTapNext: (() -> Void)? {
        didSet {
            nextField.tap = didTapNext
        }
    }

    var didTapDone: (() -> Void)? {
        didSet {
            done.tap = {
                self.textField.resignFirstResponder()
                self.didTapDone?()
            }
        }
    }

    var didEnterSpace: (() -> Void)? // enter nut Space
    var isWordValid: ((String) -> Bool)? // co loi hay k

    func disablePreviousButton() { //neu tu dau tien thi k cho hien thi dau <
        previousField.tintColor = .secondaryShadow
        previousField.isEnabled = false
    }

    func disableNextButton() { // neu la tu cuoi cung k cho hien thi dau >
        nextField.tintColor = .secondaryShadow
        nextField.isEnabled = false
    }

    // MARK: - Private
    let textField: UITextField = {
        let txt = UITextField()
        txt.borderStyle = .roundedRect
//        txt.layer.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)

        txt.autocapitalizationType = .none
        txt.autocorrectionType = .no
        txt.font = UIFont.customBody(size: 16.0)
        txt.textColor = .darkText
        //txt.delegate = self
        txt.layer.cornerRadius = 5.0
        return txt
    }()

   // private let label = UILabel(font: .customBody(size: 13.0), color: .secondaryShadow)
    private let nextField = UIButton.icon(image: #imageLiteral(resourceName: "RightArrow"), accessibilityLabel: S.RecoverWallet.rightArrow)
    private let previousField = UIButton.icon(image: #imageLiteral(resourceName: "LeftArrow"), accessibilityLabel: S.RecoverWallet.leftArrow)
    private let done = UIButton(type: .system)
    fileprivate let separator = UIView(color: .secondaryShadow) // dau gach chan mau do khi co loi
    fileprivate var hasDisplayedInvalidState = false // co hien thi co loi hay khong

    private func setup() {
        contentView.addSubview(textField)
        contentView.addSubview(separator)
        //contentView.addSubview(label)

        textField.constrain([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: C.padding[1]),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5) ])
        separator.constrain([
            separator.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: C.padding[1]),
            separator.topAnchor.constraint(equalTo: textField.bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -C.padding[1]),
            separator.heightAnchor.constraint(equalToConstant: 1.0) ])
//        label.constrain([
//            label.leadingAnchor.constraint(equalTo: separator.leadingAnchor),
//            label.topAnchor.constraint(equalTo: separator.bottomAnchor),
//            label.trailingAnchor.constraint(equalTo: separator.trailingAnchor) ])
        setData()
    }

    private func setData() {
        textField.inputAccessoryView = accessoryView
        textField.autocorrectionType = .no
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.addTarget(self, action: #selector(EnterPhraseCell.textChanged(textField:)), for: .editingChanged)

       // label.textAlignment = .center
        previousField.tintColor = .secondaryGrayText
        nextField.tintColor = .secondaryGrayText
        done.setTitle(S.RecoverWallet.done, for: .normal)
    }

    private var accessoryView: UIView {
        let view = UIView(color: .secondaryButton)
        view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        let topBorder = UIView(color: .secondaryShadow)
        view.addSubview(topBorder)
        view.addSubview(previousField)
        view.addSubview(nextField)
        view.addSubview(done)

        topBorder.constrainTopCorners(height: 1.0)
        previousField.constrain([
            previousField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            previousField.topAnchor.constraint(equalTo: view.topAnchor),
            previousField.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previousField.widthAnchor.constraint(equalToConstant: 44.0) ])

        nextField.constrain([
            nextField.leadingAnchor.constraint(equalTo: previousField.trailingAnchor),
            nextField.topAnchor.constraint(equalTo: view.topAnchor),
            nextField.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            nextField.widthAnchor.constraint(equalToConstant: 44.0) ])

        done.constrain([
            done.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
            done.topAnchor.constraint(equalTo: view.topAnchor),
            done.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        return view
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EnterPhraseCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        setColors(textField: textField)
    }

    @objc func textChanged(textField: UITextField) {
        if let text = textField.text {
            if text.last == " " {
                textField.text = text.replacingOccurrences(of: " ", with: "")
                didEnterSpace?()
            }
        }
        if hasDisplayedInvalidState {
            setColors(textField: textField)
        }
    }

    private func setColors(textField: UITextField) {
        guard let isWordValid = isWordValid else { return }
        guard let word = textField.text else { return }
        if isWordValid(word) {
            textField.textColor = .darkText
             textField.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            separator.backgroundColor = .secondaryShadow
        } else {
            textField.textColor = .cameraGuideNegative
            //separator.backgroundColor = .cameraGuideNegative
            hasDisplayedInvalidState = true
        }
    }
}
