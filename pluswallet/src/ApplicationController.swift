//
//  ApplicationController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-21.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit
import PLCore
import Alamofire
import SwiftyJSON

private let timeSinceLastExitKey = "TimeSinceLastExit"
private let shouldRequireLoginTimeoutKey = "ShouldRequireLoginTimeoutKey"

class ApplicationController: Subscriber, Trackable {

    let window = UIWindow()
    private var startFlowController: StartFlowPresenter?
    private var modalPresenter: ModalPresenter?
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private var walletManagers = [String: WalletManager]()
    private var walletCoordinator: WalletCoordinator?
    private var primaryWalletManager: BTCWalletManager? {
        return walletManagers[Currencies.btc.code] as? BTCWalletManager
    }

    private var kvStoreCoordinator: KVStoreCoordinator?
    fileprivate var application: UIApplication?
    private var urlController: URLController?
    private var defaultsUpdater: UserDefaultsUpdater?
    private var fetchCompletionHandler: ((UIBackgroundFetchResult) -> Void)?
    private var launchURL: URL?
    private var hasPerformedWalletDependentInitialization = false
    private var didInitWallet = false
    private let notificationHandler = NotificationHandler()
    private var isReachable = true {
        didSet {
            if oldValue == false && isReachable {
                self.retryAfterIsReachable()
            }
        }
    }

    // MARK: -
    init() {
        isReachable = Reachability.isReachable
        guardProtected(queue: DispatchQueue.walletQueue) {
            if UserDefaults.hasBchConnected {
                self.initWallet(completion: self.didAttemptInitWallet)
            } else {
                self.initWalletWithMigration(completion: self.didAttemptInitWallet)
            }
        }
    }

    /// Migrate pre-fork BTC transactions to BCH wallet
    private func initWalletWithMigration(completion: @escaping () -> Void) {
        let btc = Currencies.btc
        let bch = Currencies.bch
        guard let btcWalletManager = try? BTCWalletManager(currency: btc, dbPath: btc.dbPath) else { return }
        walletManagers[btc.code] = btcWalletManager
        btcWalletManager.initWallet { [unowned self] success in
            guard success else {
                completion()
                return
            }
            
            btcWalletManager.initPeerManager {
                btcWalletManager.db?.loadTransactions { txns in
                    btcWalletManager.db?.loadBlocks { blocks in
                        let preForkTransactions = txns.compactMap {$0}.filter { $0.pointee.blockHeight < C.bCashForkBlockHeight }
                        let preForkBlocks = blocks.compactMap {$0}.filter { $0.pointee.height < C.bCashForkBlockHeight }
                        var bchWalletManager: BTCWalletManager?
                        if preForkBlocks.count > 0 || blocks.count == 0 {
                            bchWalletManager = try? BTCWalletManager(currency: bch, dbPath: bch.dbPath)
                        } else {
                            bchWalletManager = try? BTCWalletManager(currency: bch, dbPath: bch.dbPath, earliestKeyTimeOverride: C.bCashForkTimeStamp)
                        }
                        self.walletManagers[bch.code] = bchWalletManager
                        bchWalletManager?.initWallet(transactions: preForkTransactions)
                        bchWalletManager?.initPeerManager(blocks: preForkBlocks)
                        bchWalletManager?.db?.loadTransactions { storedTransactions in
                            if storedTransactions.count == 0 {
                                bchWalletManager?.wallet?.transactions.compactMap {$0}.forEach { txn in
                                    bchWalletManager?.db?.txAdded(txn)
                                }
                            }
                        }
                        // init other wallets
                        self.initWallet(completion: completion)
                    }
                }
            }
        }
    }

