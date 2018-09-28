//
//  ShowTokenListViewController.swift
//  pluswallet
//
//  Created by Zan on 2018/07/12.
//  Copyright © 2018年 PlusWallet LLC. All rights reserved.
//

import UIKit

class ShowTokenListViewController: UIViewController {

    private let cellIdentifier = "CellIdentifier"
    private let kvStore: BRReplicatedKVStore
    private var metaData: CurrencyListMetaData
    private let localCurrencies: [CurrencyDef] = [Currencies.btc, Currencies.bch, Currencies.eth]
    private let tableView = UITableView()
    private let subTitle: UILabel = {
       let lbl = UILabel()
        lbl.text = S.ShowTokenListViewController.changePosition
        lbl.textColor = UIColor.gradientEnd
        lbl.font = UIFont.customBold(size: 16.0)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()
    //(Currency, isHidden)
    private var model = [(CurrencyDef, Bool)]() {
        didSet { tableView.reloadData() }
    }
    private var allCurrencies: [CurrencyDef] = []
    private var allModels = [(CurrencyDef, Bool)]()

    init( kvStore: BRReplicatedKVStore) {
        self.kvStore = kvStore
        self.metaData = CurrencyListMetaData(kvStore: kvStore)!
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "sdsdsd", style: .plain, target: nil, action: nil)
        view.backgroundColor = .white
        view.addSubview(tableView)

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        headerView.backgroundColor = .white
        headerView.addSubview(subTitle)
        subTitle.constrain([
            subTitle.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            subTitle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            subTitle.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 2/3 )
            ])

        self.tableView.tableHeaderView = headerView

        self.tableView.tableHeaderView?.layoutIfNeeded()

        tableView.keyboardDismissMode = .interactive
        tableView.constrain([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        if #available(iOS 11.0, *) {
            tableView.constrain([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)])
        } else {
            tableView.constrain([
                tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)])
            automaticallyAdjustsScrollViewInsets = false
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ShowTokenCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: C.padding[2], bottom: 0, right: C.padding[2])

        tableView.setEditing(true, animated: true)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.applyNavigationGradient(colors: [UIColor.gradientStart, UIColor.gradientEnd])
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = S.ShowTokenListViewController.allCurrency
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.customBold(size: 17.0)
        ]
        StoredTokenData.fetchTokens(callback: { [weak self] in
            guard let `self` = self else { return }
            self.metaData = CurrencyListMetaData(kvStore: self.kvStore)!
            self.setManageModel(storedCurrencies: $0.map { ERC20Token(tokenData: $0) })
        })

    }

    private func setManageModel(storedCurrencies: [CurrencyDef]) {
        allCurrencies = storedCurrencies + localCurrencies
        let enabledCurrencies = findCurrencies(fromList: metaData.enabledCurrencies, fromCurrencies: allCurrencies)

        model = enabledCurrencies.map { ($0, false) }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        mergeChanges()
        title = ""
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    private func mergeChanges() {
        let oldWallets = Store.state.wallets
        var newWallets = [String: WalletState]()
        var displayOrder = 0

        let hiddenCurrencies = findCurrencies(fromList: metaData.hiddenCurrencies, fromCurrencies: allCurrencies)
        model += hiddenCurrencies.map { ($0, true) }
        model.forEach { currency in

            //Hidden local wallets get a displayOrder of -1
            let localCurrencyCodes = localCurrencies.map { $0.code.lowercased() }
            if localCurrencyCodes.contains(currency.0.code.lowercased()) {
                var walletState = oldWallets[currency.0.code]!
                if currency.1 {
                    walletState = walletState.mutate(displayOrder: -1)
                } else {
                    walletState = walletState.mutate(displayOrder: displayOrder)
                    displayOrder += 1
                }
                newWallets[currency.0.code] = walletState

                //Hidden tokens, except for brd, get removed from the wallet state
            } else {
                if let walletState = oldWallets[currency.0.code] {
                    if currency.1 {
                        newWallets[currency.0.code] = nil
                    } else {
                        newWallets[currency.0.code] = walletState.mutate(displayOrder: displayOrder)
                        displayOrder += 1
                    }
                } else {
                    if currency.1 == false {
                        let newWalletState = WalletState.initial(currency.0, displayOrder: displayOrder)
                        displayOrder += 1
                        newWallets[currency.0.code] = newWalletState
                    }
                }
            }
        }

        //Save new metadata
        metaData.enabledCurrencies = model.compactMap {
            guard $0.1 == false else { return nil}
            if let token = $0.0 as? ERC20Token {
                return C.erc20Prefix + token.address
            } else {
                return $0.0.code
            }
        }
        metaData.hiddenCurrencies = model.compactMap {
            guard $0.1 == true else { return nil}
            if let token = $0.0 as? ERC20Token {
                return C.erc20Prefix + token.address
            } else {
                return $0.0.code
            }
        }
        save()

        //Apply new state
        Store.perform(action: ManageWallets.setWallets(newWallets))
    }

    private func save() {
        do {
            _ = try kvStore.set(metaData)
        } catch let error {
            print("error setting wallet info: \(error)")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShowTokenListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ShowTokenCell else { return UITableViewCell() }
        cell.set(currency: model[indexPath.row].0, isHidden: model[indexPath.row].1)
        return cell
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = model[sourceIndexPath.row]
        model.remove(at: sourceIndexPath.row)
        model.insert(movedObject, at: destinationIndexPath.row)
    }
}

extension ShowTokenListViewController {
    private func findCurrencies(fromList: [String], fromCurrencies: [CurrencyDef]) -> [CurrencyDef] {
        return fromList.compactMap { codeOrAddress in
            let codeOrAddress = codeOrAddress.replacingOccurrences(of: C.erc20Prefix, with: "")
            var currency: CurrencyDef?
            fromCurrencies.forEach {
                if currencyMatchesCode(currency: $0, identifier: codeOrAddress) {
                    currency = $0
                }
            }
            assert(currency != nil || E.isTestnet)
            return currency
        }
    }

    private func currencyMatchesCode(currency: CurrencyDef, identifier: String) -> Bool {
        if currency.code.lowercased() == identifier.lowercased() {
            return true
        }
        if let token = currency as? ERC20Token {
            if token.address.lowercased() == identifier.lowercased() {
                return true
            }
        }
        return false
    }
}
