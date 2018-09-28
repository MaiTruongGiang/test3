//
//  MenuSettingViewController.swift
//  pluswallet
//
//  Created by Zan on 2018/08/03.
//  Copyright © 2018年 pluswallet LLC. All rights reserved.
//

import UIKit

class MenuSettingViewController: UITableViewController {
        init(items: [MenuSettingItem], title: String) {
            self.items = items
            super.init(style: .plain)
            self.title = title
        }
        private let items: [MenuSettingItem]

        override func viewDidLoad() {
            tableView.register(MenuSettingCell.self, forCellReuseIdentifier: MenuSettingCell.cellIdentifier)
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            //tableView.backgroundColor = UIColor.whiteBackground // phan nay sua lai la White
            tableView.backgroundColor = UIColor.white
            tableView.rowHeight = 80.0

            navigationController?.setGradientBlueStyle()
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            tableView.reloadData()
        }
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1

        }
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuSettingCell.cellIdentifier, for: indexPath) as? MenuSettingCell else { return UITableViewCell() }
            cell.set(item: items[indexPath.row])
            return cell
        }
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            items[indexPath.row].callback()
            tableView.deselectRow(at: indexPath, animated: true)
        }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
