//
//  allCurrencyViewController.swift
//  PlusWallet
//
//  Created by 株式会社エンジ on 2018/07/10.
//  Copyright © 2018年 PlusWallet LLC. All rights reserved.
//

import UIKit

class AllCurrencyViewController: UIViewController {

    var didTapAddWallet: (() -> Void)?
    var didShowTokenList: (() -> Void)?
    var didSelectCurrency: ((CurrencyDef) -> Void)?
    private let assetListTable = TokenListTableViewController()
    private let subHeaderView = GradientView()
    private let backbtn: UIButton = {
       let btn = UIButton()
        //btn.setImage(#imageLiteral(resourceName: "LeftArrow"), for: UIControlState.normal)
        btn.setImage(UIImage(named: "backWhite"), for: .normal)
        btn.imageView?.contentMode = .scaleToFill
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
        return btn
    }()
    private let chooseCurrencybtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(S.AllCurrencyViewController.sorting, for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.addTarget(self, action: #selector(chooseCurrencys), for: UIControlEvents.touchUpInside)
        return btn
    }()
    private let subHeaderView2: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10

        return view
    }()
    private let titlelbl: UILabel = {
       let lbl = UILabel()
        lbl.text = S.AllCurrencyViewController.allCurrency
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.font = UIFont.customBold(size: 18.0)
        return lbl
    }()
    private let titlelbl2: UILabel = {
        let lbl = UILabel()
        lbl.text = S.AllCurrencyViewController.chooseDisplayCurrency
        lbl.textColor = UIColor.gradientEnd
        lbl.textAlignment = .center
        lbl.font = UIFont.customBold(size: 14.0)
        return lbl
    }()
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteBackground
        view.addSubview(subHeaderView)
        subHeaderView.addSubview(backbtn)
        subHeaderView.addSubview(chooseCurrencybtn)
        subHeaderView.addSubview(titlelbl)
        subHeaderView.addSubview(subHeaderView2)
        subHeaderView2.addSubview(titlelbl2)

        subHeaderView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTokenList) ))

        chooseCurrencybtn.tap = didShowTokenList
        assetListTable.didSelectCurrency = didSelectCurrency
        let height: CGFloat = 130.0
        if #available(iOS 11.0, *) {
            subHeaderView.constrain([
                subHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                subHeaderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                subHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                subHeaderView.heightAnchor.constraint(equalToConstant: height + 30) ])
            backbtn.constrain([
                backbtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 3),
                backbtn.leadingAnchor.constraint(equalTo: subHeaderView.leadingAnchor, constant: 10),
                backbtn.heightAnchor.constraint(equalToConstant: 40),
                backbtn.widthAnchor.constraint(equalToConstant: 40)
                ])
        } else {
            subHeaderView.constrain([
                subHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                subHeaderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                subHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                subHeaderView.heightAnchor.constraint(equalToConstant: height) ])
            backbtn.constrain([
                backbtn.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 19),
                backbtn.leadingAnchor.constraint(equalTo: subHeaderView.leadingAnchor, constant: 10),
                backbtn.heightAnchor.constraint(equalToConstant: 40),
                backbtn.widthAnchor.constraint(equalToConstant: 40)
                ])
        }

        chooseCurrencybtn.constrain([
            chooseCurrencybtn.topAnchor.constraint(equalTo: backbtn.topAnchor, constant: 7),
            chooseCurrencybtn.trailingAnchor.constraint(equalTo: subHeaderView.trailingAnchor, constant: -20),
            chooseCurrencybtn.heightAnchor.constraint(equalToConstant: 20)
            //chooseCurrencybtn.widthAnchor.constraint(equalToConstant: 40),
            ])
        titlelbl.constrain([
            titlelbl.centerXAnchor.constraint(equalTo: subHeaderView.centerXAnchor),
            titlelbl.topAnchor.constraint(equalTo: backbtn.topAnchor, constant: 7)
            ])
        subHeaderView2.constrain([
            subHeaderView2.bottomAnchor.constraint(equalTo: subHeaderView.bottomAnchor, constant: -25),
            subHeaderView2.centerXAnchor.constraint(equalTo: subHeaderView.centerXAnchor),
            subHeaderView2.heightAnchor.constraint(equalToConstant: 40),
            subHeaderView2.widthAnchor.constraint(equalTo: titlelbl2.widthAnchor, constant: 60)
            ])
        titlelbl2.constrain([
            titlelbl2.centerXAnchor.constraint(equalTo: subHeaderView2.centerXAnchor),
            titlelbl2.centerYAnchor.constraint(equalTo: subHeaderView2.centerYAnchor)
            ])

        addChildViewController(assetListTable, layout: {
            assetListTable.view.constrain([
                assetListTable.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                assetListTable.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                assetListTable.view.topAnchor.constraint(equalTo: subHeaderView.bottomAnchor, constant: 20 ),
                assetListTable.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        })

    }
    @objc func showTokenList() {
//        print("ggggggggggggggggggggggggggggggggg")
        self.didTapAddWallet!()

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