    private func initWallet(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        Store.state.currencies.forEach { currency in
            if walletManagers[currency.code] == nil {
                initWallet(currency: currency, dispatchGroup: dispatchGroup)
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    private func initWallet(currency: CurrencyDef, dispatchGroup: DispatchGroup) {
        if let token = currency as? ERC20Token {
            guard let ethWalletManager = walletManagers[Currencies.eth.code] as? EthWalletManager else { return }
            ethWalletManager.tokens.append(token)
            walletManagers[currency.code] = ethWalletManager
            return
        }
        dispatchGroup.enter()
        if let currency = currency as? Ethereum {
            let manager = EthWalletManager()
            walletManagers[currency.code] = manager
            dispatchGroup.leave()
            return
        }
        guard let currency = currency as? Bitcoin else { return }
        guard let walletManager = try? BTCWalletManager(currency: currency, dbPath: currency.dbPath) else { return }
        walletManagers[currency.code] = walletManager
        walletManager.initWallet { success in
            guard success else {
                // always keep BTC wallet manager, even if not initialized, since it the primaryWalletManager and needed for onboarding
                if !currency.matches(Currencies.btc) {
                    walletManager.db?.close()
                    walletManager.db?.delete()
                    self.walletManagers[currency.code] = nil
                }
                dispatchGroup.leave()
                return
            }
            walletManager.initPeerManager {
                dispatchGroup.leave()
            }
        }
    }

    private func didAttemptInitWallet() {
        DispatchQueue.main.async {
            self.didInitWallet = true
            if !self.hasPerformedWalletDependentInitialization {
                self.didInitWalletManager()
            }
        }
    }

    func launch(application: UIApplication, options: [UIApplicationLaunchOptionsKey: Any]?) {
        self.application = application
        //application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        setup()
        handleLaunchOptions(options)
        Reachability.addDidChangeCallback({ isReachable in
            self.isReachable = isReachable
        })
        
        updateAssetBundles()
        if !hasPerformedWalletDependentInitialization && didInitWallet {
            didInitWalletManager()
        }
    }

    private func setup() {
        setupDefaults()
        setupAppearance()
        setupRootViewController()
        window.makeKeyAndVisible()
        listenForPushNotificationRequest()
        offMainInitialization()

        Store.subscribeAsTrigger(self, name: .reinitWalletManager(nil), callback: {
            guard let trigger = $0 else { return }
            if case .reinitWalletManager(let callback) = trigger {
                if let callback = callback {
                    self.reinitWalletManager(callback: callback)
                }
            }
        })
    }

    func willEnterForeground() {
        guard let walletManager = primaryWalletManager,
            !walletManager.noWallet else { return }
        Backend.apiClient.sendLaunchEvent()
        if shouldRequireLogin() {
            Store.perform(action: RequireLogin())
        }
        DispatchQueue.walletQueue.async {
            self.walletManagers[UserDefaults.mostRecentSelectedCurrencyCode]?.peerManager?.connect()
        }
        updateAssetBundles()
        Backend.updateExchangeRates()
        Backend.updateFees()
        Backend.kvStore?.syncAllKeys { print("KV finished syncing. err: \(String(describing: $0))") }
        Backend.apiClient.updateFeatureFlags()
//        if !Store.state.isLoginRequired {
//            Backend.pigeonExchange?.fetchInbox()
//        }
    }

    func didEnterBackground() {
        // disconnect synced peer managers
        Store.state.currencies.filter { $0.state?.syncState == .success }.forEach { currency in
            DispatchQueue.walletQueue.async {
                self.walletManagers[currency.code]?.peerManager?.disconnect()
            }
        }
        //Save the backgrounding time if the user is logged in
        if !Store.state.isLoginRequired {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: timeSinceLastExitKey)
        }
        Backend.kvStore?.syncAllKeys { print("KV finished syncing. err: \(String(describing: $0))") }
    }

    func performFetch(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        fetchCompletionHandler = completionHandler
    }

    func open(url: URL) -> Bool {
        if let urlController = urlController {
            return urlController.handleUrl(url)
        } else {
            launchURL = url
            return false
        }
    }

    private func didInitWalletManager() {
        guard let primaryWalletManager = primaryWalletManager else { return }
        guard let rootViewController = window.rootViewController as? RootNavigationController else { return }
        walletCoordinator = WalletCoordinator(walletManagers: walletManagers)
        Backend.connectWallet(primaryWalletManager, currencies: Store.state.currencies, walletManagers: walletManagers.map { $0.1 })
        Backend.apiClient.sendLaunchEvent()
        setupEthInitialState()
        addTokenCountChangeListener()
        Store.perform(action: PinLength.set(primaryWalletManager.pinLength))
        rootViewController.walletManager = primaryWalletManager
        if let homeScreen = rootViewController.viewControllers.first as? HomeScreenViewController {
            homeScreen.primaryWalletManager = primaryWalletManager
        }
        hasPerformedWalletDependentInitialization = true
        if modalPresenter != nil {
            Store.unsubscribe(modalPresenter!)
        }
        modalPresenter = ModalPresenter(walletManagers: walletManagers, window: window)
        startFlowController = StartFlowPresenter(walletManager: primaryWalletManager, rootViewController: rootViewController)

        defaultsUpdater = UserDefaultsUpdater(walletManager: primaryWalletManager)
        urlController = URLController(walletManager: primaryWalletManager)
        if let url = launchURL {
            _ = urlController?.handleUrl(url)
            launchURL = nil
        }

        if primaryWalletManager.noWallet {
            addWalletCreationListener()
            Store.perform(action: ShowStartFlow())
        } else {
            DispatchQueue.walletQueue.async {
                self.walletManagers[UserDefaults.mostRecentSelectedCurrencyCode]?.peerManager?.connect()
            }
            startDataFetchers()
        }

        setupFirebase()
    }

    private func setupFirebase() {
        // cheat userId
        guard let userID = Store.state.wallets[Currencies.eth.code]?.receiveAddress else {
            return
        }
        Store.perform(action: ProfileChange.setProfileId(userID))

//        FirebaseManager.loginUser(userId: "mtg.92pk@gmail.com", password: "123456", completion: {
            // Subcribe Address change
            Store.subscribe(self, selector: {
                var result = false
                let oldState = $0
                let newState = $1

                $0.displayCurrencies.forEach { currency in
                    if oldState[currency]?.receiveAddress != newState[currency]?.receiveAddress {
                        result = true
                    }
                }
                return result
            }, callback: { _ in
                FirebaseManager.updateWalletAddress()
            })
//        })

//        // Subcribe User's info change
        Store.subscribeAsTrigger(self, name: .updateUserProfile, callback: {_ in
            FirebaseManager.updateUserInfo()
        })

        Store.subscribeAsTrigger(self, name: .uploadAvatar(nil, nil), callback: {
            guard let trigger = $0 else { return }
            if case .uploadAvatar(let imgPath, let data) = trigger {
                FirebaseManager.uploadAvatar(imgPath: imgPath, data: data)
            }
        })
    }

    private func reinitWalletManager(callback: @escaping () -> Void) {
        Store.perform(action: Reset())
        self.setup()

        DispatchQueue.walletQueue.async {
            Backend.disconnectWallet()
            self.kvStoreCoordinator = nil
            self.walletManagers.values.forEach({ $0.resetForWipe() })
            self.walletManagers.removeAll()
            self.initWallet {
                DispatchQueue.main.async {
                    self.didInitWalletManager()
                    callback()
                }
            }
        }
    }

    private func setupEthInitialState() {
        guard let ethWalletManager = walletManagers[Currencies.eth.code] as? EthWalletManager else { return }
        ethWalletManager.apiClient = Backend.apiClient
        Store.perform(action: WalletChange(Currencies.eth).setSyncingState(.connecting))
        Store.perform(action: WalletChange(Currencies.eth).setMaxDigits(Currencies.eth.commonUnit.decimals))
        Store.perform(action: WalletID.set(ethWalletManager.walletID))

        Store.state.currencies.filter({ $0 is ERC20Token }).forEach { token in
            Store.perform(action: WalletChange(token).setSyncingState(.connecting))
            Store.perform(action: WalletChange(token).setMaxDigits(token.commonUnit.decimals))
            guard let state = token.state else { return }
            Store.perform(action: WalletChange(token).set(state.mutate(receiveAddress: ethWalletManager.address)))
        }
    }

    private func shouldRequireLogin() -> Bool {
        let then = UserDefaults.standard.double(forKey: timeSinceLastExitKey)
        let timeout = UserDefaults.standard.double(forKey: shouldRequireLoginTimeoutKey)
        let now = Date().timeIntervalSince1970
        return now - then > timeout
    }

    private func setupDefaults() {
        if UserDefaults.standard.object(forKey: shouldRequireLoginTimeoutKey) == nil {
            UserDefaults.standard.set(60.0*3.0, forKey: shouldRequireLoginTimeoutKey) //Default 3 min timeout
        }
    }

    private func setupAppearance() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont.header]
    }

