//
//  PortfolioCurrencyTableViewController.swift
//  pluswallet
//
//  Created by Zan on 2018/07/26.
//  Copyright © 2018年 PlusWallet LLC. All rights reserved.
//

import UIKit

class PortfolioCurrencyTableViewController: UITableViewController, Subscriber {

    //var didTapAddWallet: (() -> Void)?
    var updownPercent: [String: Double]?
    private let height: CGFloat = 110.0
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .whiteBackground
        tableView.register(PortofolioCurrencyTableCell.self, forCellReuseIdentifier: PortofolioCurrencyTableCell.cellIdentifier)
        tableView.separatorStyle = .none

        tableView.reloadData()
        tableView.setEditing(true, animated: true)

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

     //   print(updownPercent!)
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
        var viewModel = AssetListViewModel(currency: currency)
        let code = viewModel.currency.code
        if updownPercent![code] != nil {
            viewModel.updownPercent = updownPercent![code]!
        } else { viewModel.updownPercent = 0.0 }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
            PortofolioCurrencyTableCell.cellIdentifier, for: indexPath) as? PortofolioCurrencyTableCell else {
                return PortofolioCurrencyTableCell()
        }
        cell.set(viewModel: viewModel )

        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}
