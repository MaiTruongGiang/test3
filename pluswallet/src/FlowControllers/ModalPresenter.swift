//
//  ModalPresenter.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-25.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit
import LocalAuthentication
import PLCore
import FirebaseAuth

class ModalPresenter: Subscriber, Trackable {

    // MARK: - Public
    let primaryWalletManager: BTCWalletManager
    var walletManagers: [String: WalletManager]
    lazy var supportCenter: SupportCenterContainer = {
        return SupportCenterContainer(walletManagers: self.walletManagers)
    }()

    init(walletManagers: [String: WalletManager], window: UIWindow) {
        self.window = window
        self.walletManagers = walletManagers
        guard let btcManager = walletManagers[Currencies.btc.code]! as? BTCWalletManager else {
            fatalError("Primary Wallet failed while assign")
        }
        self.primaryWalletManager = btcManager
        self.modalTransitionDelegate = ModalTransitionDelegate(type: .regular)
        self.wipeNavigationDelegate = StartNavigationDelegate()
        addSubscriptions()
        
        if !Reachability.isReachable {
            showNotReachable()
        }
    }

    deinit {
        Store.unsubscribe(self)
    }

    // MARK: - Private
    private let window: UIWindow
    private let alertHeight: CGFloat = 260.0
    private let modalTransitionDelegate: ModalTransitionDelegate
    private let messagePresenter = MessageUIPresenter()
    private let securityCenterNavigationDelegate = SecurityCenterNavigationDelegate()
    private let verifyPinTransitionDelegate = PinTransitioningDelegate()
    private var currentRequest: PaymentRequest?
//    private var reachability = ReachabilityMonitor()
    private var notReachableAlert: InAppAlert?
    private let wipeNavigationDelegate: StartNavigationDelegate
    
    // swiftlint:disable:next cyclomatic_complexity 
    private func addSubscriptions() {

        Store.lazySubscribe(self,
                        selector: { $0.rootModal != $1.rootModal},
                        callback: { [weak self] in self?.presentModal($0.rootModal) })

        Store.lazySubscribe(self,
                        selector: { $0.alert != $1.alert && $1.alert != .none },
                        callback: { [weak self] in self?.handleAlertChange($0.alert) })

        Store.subscribeAsTrigger(self, name: .presentFaq("", nil), callback: { [weak self] in
            guard let trigger = $0 else { return }
            if case .presentFaq(let articleId, let currency) = trigger {
                self?.presentFaq(articleId: articleId, currency: currency)
            }
        })

        //Subscribe to prompt actions
        Store.subscribeAsTrigger(self, name: .promptUpgradePin, callback: { [weak self] _ in
            self?.presentUpgradePin()
        })
        Store.subscribeAsTrigger(self, name: .promptPaperKey, callback: { [weak self] _ in
            self?.presentWritePaperKey()
        })
        Store.subscribeAsTrigger(self, name: .promptBiometrics, callback: { [weak self] _ in
            self?.presentBiometricsSetting()
        })
        Store.subscribeAsTrigger(self, name: .promptShareData, callback: { [weak self] _ in
            self?.promptShareData()
        })
        Store.subscribeAsTrigger(self, name: .openFile(Data()), callback: { [weak self] in
            guard let trigger = $0 else { return }
            if case .openFile(let file) = trigger {
                self?.handleFile(file)
            }
        })

        walletManagers.values.map({ $0.currency }).filter({ $0 is Bitcoin }).forEach { currency in
            // TODO: show alert and automatic rescan instead of showing the rescan screen
            Store.subscribeAsTrigger(self, name: .recommendRescan(currency), callback: { [weak self] _ in
                self?.presentRescan(currency: currency)
            })
        }

        //URLs
        Store.subscribeAsTrigger(self, name: .receivedPaymentRequest(nil), callback: { [weak self] in
            guard let trigger = $0 else { return }
            if case let .receivedPaymentRequest(request) = trigger {
                if let request = request {
                    self?.handlePaymentRequest(request: request)
                }
            }
        })
        Store.subscribeAsTrigger(self, name: .scanQr, callback: { [weak self] _ in
            self?.handleScanQrURL()
        })
        Store.subscribeAsTrigger(self, name: .copyWalletAddresses(nil, nil), callback: { [weak self] in
            guard let trigger = $0 else { return }
            if case .copyWalletAddresses(let success, let error) = trigger {
                self?.handleCopyAddresses(success: success, error: error)
            }
        })
        Store.subscribeAsTrigger(self, name: .authenticateForPlatform("", true, {_ in}), callback: { [unowned self] in
            guard let trigger = $0 else { return }
            if case .authenticateForPlatform(let prompt, let allowBiometricAuth, let callback) = trigger {
                self.authenticateForPlatform(prompt: prompt, allowBiometricAuth: allowBiometricAuth, callback: callback)
            }
        })
        Store.subscribeAsTrigger(self, name: .confirmTransaction(Currencies.btc, Amount.empty, Amount.empty, "", {_ in}), callback: { [unowned self] in
            guard let trigger = $0 else { return }
            if case .confirmTransaction(let currency, let amount, let fee, let address, let callback) = trigger {
                self.confirmTransaction(currency: currency, amount: amount, fee: fee, address: address, callback: callback)
            }
        })
        Reachability.addDidChangeCallback({ [weak self] isReachable in
            if isReachable {
                self?.hideNotReachable()
            } else {
                self?.showNotReachable()
            }
        })
        Store.subscribeAsTrigger(self, name: .lightWeightAlert(""), callback: { [weak self] in
            guard let trigger = $0 else { return }
            if case let .lightWeightAlert(message) = trigger {
                self?.showLightWeightAlert(message: message)
            }
        })
        Store.subscribeAsTrigger(self, name: .showAlert(nil), callback: { [weak self] in
            guard let trigger = $0 else { return }
            if case let .showAlert(alert) = trigger {
                if let alert = alert {
                    self?.topViewController?.present(alert, animated: true, completion: nil)
                }
            }
        })
        
        Store.subscribeAsTrigger(self, name: .wipeWalletNoPrompt, callback: { [weak self] _ in
            self?.wipeWalletNoPrompt()
        })
        Store.subscribeAsTrigger(self, name: .showCurrency(Currencies.btc), callback: { [unowned self] in
            guard let trigger = $0 else { return }
            if case .showCurrency(let currency) = trigger {
                self.showAccountView(currency: currency, animated: true, completion: nil)
            }
        })
    }

