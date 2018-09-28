//
//  allCurrencyViewController.swift
//  breadwallet
//
//  Created by 株式会社エンジ on 2018/07/10.
//  Copyright © 2018年 breadwallet LLC. All rights reserved.
//

import UIKit

class AllCurrencyViewController: UIViewController {

    var didTapAddWallet: (() -> Void)?
    var didTapSupport: (() -> Void)?
    var didTapSettings: (() -> Void)?
    private let assetListTable = AssetListTableView()
    private let subHeaderView = GradientView()
    private let backbtn: UIButton = {
       let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "Back"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
        return btn
    }()
    private let chooseCurrencybtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("並べ替え", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.addTarget(self, action: #selector(chooseCurrencys), for: UIControlEvents.touchUpInside)
        return btn
    }()
    @objc func back() {
        dismiss(animated: true, completion: nil)
    }
//    @objc func chooseCurrencys() {
//
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(subHeaderView)
        subHeaderView.addSubview(backbtn)
        subHeaderView.addSubview(chooseCurrencybtn)
        chooseCurrencybtn.tap = didTapAddWallet
        assetListTable.didTapAddWallet = didTapAddWallet
        assetListTable.didTapSettings = didTapSettings
        assetListTable.didTapSupport = didTapSupport
//        subHeaderView.clipsToBounds = false
//        navigationController?.navigationBar.isHidden = false
//        //navigationController?.isNavigationBarHidden = false
//        navigationController?.navigationItem.hidesBackButton = false
//        navigationController?.navigationBar.barTintColor = .blue
        //        navigationItem.titleView = UIView()
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.shadowImage = #imageLiteral(resourceName: "TransparentPixel")
//        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "TransparentPixel"), for: .default)
        let height: CGFloat = 80.0
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
        backbtn.constrain([
            backbtn.topAnchor.constraint(equalTo: subHeaderView.topAnchor, constant: 10),
            backbtn.leadingAnchor.constraint(equalTo: subHeaderView.leadingAnchor, constant: 10),
            backbtn.heightAnchor.constraint(equalToConstant: 20),
            backbtn.widthAnchor.constraint(equalToConstant: 20)
        ])
        chooseCurrencybtn.constrain([
            chooseCurrencybtn.topAnchor.constraint(equalTo: subHeaderView.topAnchor, constant: 10),
            chooseCurrencybtn.trailingAnchor.constraint(equalTo: subHeaderView.trailingAnchor, constant: -10),
            chooseCurrencybtn.heightAnchor.constraint(equalToConstant: 20)
            //chooseCurrencybtn.widthAnchor.constraint(equalToConstant: 40),
        ])

        addChildViewController(assetListTable, layout: {
            assetListTable.view.constrain([
                assetListTable.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                assetListTable.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                assetListTable.view.topAnchor.constraint(equalTo: subHeaderView.bottomAnchor),
                assetListTable.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        })
//        if #available(iOS 11.0, *) {
//
//        } else {
//            addChildViewController(assetListTable, layout: {
//                assetListTable.view.constrain([
//                    assetListTable.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                    assetListTable.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                    assetListTable.view.topAnchor.constraint(equalTo:topLayoutGuide.bottomAnchor ),
//                    assetListTable.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//                    ])
//            })
//        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        //navigationController?.navigationBar.barTintColor = .blue
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

}