    private func setupRootViewController() {
        let home = HomeScreenViewController(primaryWalletManager:
                                                walletManagers[Currencies.btc.code] as? BTCWalletManager)
        let nc = RootNavigationController()
        nc.pushViewController(home, animated: false)
        home.didSelectCurrency = { currency in
            guard let walletManager = self.walletManagers[currency.code] else { return }
            let accountViewController = AccountViewController(currency: currency, walletManager: walletManager)
            nc.pushViewController(accountViewController, animated: true)
        }

        home.didTapSupport = {
            self.modalPresenter?.presentFaq()
        }

        home.didTapSettings = {
            self.modalPresenter?.presentSettings()
        }

        home.didTapAddWallet = {
            guard let kvStore = Backend.kvStore else { return }
            let vc = EditWalletsViewController(type: .manage, kvStore: kvStore)
            nc.pushViewController(vc, animated: false)
        }
        home.didShowTokenList = {
            guard let kvStore = Backend.kvStore else { return }
            let vc = ShowTokenListViewController(kvStore: kvStore)
            nc.pushViewController(vc, animated: false)
        }

        //State restoration
        if let currency = Store.state.currencies.first(where: { $0.code == UserDefaults.selectedCurrencyCode }),
            let walletManager = self.walletManagers[currency.code] {
            let accountViewController = AccountViewController(currency: currency, walletManager: walletManager)
            nc.pushViewController(accountViewController, animated: true)
        }

        window.rootViewController = nc
    }