    private func presentModal(_ type: RootModal, configuration: ((UIViewController) -> Void)? = nil) {
        guard type != .loginScan else { return presentLoginScan() }
        guard let vc = rootModalViewController(type) else {
            Store.perform(action: RootModalActions.Present(modal: .none))
            return
        }
        vc.transitioningDelegate = modalTransitionDelegate
        vc.modalPresentationStyle = .overFullScreen
        vc.modalPresentationCapturesStatusBarAppearance = true
        configuration?(vc)
        topViewController?.present(vc, animated: true) {
            Store.perform(action: RootModalActions.Present(modal: .none))
            Store.trigger(name: .hideStatusBar)
        }
    }

    private func handleAlertChange(_ type: AlertType) {
        guard type != .none else { return }
        presentAlert(type, completion: {
            Store.perform(action: Alert.Hide())
        })
    }

    private func presentAlert(_ type: AlertType, completion: @escaping () -> Void) {
        let alertView = AlertView(type: type)
        let window = UIApplication.shared.keyWindow!
        let size = window.bounds.size
        window.addSubview(alertView)

        let topConstraint = alertView.constraint(.top, toView: window, constant: size.height)
        alertView.constrain([
            alertView.constraint(.width, constant: size.width),
            alertView.constraint(.height, constant: alertHeight + 25.0),
            alertView.constraint(.leading, toView: window, constant: nil),
            topConstraint ])
        window.layoutIfNeeded()

        UIView.spring(0.6, animations: {
            topConstraint?.constant = size.height - self.alertHeight
            window.layoutIfNeeded()
        }, completion: { _ in
            alertView.animate()
            UIView.spring(0.6, delay: 2.0, animations: {
                topConstraint?.constant = size.height
                window.layoutIfNeeded()
            }, completion: { _ in
                //TODO - Make these callbacks generic
                if case .paperKeySet(let callback) = type {
                    callback()
                }
                if case .pinSet(let callback) = type {
                    callback()
                }
                if case .sweepSuccess(let callback) = type {
                    callback()
                }
                completion()
                alertView.removeFromSuperview()
            })
        })
    }

    func presentFaq(articleId: String? = nil, currency: CurrencyDef? = nil) {
        supportCenter.modalPresentationStyle = .overFullScreen
        supportCenter.modalPresentationCapturesStatusBarAppearance = true
        supportCenter.transitioningDelegate = supportCenter
        var url: String
        if let articleId = articleId {
            url = "/support/article?slug=\(articleId)"
            if let currency = currency {
                url += "&currency=\(currency.code.lowercased())"
            }
        } else {
            url = "/support?"
        }
        supportCenter.navigate(to: url)
        topViewController?.present(supportCenter, animated: true, completion: {})
    }

