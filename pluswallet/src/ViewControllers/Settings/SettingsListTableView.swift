//  SettingsListTableView.swift
//  PlusWallet
//
//  Created by Chien Kieu on 2018/07/11.
//  Copyright © 2018年 株式会社エンジ. All rights reserved.

import UIKit

class SettingsListTableView: UITableViewController {

    var didTapDisplay: (() -> Void)?
    var didTapSecurity: (() -> Void)?
//    var didTapSupport: (() -> Void)?
    var didTapProfile: (() -> Void)?
    var didTapAbout: (() -> Void)?
    private let menuHeight: CGFloat = 80.0

    // MARK: - Init

    init() {
        super.init(style: .plain)
    }

    override func viewDidLoad() {
        tableView.backgroundColor = UIColor.whiteBackground
 //       tableView.isScrollEnabled = false;
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.cellIdentifier)
        tableView.separatorStyle = .none
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func reload() {
        tableView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Data Source
    enum Menu: Int {
        case display
        case profile
        case security
//        case support
        case about

        var content: (String, UIImage) {
            switch self {
            case .display:
                return (S.MenuButton.settings, #imageLiteral(resourceName: "setting"))
            case .profile:
                return (S.MenuButton.profile, #imageLiteral(resourceName: "profile"))
            case .security:
                return (S.MenuButton.security, #imageLiteral(resourceName: "security"))
//            case .support:
//                return (S.MenuButton.support, #imageLiteral(resourceName: "support"))
            case .about:
                return (S.MenuButton.about, #imageLiteral(resourceName: "about"))
            }
        }

        static let allItems: [Menu] = [.display,
                                       .profile,
                                       .security,
//                                       .support,
                                       .about]
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Menu.allItems.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return menuHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.cellIdentifier, for: indexPath) as? MenuCell else {
            return MenuCell()
        }

        guard let item = Menu(rawValue: indexPath.row) else { return cell }
        let content = item.content
        cell.set(title: content.0, icon: content.1)

        let separator = UIView(color: .secondaryShadow)
        tableView.addSubview(separator)
        separator.constrain([
            separator.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
            separator.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0) ])

        return cell
    }

    // MARK: - Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = Menu(rawValue: indexPath.row) else { return }
        switch item {
       // case .
        case .display:
            didTapDisplay?()
        case .profile:
            didTapProfile?()
        case .security:
            didTapSecurity?()
//        case .support:
//            didTapSupport?()
        case .about:
            didTapAbout?()
        }
    }
}