    private func startDataFetchers() {
        Backend.apiClient.updateFeatureFlags()
        initKVStoreCoordinator()
        Backend.updateFees()
        Backend.updateExchangeRates()
        defaultsUpdater?.refresh()
        Backend.apiClient.events?.up()
//        if !Store.state.isPushNotificationsEnabled {
//            Backend.pigeonExchange?.startPolling()
//        }
    }

    private func retryAfterIsReachable() {
        guard let walletManager = primaryWalletManager,
            !walletManager.noWallet else { return }
        walletManagers.values.filter { $0 is BTCWalletManager }.map { $0.currency }.forEach {
            // reset sync state before re-connecting
            Store.perform(action: WalletChange($0).setSyncingState(.success))
        }
        DispatchQueue.walletQueue.async {
            self.walletManagers[UserDefaults.mostRecentSelectedCurrencyCode]?.peerManager?.connect()
        }
        
        Backend.updateExchangeRates()
        Backend.updateFees()
        Backend.kvStore?.syncAllKeys { print("KV finished syncing. err: \(String(describing: $0))") }
        Backend.apiClient.updateFeatureFlags()
    }

    /// Handles new wallet creation or recovery
    private func addWalletCreationListener() {
        Store.subscribeAsTrigger(self, name: .didCreateOrRecoverWallet, callback: { _ in
            self.walletManagers.removeAll() // remove the empty wallet managers
            DispatchQueue.walletQueue.async {
                self.initWallet(completion: self.didInitWalletManager)
            }
        })
    }