    private func rootModalViewController(_ type: RootModal) -> UIViewController? {
        switch type {
        case .none:
            return nil
        case .send(let currency):
            return makeSendView(currency: currency)
        case .receive(let currency):
            return receiveView(currency: currency, isRequestAmountVisible: (currency.urlSchemes != nil))
        case .loginScan:
            return nil //The scan view needs a custom presentation
        case .loginAddress:
            return receiveView(currency: Currencies.btc, isRequestAmountVisible: false)
        case .requestAmount(let currency):
            guard let walletManager = walletManagers[currency.code] else { return nil }
            var address: String?
            switch currency.code {
            case Currencies.btc.code:
                address = walletManager.wallet?.receiveAddress
            case Currencies.bch.code:
                address = walletManager.wallet?.receiveAddress.bCashAddr
            case Currencies.eth.code:
                address = (walletManager as? EthWalletManager)?.address
            default:
                if currency is ERC20Token {
                    address = (walletManager as? EthWalletManager)?.address
                }
            }
            guard let receiveAddress = address else { return nil }
            let requestVc = RequestAmountViewController(currency: currency, receiveAddress: receiveAddress)
            requestVc.presentEmail = { [weak self] bitcoinURL, image in
                self?.messagePresenter.presenter = self?.topViewController
                self?.messagePresenter.presentMailCompose(bitcoinURL: bitcoinURL, image: image)
            }
            requestVc.presentText = { [weak self] bitcoinURL, image in
                self?.messagePresenter.presenter = self?.topViewController
                self?.messagePresenter.presentMessageCompose(bitcoinURL: bitcoinURL, image: image)
            }
            return ModalViewController(childViewController: requestVc)
        case .buy(let currency):
            presentPlatformWebViewController("/buy?currency=\(currency.code)")
            return nil
        case .sell(let currency):
            presentPlatformWebViewController("/sell?currency=\(currency.code)")
            return nil
        }

    }

    private func makeSendView(currency: CurrencyDef) -> UIViewController? {
        guard !(currency.state?.isRescanning ?? false) else {
            let alert = UIAlertController(title: S.Alert.error, message: S.Send.isRescanning, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: S.Button.ok, style: .cancel, handler: nil))
            topViewController?.present(alert, animated: true, completion: nil)
            return nil
        }
        guard let walletManager = walletManagers[currency.code] else { return nil }
        guard let kvStore = Backend.kvStore else { return nil }
        guard let sender = currency.createSender(walletManager: walletManager, kvStore: kvStore) else { return nil }
        let sendVC = SendViewController(sender: sender,
                                        initialRequest: currentRequest,
                                        currency: currency)
        currentRequest = nil

        if Store.state.isLoginRequired {
            sendVC.isPresentedFromLock = true
        }

