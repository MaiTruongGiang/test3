//
//  HomeScreenViewController.swift
//  PlusWallet
//
//  Created by Zan on 2018-07-26.
//  Copyright © 2018 PLusWallet LLC. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController, Subscriber, Trackable {

    var primaryWalletManager: BTCWalletManager? {
        didSet {
            setInitialData()
            setupSubscriptions()
            homeScreenCollectionViewController.reload()

           // attemptShowPrompt()
        }
    }
    //private let assetList = AssetListTableView()
    private let subHeaderView = GradientView()
    private let total = UILabel(font: .customBold(size: 40), color: .white)
    private let totalHeader = UILabel(font: .customMedium(size: 18.0), color: .white)
    private let prompt = UIView()
    private var promptHiddenConstraint: NSLayoutConstraint!

    private let currencyView = UIView()
    private let currencylbl: UILabel = {
       let lbl = UILabel()
        lbl.text = NSLocalizedString("HomeScreen.currency", value:"Currency", comment: "Currency")
        lbl.font = UIFont.customBody(size: 15)
        lbl.textColor = .gray
        return lbl
    }()
    private let allCurrencybtn: UIButton = {
       let btn = UIButton()
//        btn.setImage(#imageLiteral(resourceName: "RightArrow"), for: .normal)
//        btn.imageView?.contentMode = .scaleToFill
//        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        btn.setTitle(S.HomeScreen.allView, for:.normal)
        btn.setTitleColor(.gradientEnd, for: .normal)
        btn.titleLabel?.font = UIFont.customBody(size: 15)
//        btn.semanticContentAttribute = .forceRightToLeft
        return btn

    }()

    lazy var homeScreenCollectionViewController: HomeScreenCollectionViewController = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let homeCollection = HomeScreenCollectionViewController(collectionViewLayout: layout)

            homeCollection.didTapAddWallet = didTapAddWallet
            homeCollection.didSelectCurrency = didSelectCurrency
        return homeCollection
    }()

    var didSelectCurrency: ((CurrencyDef) -> Void)?
    var didTapSecurity: (() -> Void)?
    var didTapSupport: (() -> Void)?
    var didTapSettings: (() -> Void)?
    var didTapAddWallet: (() -> Void)?
    var didShowTokenList: (() -> Void)?
    // MARK: -

    init(primaryWalletManager: BTCWalletManager?) {
        self.primaryWalletManager = primaryWalletManager
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {

        addSubviews()
        addConstraints()
        setInitialData()
        setupSubscriptions()

      // primaryWalletManager?.updateProfileBTC()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarItems()
//
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.tintColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTotalAssets()
    }

    // MARK: Setup

    private func addSubviews() {
        view.addSubview(subHeaderView)
        subHeaderView.addSubview(totalHeader)
        subHeaderView.addSubview(total)
        view.addSubview(currencyView)
        currencyView.addSubview(currencylbl)
        currencyView.addSubview(allCurrencybtn)
        //view.addSubview(prompt)
        allCurrencybtn.tap = {
            let  vc = AllCurrencyViewController()

            vc.didTapAddWallet = self.didTapAddWallet
            vc.didShowTokenList = self.didShowTokenList
            vc.didSelectCurrency = self.didSelectCurrency
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func addConstraints() {
        let height: CGFloat = 120.0
        if #available(iOS 11.0, *) {
            subHeaderView.constrain([
                subHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                subHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
                subHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                subHeaderView.heightAnchor.constraint(equalToConstant: height) ])
        } else {
            subHeaderView.constrain([
                subHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                subHeaderView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0.0),
                subHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                subHeaderView.heightAnchor.constraint(equalToConstant: height) ])
        }

        totalHeader.constrain([
            totalHeader.centerXAnchor.constraint(equalTo: subHeaderView.centerXAnchor),
            totalHeader.topAnchor.constraint(equalTo: subHeaderView.topAnchor, constant: 15)

            ])

        total.constrain([
            total.topAnchor.constraint(equalTo: totalHeader.topAnchor, constant: C.padding[3]),
            total.centerXAnchor.constraint(equalTo: subHeaderView.centerXAnchor)])

//        promptHiddenConstraint = prompt.heightAnchor.constraint(equalToConstant: 0.0)
//        prompt.backgroundColor = .red
//        prompt.constrain([
//            prompt.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            prompt.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            prompt.topAnchor.constraint(equalTo: subHeaderView.bottomAnchor),
//            promptHiddenConstraint
//            ])
        currencyView.constrain([
            currencyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            currencyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currencyView.topAnchor.constraint(equalTo: subHeaderView.bottomAnchor),
            currencyView.heightAnchor.constraint(equalToConstant: 40)
            ])
        currencylbl.constrain([
            currencylbl.leadingAnchor.constraint(equalTo: currencyView.leadingAnchor, constant: 20),
            currencylbl.bottomAnchor.constraint(equalTo: currencyView.bottomAnchor)

            ])
        allCurrencybtn.constrain([
            allCurrencybtn.trailingAnchor.constraint(equalTo: currencyView.trailingAnchor, constant: -20),
            allCurrencybtn.bottomAnchor.constraint(equalTo: currencyView.bottomAnchor, constant: 5)
            ])

//        addChildViewController(assetList, layout: {
//            assetList.view.constrain([
//                assetList.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                assetList.view.topAnchor.constraint(equalTo: currencyView.bottomAnchor),
//                assetList.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                assetList.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
//        })
        addChildViewController(homeScreenCollectionViewController, layout: {
            homeScreenCollectionViewController.view.constrain([
                homeScreenCollectionViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor ),
                homeScreenCollectionViewController.view.topAnchor.constraint(equalTo: currencyView.bottomAnchor),
                homeScreenCollectionViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor ),
                homeScreenCollectionViewController.view.heightAnchor.constraint(equalToConstant: 250)])
        })
    }

    private func setInitialData() {
        view.backgroundColor = .whiteBackground
        //view.backgroundColor = .whiteBackground
        //subHeaderView.backgroundColor = .whiteBackground
        subHeaderView.clipsToBounds = false

   //     navigationItem.titleView = UIView()
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.shadowImage = #imageLiteral(resourceName: "TransparentPixel")
//        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "TransparentPixel"), for: .default)

        totalHeader.text = S.HomeScreen.totalAssets
        totalHeader.textAlignment = .left
        total.textAlignment = .left
        total.text = "0"
        title = ""

        updateTotalAssets()
    }
    private func updateTotalAssets() {
        let fiatTotal: Decimal = Store.state.displayCurrencies.map {
            guard let balance = Store.state[$0]?.balance,
                let rate = Store.state[$0]?.currentRate else { return 0.0 }
            let amount = Amount(amount: balance,
                                currency: $0,
                                rate: rate)
            return amount.fiatValue
            }.reduce(0.0, +)
        let format = NumberFormatter()
        format.isLenient = true
        format.numberStyle = .currency
        format.generatesDecimalNumbers = true
        format.negativeFormat = format.positiveFormat.replacingCharacters(in: format.positiveFormat.range(of: "#")!, with: "-#")
        format.currencySymbol = Store.state[Currencies.btc]?.currentRate?.currencySymbol ?? ""
        self.total.text = format.string(from: fiatTotal as NSDecimalNumber)
    }

    private func setupSubscriptions() {
        Store.unsubscribe(self)

        Store.subscribe(self, selector: {
            var result = false
            let oldState = $0
            let newState = $1
            $0.displayCurrencies.forEach { currency in
                result = result || oldState[currency]?.balance != newState[currency]?.balance
                result = result || oldState[currency]?.currentRate?.rate != newState[currency]?.currentRate?.rate
            }
            return result
        },
        callback: { _ in
            self.updateTotalAssets()
        })

//        // prompts
//        Store.subscribeAsTrigger(self, name: .didUpgradePin, callback: { _ in
//            if self.currentPrompt?.type == .upgradePin {
//                self.currentPrompt = nil
//            }
//        })
//        Store.subscribeAsTrigger(self, name: .didEnableShareData, callback: { _ in
//            if self.currentPrompt?.type == .shareData {
//                self.currentPrompt = nil
//            }
//        })
//        Store.subscribeAsTrigger(self, name: .didWritePaperKey, callback: { _ in
//            if self.currentPrompt?.type == .paperKey {
//                self.currentPrompt = nil
//            }
//        })
    }

    // MARK: - Prompt