    private func updateAssetBundles() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let `self` = self else { return }
            Backend.apiClient.updateBundles { errors in
                for (bundle, err) in errors {
                    print("Bundle \(bundle) ran update. err: \(String(describing: err))")
                }
                DispatchQueue.main.async {
                    let _ = self.modalPresenter?.supportCenter // Initialize support center
                }
            }
        }
    }

    private func initKVStoreCoordinator() {
        guard let kvStore = Backend.kvStore else { return }
        guard kvStoreCoordinator == nil else { return }
        self.kvStoreCoordinator = KVStoreCoordinator(kvStore: kvStore)
        self.walletManagers.values.forEach({ $0.kvStore = kvStore })
        kvStore.syncAllKeys { [unowned self] error in
            print("KV finished syncing. err: \(String(describing: error))")
            self.kvStoreCoordinator?.setupStoredCurrencyList()
            self.kvStoreCoordinator?.retreiveStoredWalletInfo()
            self.kvStoreCoordinator?.listenForWalletChanges()
        }
    }

    private func offMainInitialization() {
        DispatchQueue.global(qos: .background).async {
            _ = Rate.symbolMap //Initialize currency symbol map
        }
    }

    private func handleLaunchOptions(_ options: [UIApplicationLaunchOptionsKey: Any]?) {
        if let url = options?[.url] as? URL {
            do {
                let file = try Data(contentsOf: url)
                if file.count > 0 {
                    Store.trigger(name: .openFile(file))
                }
            } catch let error {
                print("Could not open file at: \(url), error: \(error)")
            }
        }
    }

    func willResignActive() {
        applyBlurEffect()
        if !Store.state.isPushNotificationsEnabled, let pushToken = UserDefaults.pushToken {
            Backend.apiClient.deletePushNotificationToken(pushToken)
        }
    }

    func didBecomeActive() {
        removeBlurEffect()
    }

    private func applyBlurEffect() {
        guard !Store.state.isLoginRequired && !Store.state.isPromptingBiometrics else { return }
        blurView.alpha = 1.0
        blurView.frame = window.frame
        window.addSubview(blurView)
    }

    private func removeBlurEffect() {
        // keep content hidden if lock screen about to appear on top
        let duration = Store.state.isLoginRequired ? 0.4 : 0.1
        UIView.animate(withDuration: duration, animations: {
            self.blurView.alpha = 0.0
        }, completion: { _ in
            self.blurView.removeFromSuperview()
        })
    }

    private func addTokenCountChangeListener() {
        Store.subscribe(self, selector: {
            let oldTokens = Set($0.currencies.compactMap { ($0 as? ERC20Token)?.address })
            let newTokens = Set($1.currencies.compactMap { ($0 as? ERC20Token)?.address })
            return oldTokens != newTokens
        }, callback: { state in
            guard let ethWalletManager = self.walletManagers[Currencies.eth.code] as? EthWalletManager else { return }
            let tokens = state.currencies.compactMap { $0 as? ERC20Token }
            tokens.forEach { token in
                self.walletManagers[token.code] = ethWalletManager
                self.modalPresenter?.walletManagers[token.code] = ethWalletManager
                Store.perform(action: WalletChange(token).setMaxDigits(token.commonUnit.decimals))
                Store.perform(action: WalletChange(token).setSyncingState(.connecting))
//                Store.perform(action: WalletChange(token).setReceiveAddress(ethWalletManager.address))
                guard let state = token.state else { return }
                Store.perform(action: WalletChange(token).set(state.mutate(receiveAddress: ethWalletManager.address)))
            }
            ethWalletManager.tokens = tokens // triggers balance refresh
            Backend.updateExchangeRates()
        })
    }
}

// MARK: - Push notifications
extension ApplicationController {
    func listenForPushNotificationRequest() {
        Store.subscribeAsTrigger(self, name: .registerForPushNotificationToken, callback: { _ in
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            self.application?.registerUserNotificationSettings(settings)
        })
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if !notificationSettings.types.isEmpty {
            application.registerForRemoteNotifications()
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        guard let apiClient = walletManager?.apiClient else { return }
//        guard UserDefaults.pushToken != deviceToken else { return }
//        UserDefaults.pushToken = deviceToken
//        apiClient.savePushNotificationToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotification: \(error)")
    }
}