       // let root = ModalViewController(childViewController: sendVC)
        sendVC.presentScan = presentScan(parent: sendVC, currency: currency)
        sendVC.presentVerifyPin = { [weak self, weak sendVC] bodyText, success in
            guard let myself = self else { return }
            let walletManager = myself.primaryWalletManager
            let vc = VerifyPinViewController(bodyText: bodyText, pinLength: Store.state.pinLength, walletManager: walletManager, success: success)
            vc.transitioningDelegate = self?.verifyPinTransitionDelegate
            vc.modalPresentationStyle = .overFullScreen
            vc.modalPresentationCapturesStatusBarAppearance = true
            sendVC?.view.isFrameChangeBlocked = true
            sendVC?.present(vc, animated: true, completion: nil)
        }
        sendVC.onPublishSuccess = { [weak self] in
            self?.presentAlert(.sendSuccess, completion: {})
        }
        return sendVC
    }

    private func receiveView(currency: CurrencyDef, isRequestAmountVisible: Bool) -> UIViewController? {
        let receiveVC = ReceiveViewController(currency: currency, isRequestAmountVisible: isRequestAmountVisible)
       // let root = ModalViewController(childViewController: receiveVC)
        receiveVC.presentEmail = { [weak self, weak receiveVC] address, image in
            guard let vc = receiveVC, let uri = currency.addressURI(address) else { return }
            self?.messagePresenter.presenter = vc
            self?.messagePresenter.presentMailCompose(uri: uri, image: image)
        }
        receiveVC.presentText = { [weak self, weak receiveVC] address, image in
            guard let vc = receiveVC, let uri = currency.addressURI(address) else { return }
            self?.messagePresenter.presenter = vc
            self?.messagePresenter.presentMessageCompose(uri: uri, image: image)
        }
        return receiveVC
       // return root
    }

    private func presentLoginScan() {
        //TODO:BCH URL support
        guard let top = topViewController else { return }
        let present = presentScan(parent: top, currency: Currencies.btc)
        Store.perform(action: RootModalActions.Present(modal: .none))
        present({ paymentRequest in
            guard let request = paymentRequest else { return }
            self.currentRequest = request
            self.presentModal(.send(currency: Currencies.btc))
        })
    }

    // MARK: Settings
    func presentSettings() {
        guard let top = topViewController else { return }
        let settings = SettingsViewController()
        settings.addCloseNavigationItem(tintColor: .white)
        let menuNav = UINavigationController()
        //menuNav.setDarkStyle()
        let btcWalletManager = primaryWalletManager
        let nc = ModalNavigationController(rootViewController: settings)
        //nc.setClearNavbar()
        //nc.setGradientBlueStyle()
        nc.isNavigationBarHidden = true

//        settings.didTapSupport = { [weak self] in
//            self?.presentFaq()
//        }

        settings.didTapSecurity = { [weak self] in
            self?.presentSecurityCenter(parent: settings)
        }

        // hien thi phan setting
        settings.didTapDisplay = {
            let preferencesItems: [MenuSettingItem] = [
                // Display Currency
                MenuSettingItem(title: S.Settings.currency, accessoryText: {
                    let code = Store.state.defaultCurrencyCode
                    let components: [String : String] = [NSLocale.Key.currencyCode.rawValue: code]
                    let identifier = Locale.identifier(fromComponents: components)
                    return Locale(identifier: identifier).currencyCode ?? ""
                }, callback: {
                    menuNav.isNavigationBarHidden = false
                    menuNav.pushViewController(DefaultCurrencyViewController(walletManager: btcWalletManager), animated: true)
                }),

                // Share Anonymous Data
                MenuSettingItem(title: S.Settings.shareData, callback: {
                    menuNav.pushViewController(ShareDataViewController(), animated: true)
                }),

                // Reset Wallets
//                MenuSettingItem(title: S.Settings.resetCurrencies, callback: {
//                    menuNav.dismiss(animated: true, completion: {
//                        Store.trigger(name: .resetDisplayCurrencies)
//                    })
//                }),
                MenuSettingItem(title: S.Settings.wipe) { [unowned self] in
                    let mc = ModalNavigationController()
                    mc.setClearNavbar()
                    mc.setWhiteStyle()
                    mc.delegate = self.wipeNavigationDelegate
                    let start = StartWipeWalletViewController { [unowned self] in
                        let recover = EnterPhraseViewController(walletManager: btcWalletManager, reason: .validateForWipingWallet({
                            self.wipeWallet()

                        }))
                        print("Nhap 12 chu vao")
                        //recover.navigationController?.isNavigationBarHidden = false
                        //recover.navigationController?.navigationBar.isHidden = false
                     mc.navigationController?.navigationBar.isHidden = false

                        mc.pushViewController(recover, animated: true)
                    }
                    start.addCloseNavigationItem(tintColor: .white)
                    start.navigationItem.title = S.WipeWallet.title
                    mc.viewControllers = [start]
                    menuNav.dismiss(animated: true) {
                        self.topViewController?.present(mc, animated: true, completion: nil)
                    }
                }
            ]
            let settings = MenuSettingViewController(items: preferencesItems, title: S.Settings.title)
            settings.addCloseNavigationItem(tintColor: .white)
            //settings.navigationItem.backBarButtonItem = UIBarButtonItem(title: "aaa", style: .plain, target: nil, action: nil)
            menuNav.viewControllers = [settings]
            nc.isNavigationBarHidden = false

            nc.present(menuNav, animated: true, completion: nil)
            //nc.pushViewController(menuNav, animated: true)

        }
        settings.didTapAbout = {}
//        settings.didTapAbout = strongify(self) { myself in
//            let biometricsSettings = BiometricsSettingsViewController(walletManager: self.primaryWalletManager)
//            biometricsSettings.presentSpendingLimit = {
//                myself.pushBiometricsSpendingLimit(onNc: nc)
//            }
//            nc.isNavigationBarHidden = false
//            nc.pushViewController(biometricsSettings, animated: true)
//        }

        settings.didTapProfile = {
            if Auth.auth().currentUser != nil {
                let profile = ProfileViewController()
                nc.isNavigationBarHidden = false
                nc.pushViewController(profile, animated: true)
            } else{
                let profileLogin = ProfileLoginViewController()
                nc.isNavigationBarHidden = false
                nc.pushViewController(profileLogin, animated: true)
            }
        }

        window.rootViewController?.present(nc, animated: true, completion: nil)
    }

    private func presentScan(parent: UIViewController, currency: CurrencyDef) -> PresentScan {
        return { [weak parent] scanCompletion in
            guard ScanViewController.isCameraAllowed else {
                self.saveEvent("scan.cameraDenied")
                if let parent = parent {
                    ScanViewController.presentCameraUnavailableAlert(fromRoot: parent)
                }
                return
            }
            let vc = ScanViewController(currency: currency, completion: { paymentRequest in
                scanCompletion(paymentRequest)
                parent?.view.isFrameChangeBlocked = false
            })
            parent?.view.isFrameChangeBlocked = true
            parent?.present(vc, animated: true, completion: {})
        }
    }

    func presentSecurityCenter(parent: UIViewController) {
        let securityCenter = SecurityCenterViewController(walletManager: primaryWalletManager)
        let nc = ModalNavigationController(rootViewController: securityCenter)
        nc.setDefaultStyle()
        nc.isNavigationBarHidden = true
        nc.delegate = securityCenterNavigationDelegate
        securityCenter.didTapPin = {
            let updatePin = UpdatePinViewController(walletManager: self.primaryWalletManager, type: .update)
            nc.pushViewController(updatePin, animated: true)
        }
        securityCenter.didTapBiometrics = strongify(self) { myself in
            let biometricsSettings = BiometricsSettingsViewController(walletManager: self.primaryWalletManager)
            biometricsSettings.presentSpendingLimit = {
                myself.pushBiometricsSpendingLimit(onNc: nc)
            }
            nc.pushViewController(biometricsSettings, animated: true)
        }
        securityCenter.didTapPaperKey = { [weak self] in
            self?.presentWritePaperKey(fromViewController: nc)
        }
//        nc.pushViewController(securityCenter, animated: true)
        parent.present(nc, animated: true, completion: nil)
    }

    private func pushBiometricsSpendingLimit(onNc: UINavigationController) {
        let verify = VerifyPinViewController(bodyText: S.VerifyPin.continueBody, pinLength: Store.state.pinLength, walletManager: primaryWalletManager, success: { _ in
            let spendingLimit = BiometricsSpendingLimitViewController(walletManager: self.primaryWalletManager)
            onNc.pushViewController(spendingLimit, animated: true)
        })
        verify.transitioningDelegate = verifyPinTransitionDelegate
        verify.modalPresentationStyle = .overFullScreen
        verify.modalPresentationCapturesStatusBarAppearance = true
        onNc.present(verify, animated: true, completion: nil)
    }

    private func presentWritePaperKey(fromViewController vc: UIViewController) {
        let paperPhraseNavigationController = UINavigationController()
     //  paperPhraseNavigationController.setClearNavbar()
//        paperPhraseNavigationController.setWhiteStyle()
//        paperPhraseNavigationController.navigationBar.applyNavigationGradient(colors: [UIColor.gradientStart , UIColor.gradientEnd])
        paperPhraseNavigationController.modalPresentationStyle = .overFullScreen

        let start = StartPaperPhraseViewController(callback: { [weak self] in
            print("dang chay trong presentWritePaperKey ")
            guard let `self` = self else { return }
            let verify = VerifyPinViewController(bodyText: S.VerifyPin.continueBody, pinLength: Store.state.pinLength, walletManager: self.primaryWalletManager, success: { pin in
                self.pushWritePaperPhrase(navigationController: paperPhraseNavigationController, pin: pin)
            })
            verify.transitioningDelegate = self.verifyPinTransitionDelegate
            verify.modalPresentationStyle = .overFullScreen
            verify.modalPresentationCapturesStatusBarAppearance = true
            paperPhraseNavigationController.present(verify, animated: true, completion: nil)
        })
        start.addCloseNavigationItem(tintColor: .white)
        start.navigationItem.title = S.SecurityCenter.Cells.paperKeyTitle
       // let faqButton = UIButton.buildFaqButton(articleId: ArticleIds.paperKey)
      //  faqButton.tintColor = .white
//        start.navigationItem.rightBarButtonItems = [UIBarButtonItem.negativePadding, UIBarButtonItem(customView: faqButton)]
        paperPhraseNavigationController.viewControllers = [start]
        vc.present(paperPhraseNavigationController, animated: true, completion: nil)
    }

    private func pushWritePaperPhrase(navigationController: UINavigationController, pin: String) {
        let walletManager = primaryWalletManager
        var writeViewController: WritePaperPhraseViewController?
        writeViewController = WritePaperPhraseViewController(walletManager: walletManager, pin: pin, callback: {
            var confirm: ConfirmPaperPhraseViewController?
            confirm = ConfirmPaperPhraseViewController(walletManager: walletManager, pin: pin, callback: {
                confirm?.dismiss(animated: true, completion: {
                    Store.perform(action: Alert.Show(.paperKeySet(callback: {
                        Store.perform(action: HideStartFlow())
                    })))
                })
            })
            writeViewController?.navigationItem.title = S.SecurityCenter.Cells.paperKeyTitle
            if let confirm = confirm {
                navigationController.pushViewController(confirm, animated: true)
            }
        })

        writeViewController?.addCloseNavigationItem(tintColor: .white)
        writeViewController?.navigationItem.title = S.SecurityCenter.Cells.paperKeyTitle
        guard let writeVC = writeViewController else { return }
        navigationController.pushViewController(writeVC, animated: true)
    }

    private func presentPlatformWebViewController(_ mountPoint: String) {
        let vc: BRWebViewController
        #if Debug || Testflight
            vc = BRWebViewController(bundleName: "brd-web-staging", mountPoint: mountPoint, walletManagers: walletManagers)
        #else
            vc = BRWebViewController(bundleName: "brd-web", mountPoint: mountPoint, walletManagers: walletManagers)
        #endif
        vc.startServer()
        vc.preload()
        self.topViewController?.present(vc, animated: true, completion: nil)
    }

    private func presentRescan(currency: CurrencyDef) {
        let vc = ReScanViewController(currency: currency)
        let nc = UINavigationController(rootViewController: vc)
        nc.setClearNavbar()
        vc.addCloseNavigationItem()
        topViewController?.present(nc, animated: true, completion: nil)
    }

    private func wipeWallet() {
        let alert = UIAlertController(title: S.WipeWallet.alertTitle, message: S.WipeWallet.alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.Button.cancel, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: S.WipeWallet.wipe, style: .default, handler: { _ in
            self.topViewController?.dismiss(animated: true, completion: {
                self.wipeWalletNoPrompt()
            })
        }))
        topViewController?.present(alert, animated: true, completion: nil)
    }

    private func wipeWalletNoPrompt() {
        let activity = BRActivityViewController(message: S.WipeWallet.wiping)
        self.topViewController?.present(activity, animated: true, completion: nil)
        DispatchQueue.walletQueue.async {
            self.walletManagers.values.forEach({ $0.peerManager?.disconnect() })
            DispatchQueue.walletQueue.asyncAfter(deadline: .now() + 2.0, execute: {
                let success = self.primaryWalletManager.wipeWallet(pin: "forceWipe")
                DispatchQueue.main.async {
                    activity.dismiss(animated: true) {
                        if success {
                            Store.trigger(name: .reinitWalletManager({
                                Store.trigger(name: .resetDisplayCurrencies)
                            }))
                        } else {
                            let failure = UIAlertController(title: S.WipeWallet.failedTitle, message: S.WipeWallet.failedMessage, preferredStyle: .alert)
                            failure.addAction(UIAlertAction(title: S.Button.ok, style: .default, handler: nil))
                            self.topViewController?.present(failure, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }

    private func presentKeyImport(walletManager: BTCWalletManager) {
        let nc = ModalNavigationController()
        nc.setClearNavbar()
        nc.setWhiteStyle()
        let start = StartImportViewController(walletManager: walletManager)
        start.addCloseNavigationItem(tintColor: .white)
        start.navigationItem.title = S.Import.title
        let faqButton = UIButton.buildFaqButton(articleId: ArticleIds.importWallet, currency: walletManager.currency)
        faqButton.tintColor = .white
        start.navigationItem.rightBarButtonItems = [UIBarButtonItem.negativePadding, UIBarButtonItem(customView: faqButton)]
        nc.viewControllers = [start]
        topViewController?.present(nc, animated: true, completion: nil)
    }

    // MARK: - Prompts
    func presentBiometricsSetting() {
        let walletManager = primaryWalletManager
        let biometricsSettings = BiometricsSettingsViewController(walletManager: walletManager)
        biometricsSettings.addCloseNavigationItem(tintColor: .white)
        let nc = ModalNavigationController(rootViewController: biometricsSettings)
        biometricsSettings.presentSpendingLimit = strongify(self) { myself in
            myself.pushBiometricsSpendingLimit(onNc: nc)
        }
        nc.setDefaultStyle()
        nc.isNavigationBarHidden = true
        nc.delegate = securityCenterNavigationDelegate
        topViewController?.present(nc, animated: true, completion: nil)
    }

    private func promptShareData() {
        let shareData = ShareDataViewController()
        let nc = ModalNavigationController(rootViewController: shareData)
        nc.setDefaultStyle()
        nc.isNavigationBarHidden = true
        nc.delegate = securityCenterNavigationDelegate
        shareData.addCloseNavigationItem()
        topViewController?.present(nc, animated: true, completion: nil)
    }

    func presentWritePaperKey() {
        guard let vc = topViewController else { return }
        presentWritePaperKey(fromViewController: vc)
    }
//
    func presentUpgradePin() {
        let walletManager = primaryWalletManager
        let updatePin = UpdatePinViewController(walletManager: walletManager, type: .update)
        let nc = ModalNavigationController(rootViewController: updatePin)
        nc.setDefaultStyle()
        nc.isNavigationBarHidden = true
        nc.delegate = securityCenterNavigationDelegate
        updatePin.addCloseNavigationItem()
        topViewController?.present(nc, animated: true, completion: nil)
    }

    private func handleFile(_ file: Data) {
        if let request = PaymentProtocolRequest(data: file) {
            if let topVC = topViewController as? ModalViewController {
                let attemptConfirmRequest: () -> Bool = {
                    if let send = topVC.childViewController as? SendViewController {
                        send.confirmProtocolRequest(request)
                        return true
                    }
                    return false
                }
                if !attemptConfirmRequest() {
                    modalTransitionDelegate.reset()
                    topVC.dismiss(animated: true, completion: {
                        //TODO:BCH
                        Store.perform(action: RootModalActions.Present(modal: .send(currency: Currencies.btc)))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { //This is a hack because present has no callback
                            _ = attemptConfirmRequest()
                        })
                    })
                }
            }
        } else if let ack = PaymentProtocolACK(data: file) {
            if let memo = ack.memo {
                let alert = UIAlertController(title: "", message: memo, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: S.Button.ok, style: .cancel, handler: nil))
                topViewController?.present(alert, animated: true, completion: nil)
            }
        //TODO - handle payment type
        } else {
            let alert = UIAlertController(title: S.Alert.error, message: S.PaymentProtocol.Errors.corruptedDocument, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: S.Button.ok, style: .cancel, handler: nil))
            topViewController?.present(alert, animated: true, completion: nil)
        }
    }

    private func handlePaymentRequest(request: PaymentRequest) {
        self.currentRequest = request
        guard !Store.state.isLoginRequired else { presentModal(.send(currency: request.currency)); return }

        showAccountView(currency: request.currency, animated: false) {
            self.presentModal(.send(currency: request.currency))
        }
    }

    private func showAccountView(currency: CurrencyDef, animated: Bool, completion: (() -> Void)?) {
        let pushAccountView = {
            guard let nc = self.topViewController?.navigationController as? RootNavigationController,
                nc.viewControllers.count == 1 else { return }
            guard let walletManager = self.walletManagers[currency.code] else { return }
            let accountViewController = AccountViewController(currency: currency, walletManager: walletManager)
            nc.pushViewController(accountViewController, animated: animated)
            completion?()
        }

        if let accountVC = topViewController as? AccountViewController {
            if accountVC.currency.matches(currency) {
                completion?()
            } else {
                accountVC.navigationController?.popToRootViewController(animated: false)
                pushAccountView()
            }
        } else if topViewController is HomeScreenViewController {
            pushAccountView()
        } else if let presented = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            if let nc = presented.presentingViewController as? RootNavigationController, nc.viewControllers.count > 1 {
                // modal on top of another account screen
                presented.dismiss(animated: false) {
                    self.showAccountView(currency: currency, animated: animated, completion: completion)
                }
            } else {
                presented.dismiss(animated: true) {
                    pushAccountView()
                }
            }
        }
    }

    private func handleScanQrURL() {
        guard !Store.state.isLoginRequired else { presentLoginScan(); return }
        if topViewController is AccountViewController || topViewController is LoginViewController {
            presentLoginScan()
        } else {
            if let presented = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
                presented.dismiss(animated: true, completion: {
                    self.presentLoginScan()
                })
            }
        }
    }

    private func handleCopyAddresses(success: String?, error: String?) {
        let walletManager = primaryWalletManager // TODO:BCH
        let alert = UIAlertController(title: S.URLHandling.addressListAlertTitle, message: S.URLHandling.addressListAlertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.Button.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: S.URLHandling.copy, style: .default, handler: { [weak self] _ in
            let verify = VerifyPinViewController(bodyText: S.URLHandling.addressListVerifyPrompt, pinLength: Store.state.pinLength, walletManager: walletManager, success: { [weak self] _ in
                self?.copyAllAddressesToClipboard()
                Store.perform(action: Alert.Show(.addressesCopied))
                if let success = success, let url = URL(string: success) {
                    UIApplication.shared.openURL(url)
                }
            })
            verify.transitioningDelegate = self?.verifyPinTransitionDelegate
            verify.modalPresentationStyle = .overFullScreen
            verify.modalPresentationCapturesStatusBarAppearance = true
            self?.topViewController?.present(verify, animated: true, completion: nil)
        }))
        topViewController?.present(alert, animated: true, completion: nil)
    }

    private func authenticateForPlatform(prompt: String, allowBiometricAuth: Bool, callback: @escaping (PlatformAuthResult) -> Void) {
        if UserDefaults.isBiometricsEnabled && allowBiometricAuth {
            primaryWalletManager.authenticate(biometricsPrompt: prompt, completion: { result in
                switch result {
                case .success:
                    return callback(.success(nil))
                case .cancel:
                    return callback(.cancelled)
                case .failure:
                    self.verifyPinForPlatform(prompt: prompt, callback: callback)
                case .fallback:
                    self.verifyPinForPlatform(prompt: prompt, callback: callback)
                }
            })
        } else {
            self.verifyPinForPlatform(prompt: prompt, callback: callback)
        }
    }

    private func verifyPinForPlatform(prompt: String, callback: @escaping (PlatformAuthResult) -> Void) {
        let verify = VerifyPinViewController(bodyText: prompt, pinLength: Store.state.pinLength, walletManager: primaryWalletManager, success: { pin in
                callback(.success(pin))
        })
        verify.didCancel = { callback(.cancelled) }
        verify.transitioningDelegate = verifyPinTransitionDelegate
        verify.modalPresentationStyle = .overFullScreen
        verify.modalPresentationCapturesStatusBarAppearance = true
        topViewController?.present(verify, animated: true, completion: nil)
    }

    private func confirmTransaction(currency: CurrencyDef, amount: Amount, fee: Amount, address: String, callback: @escaping (Bool) -> Void) {
        let confirm = ConfirmationViewController(amount: amount,
                                                 fee: fee,
                                                 feeType: .regular,
                                                 address: address,
                                                 isUsingBiometrics: false,
                                                 currency: currency)
        let transitionDelegate = PinTransitioningDelegate()
        transitionDelegate.shouldShowMaskView = true
        confirm.transitioningDelegate = transitionDelegate
        confirm.modalPresentationStyle = .overFullScreen
        confirm.modalPresentationCapturesStatusBarAppearance = true
        confirm.successCallback = {
            callback(true)
        }
        confirm.cancelCallback = {
            callback(false)
        }
        topViewController?.present(confirm, animated: true, completion: nil)
    }

    private func copyAllAddressesToClipboard() {
        guard let wallet = primaryWalletManager.wallet else { return } // TODO:BCH
        let addresses = wallet.allAddresses.filter({wallet.addressIsUsed($0)})
        UIPasteboard.general.string = addresses.joined(separator: "\n")
    }

    private var topViewController: UIViewController? {
        var viewController = window.rootViewController
        if let nc = viewController as? UINavigationController {
            viewController = nc.topViewController
        }
        while viewController?.presentedViewController != nil {
            viewController = viewController?.presentedViewController
        }
        return viewController
    }

    private func showNotReachable() {
        guard notReachableAlert == nil else { return }
        let alert = InAppAlert(message: S.Alert.noInternet, image: #imageLiteral(resourceName: "BrokenCloud"))
        notReachableAlert = alert
        let window = UIApplication.shared.keyWindow!
        let size = window.bounds.size
        window.addSubview(alert)
        let bottomConstraint = alert.bottomAnchor.constraint(equalTo: window.topAnchor, constant: 0.0)
        alert.constrain([
            alert.constraint(.width, constant: size.width),
            alert.constraint(.height, constant: InAppAlert.height),
            alert.constraint(.leading, toView: window, constant: nil),
            bottomConstraint ])
        window.layoutIfNeeded()
        alert.bottomConstraint = bottomConstraint
        alert.hide = {
            self.hideNotReachable()
        }
        UIView.spring(C.animationDuration, animations: {
            alert.bottomConstraint?.constant = InAppAlert.height
            window.layoutIfNeeded()
        }, completion: {_ in})
    }

    private func hideNotReachable() {
        UIView.animate(withDuration: C.animationDuration, animations: {
            self.notReachableAlert?.bottomConstraint?.constant = 0.0
            self.notReachableAlert?.superview?.layoutIfNeeded()
        }, completion: { _ in
            self.notReachableAlert?.removeFromSuperview()
            self.notReachableAlert = nil
        })
    }

    private func showLightWeightAlert(message: String) {
        let alert = LightWeightAlert(message: message)
        let view = UIApplication.shared.keyWindow!
        view.addSubview(alert)
        alert.constrain([
            alert.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alert.centerYAnchor.constraint(equalTo: view.centerYAnchor) ])
        alert.background.effect = nil
        UIView.animate(withDuration: 0.6, animations: {
            alert.background.effect = alert.effect
        }, completion: { _ in
            UIView.animate(withDuration: 0.6, delay: 1.0, options: [], animations: {
                alert.background.effect = nil
            }, completion: { _ in
                alert.removeFromSuperview()
            })
        })
    }

    private func showEmailLogsModal() {
        self.messagePresenter.presenter = self.topViewController
        self.messagePresenter.presentEmailLogs()
    }
}

class SecurityCenterNavigationDelegate: NSObject, UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        guard let coordinator = navigationController.topViewController?.transitionCoordinator else { return }

        if coordinator.isInteractive {
            coordinator.notifyWhenInteractionEnds { context in
                //We only want to style the view controller if the
                //pop animation wasn't cancelled
                if !context.isCancelled {
                    self.setStyle(navigationController: navigationController, viewController: viewController)
                }
            }
        } else {
            setStyle(navigationController: navigationController, viewController: viewController)
        }
    }

    func setStyle(navigationController: UINavigationController, viewController: UIViewController) {
        if viewController is SecurityCenterViewController {
            navigationController.isNavigationBarHidden = true
        } else {
            navigationController.isNavigationBarHidden = false
        }

        if viewController is BiometricsSettingsViewController {
            navigationController.setWhiteStyle()
        } else {
            navigationController.setDefaultStyle()
        }
    }
}