//    private let promptDelay: TimeInterval = 0.6
//    
//    private var currentPrompt: Prompt? {
//        didSet {
//            if currentPrompt != oldValue {
//                var afterFadeOut: TimeInterval = 0.0
//                if let oldPrompt = oldValue {
//                    afterFadeOut = 0.15
//                    UIView.animate(withDuration: 0.2, animations: {
//                        oldValue?.alpha = 0.0
//                    }, completion: { _ in
//                        oldPrompt.removeFromSuperview()
//                    })
//                }
//                
//                if let newPrompt = currentPrompt {
//                    newPrompt.alpha = 0.0
//                    prompt.addSubview(newPrompt)
//                    newPrompt.constrain(toSuperviewEdges: .zero)
//                    prompt.layoutIfNeeded()
//                    promptHiddenConstraint.isActive = false
//
//                    // fade-in after fade-out and layout
//                    UIView.animate(withDuration: 0.2, delay: afterFadeOut + 0.15, options: .curveEaseInOut, animations: {
//                        newPrompt.alpha = 1.0
//                    })
//                } else {
//                    promptHiddenConstraint.isActive = true
//                }
//                
//                // layout after fade-out
//                UIView.animate(withDuration: 0.2, delay: afterFadeOut, options: .curveEaseInOut, animations: {
//                    self.view.layoutIfNeeded()
//                })
//            }
//        }
//    }
//    
//    private func attemptShowPrompt() {
//        guard let walletManager = primaryWalletManager else {
//            currentPrompt = nil
//            return
//        }
//        if let type = PromptType.nextPrompt(walletManager: walletManager) {
//            self.saveEvent("prompt.\(type.name).displayed")
//            currentPrompt = Prompt(type: type)
//            currentPrompt!.dismissButton.tap = { [unowned self] in
//                self.saveEvent("prompt.\(type.name).dismissed")
//                self.currentPrompt = nil
//            }
//            currentPrompt!.continueButton.tap = { [unowned self] in
//                // TODO:BCH move out of home screen
//                if let trigger = type.trigger(currency: Currencies.btc) {
//                    Store.trigger(name: trigger)
//                }
//                self.saveEvent("prompt.\(type.name).trigger")
//                self.currentPrompt = nil
//            }
//            if type == .biometrics {
//                UserDefaults.hasPromptedBiometrics = true
//            }
//            if type == .shareData {
//                UserDefaults.hasPromptedShareData = true
//            }
//        } else {
//            currentPrompt = nil
//        }
//    }

    // MARK: -

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension HomeScreenViewController {
    func setupNavigationBarItems() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = .white
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.tintColor = .black
        //    navigationController?.navigationBar.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 200)
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let label = UILabel()
        label.text = "Plus Wallet"
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .black
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "login1 2"))
        //titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        titleView.addSubview(titleImageView)
        titleView.addSubview(label)
        titleImageView.constrain([
            titleImageView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor, constant: -25),
            titleImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            titleImageView.widthAnchor.constraint(equalToConstant: 35),
            titleImageView.heightAnchor.constraint(equalToConstant: 40)
            ])
        label.constrain([
            label.centerXAnchor.constraint(equalTo: titleView.centerXAnchor, constant: 35),
            label.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
            //            label.widthAnchor.constraint(equalToConstant: 30),
            //            label.heightAnchor.constraint(equalToConstant: 40)
            ])

        navigationItem.titleView = titleView
       // navigationController?.navigationBar.backgroundColor = .white
      //  navigationController?.navigationBar.isTranslucent = false

//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        let portofoliobtn = UIButton(type: .system)
        portofoliobtn.setImage(#imageLiteral(resourceName: "Settings").withRenderingMode(.alwaysOriginal), for: .normal)
        portofoliobtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: portofoliobtn)
        portofoliobtn.tap = {
            let vc = PortofolioViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let setting = UIButton(type: .system)
        setting.setImage(#imageLiteral(resourceName: "Profile").withRenderingMode(.alwaysOriginal), for: .normal)
        setting.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: setting)
        setting.tap = didTapSettings
    }
}
