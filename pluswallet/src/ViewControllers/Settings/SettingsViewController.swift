//  SettingsViewController.swift
//  PlusWallet
//
//  Created by Chien Kieu on 2018/07/11.
//  Copyright © 2018年 株式会社エンジ. All rights reserved.

import UIKit
import RxCocoa
import RxSwift

class SettingHeader: UIView, GradientDrawable {
    override func draw(_ rect: CGRect) {
        drawGradient(rect)
    }
}

private let constHeaderHeight: CGFloat = 230.0
private let fadeStart: CGFloat = 180.0
private let fadeEnd: CGFloat = 140.0

class SettingsViewController: UIViewController {

    var didTapDisplay: (() -> Void)?
//    var didTapSupport: (() -> Void)?
    var didTapProfile: (() -> Void)?
    var didTapSecurity: (() -> Void)?
    var didTapAbout : (() -> Void)?
    // constant
    private let closeButtonSize: CGFloat = 44.0
    private let avatarSize: CGFloat = 100.0
    fileprivate var headerHeight: NSLayoutConstraint?
    fileprivate var didViewAppear = false

    // Sub views
    private let scrollView = UIScrollView()
    private let headerView = SettingHeader()
    private let settingListTable = SettingsListTableView()
    private let avatarView = AvatarHeaderView()

    private let close = UIButton.close

    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {

        settingListTable.didTapDisplay = didTapDisplay
        settingListTable.didTapProfile = didTapProfile
//        settingListTable.didTapSupport = didTapSupport
        settingListTable.didTapSecurity = didTapSecurity
        settingListTable.didTapAbout = didTapAbout
        close.tap = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        didViewAppear = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didViewAppear = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        didViewAppear = false
        navigationController?.navigationBar.isHidden = false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setup() {
        setupSubscribe()
        setupStyles()
        addSubviews()
        setupConstraints()
    }

    private func setupSubscribe() {
        UserDefaults.standard.rx
            .observe(String.self, UDefaultKey.profileName)
            .subscribe(onNext: { (value) in
                self.avatarView.setText(string: value ?? "", font: UIFont.boldSystemFont(ofSize: 20))
            })
            .disposed(by: disposeBag)

        UserDefaults.standard.rx
            .observe(Data.self, UDefaultKey.profileAvatar)
            .subscribe(onNext: { (value) in
                if let imageData = value {
                    self.avatarView.setAvatar(UIImage(data: imageData as Data))
                }
            })
            .disposed(by: disposeBag)
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(headerView)
        headerView.addSubview(close)
        headerView.addSubview(avatarView)

        scrollView.addSubview(settingListTable.view)
    }

    private func setupStyles() {
        view.backgroundColor = .white
        scrollView.alwaysBounceVertical = true
        scrollView.panGestureRecognizer.delaysTouchesBegan = false
        scrollView.delegate = self

        // Close button
        close.tintColor = .white

        // Avatar        
        avatarView.setAvatar(UIImage(data: UserDefaults.profileAvatar as Data ))
    }

    private func setupConstraints() {
        scrollView.constrain([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor) ])

        headerHeight = headerView.heightAnchor.constraint(equalToConstant: constHeaderHeight)
        headerView.constrain([
            headerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            headerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            headerHeight])

        avatarView.constrain([
            avatarView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            avatarView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarView.heightAnchor.constraint(equalToConstant: avatarSize) ])

        close.constrain([
            close.topAnchor.constraint(equalTo: headerView.topAnchor, constant: E.isIPhoneX ? 40.0 : 30.0),
            close.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0),
            close.widthAnchor.constraint(equalToConstant: closeButtonSize),
            close.heightAnchor.constraint(equalToConstant: closeButtonSize) ])

        settingListTable.view.constrain([
            settingListTable.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingListTable.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingListTable.view.topAnchor.constraint(equalTo: headerView.bottomAnchor ),
            settingListTable.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard didViewAppear else { return } //We don't want to be doing an stretchy header stuff during interactive pop gestures
        let yOffset = scrollView.contentOffset.y + 20.0
        let newHeight = constHeaderHeight - yOffset
        headerHeight?.constant = newHeight

        if newHeight < fadeStart {
            let range = fadeStart - fadeEnd
            let alpha = (newHeight - fadeEnd)/range
            avatarView.alpha = max(alpha, 0.0)
        } else {
            avatarView.alpha = 1.0
        }

    }
}
