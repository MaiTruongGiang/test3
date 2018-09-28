//
//  TokenListTableViewController.swift
//  pluswallet
//
//  Created by zan on 2018/07/11.
//  Copyright © 2018年 pluswallet LLC. All rights reserved.
//

import UIKit

class TokenListTableViewController: UITableViewController, Subscriber {

    //var didTapAddWallet: (() -> Void)?
    var didSelectCurrency: ((CurrencyDef) -> Void)?
    private let height: CGFloat = 120.0
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .whiteBackground
        tableView.register(TokenListTableViewCell.self, forCellReuseIdentifier: TokenListTableViewCell.cellIdentifier)
        tableView.separatorStyle = .none

        tableView.reloadData()
//        tableView.setEditing(true, animated: true)

        Store.subscribe(self, selector: {
            var result = false
            let oldState = $0
            let newState = $1
            $0.displayCurrencies.forEach { currency in
                if oldState[currency]?.balance != newState[currency]?.balance
                    || oldState[currency]?.currentRate?.rate != newState[currency]?.currentRate?.rate
                    || oldState[currency]?.maxDigits != newState[currency]?.maxDigits {
                    result = true
                }
            }
            return result
        }, callback: { _ in
            self.tableView.reloadData()
        })

        Store.subscribe(self, selector: {
            $0.displayCurrencies.map { $0.code } != $1.displayCurrencies.map { $0.code }
        }, callback: { _ in
            self.tableView.reloadData()
        })

    }
    init() {
        super.init(style: .plain)
    }

    func reload() {
        tableView.reloadData()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Store.state.displayCurrencies.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currency = Store.state.displayCurrencies[indexPath.row]
        let viewModel = AssetListViewModel(currency: currency)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TokenListTableViewCell.cellIdentifier, for: indexPath) as? TokenListTableViewCell else {
            return TokenListTableViewCell()
        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: TokenListTableViewCell.cellIdentifier, for: indexPath) as! TokenListTableViewCell
        cell.set(viewModel: viewModel )

        return cell
    }

//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .none
//    }
//
//    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectCurrency!(Store.state.displayCurrencies[indexPath.row])
    }

}
