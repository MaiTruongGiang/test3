//
//  StartViewController.swift
//  PlusWallet
//
//  Created by Zan on 2018-07-22.
//  Copyright © 2018 PLusWallet LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import FirebaseAuth

class StartViewController: UIViewController {

    // MARK: - Public
    init(didTapCreate: @escaping () -> Void, didTapRecover: @escaping () -> Void) {
        self.didTapRecover = didTapRecover
        self.didTapCreate = didTapCreate
        self.faq = UIButton.buildFaqButton(articleId: ArticleIds.startView)
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Private
    private let message = UILabel(font: .customMedium(size: 18.0), color: .whiteTint)
    private let create = ShadowButton(title: "4ステップですぐに始める", type: .primary)
    //private let recover = ShadowButton(title: "アカウントの復元", type: .secondary)
    private let recover: UIButton = {
        let button = UIButton()
        let yourAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor: UIColor.blue,
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: "アカウントの復元",
                                                        attributes: yourAttributes)
        button.setAttributedTitle(attributeString, for: .normal)
        //button.titleLabel?.font = UIFont.
        return button
    }()
    private let didTapRecover: () -> Void
    private let didTapCreate: () -> Void
    private let background = LoginBackgroundView()
    private var logo: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "login1 2"))
        image.contentMode = .scaleAspectFit
        return image
    }()
    private var backgroundImage: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "login1"))
        //image.contentMode = .scaleAspectFit
        return image
    }()
    private var faq: UIButton

    override func viewDidLoad() {
        view.backgroundColor = .white
        
        
       // print(Auth.auth().currentUser!.uid)
        setData()
        addSubviews()
        addConstraints()
        addButtonActions()
    }
    override func viewWillAppear(_ animated: Bool) {
       navigationController?.navigationBar.isHidden = true
    }
//    override func viewDidDisappear(_ animated: Bool) {
//        navigationController?.navigationBar.isHidden = false
//    }
    private func setData() {
        message.text =  "Plus Wallet" //S.StartViewController.message
        message.textColor = .black
        message.font = UIFont.italicSystemFont(ofSize: 40)
        message.lineBreakMode = .byWordWrapping
        message.numberOfLines = 0
        message.textAlignment = .center
        faq.tintColor = .whiteTint
    }

    private func addSubviews() {
        view.addSubview(backgroundImage)
        view.addSubview(logo)
        view.addSubview(message)
        view.addSubview(create)
        view.addSubview(recover)
        view.addSubview(faq)
    }

    private func addConstraints() {
        //background.constrain(toSuperviewEdges: nil)
        let yConstraint = NSLayoutConstraint(item: logo, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.5, constant: 0.0)
        logo.constrain([
            logo.constraint(.centerX, toView: view, constant: nil),
            yConstraint])
        message.constrain([
            message.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            message.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: C.padding[2]),
            message.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]) ])

        create.constrain([
            create.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 20),
            create.constraint(.leading, toView: view, constant: C.padding[6]),
            create.constraint(.trailing, toView: view, constant: -C.padding[6]),
            create.constraint(.height, constant: C.Sizes.buttonHeight) ])
        recover.constrain([
            recover.topAnchor.constraint(equalTo: create.bottomAnchor, constant: 20),
            recover.constraint(.leading, toView: view, constant: C.padding[6]),
            recover.constraint(.trailing, toView: view, constant: -C.padding[6]),
            recover.constraint(.height, constant: C.Sizes.buttonHeight) ])
        faq.constrain([
            faq.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: C.padding[4]),
            faq.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[4]),
            faq.widthAnchor.constraint(equalToConstant: 44.0),
            faq.heightAnchor.constraint(equalToConstant: 44.0) ])
        backgroundImage.constrain([
            backgroundImage.constraint(.leading, toView: view, constant: 0),
            backgroundImage.constraint(.trailing, toView: view, constant: 0),
            backgroundImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2/5),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }

    private func addButtonActions() {
        recover.tap = didTapRecover
        create.tap = didTapCreate
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
