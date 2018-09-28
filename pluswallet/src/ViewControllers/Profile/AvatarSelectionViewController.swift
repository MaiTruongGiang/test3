//
//  AvatarSelectionViewController.swift
//  pluswallet
//
//  Created by Kieu Quoc Chien on 2018/07/23.
//  Copyright © 2018 株式会社エンジ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AvatarSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var didChangeAvatar: ((UIImage, Bool, String) -> Void)?
    var selectedAvatarName: String?
    private let updateBtnWidth: CGFloat = 250.0
    private let updateBtnHeight: CGFloat = 50.0
    private let itemSize: CGFloat = 40.0
    private var selectedIndexPath: IndexPath?

    // Sub views
    private var avatarCollection: UICollectionView?
    private let updateBtn = UIButton.rounded(title: S.Profile.update, color: UIColor.blue)

    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
        updateBtn.addTarget(self, action: #selector(self.updateAvatarOnClick(_:)), for: .touchUpInside)
    }

    @objc func updateAvatarOnClick(_ sender: AnyObject) {
        guard let selected = selectedIndexPath else {
            return
        }

        Store.perform(action: ProfileChange.setProfileUrl("plus_wallet_icoin\(selected.row + 1)", isFromGallery: false))

        let nameIcon = "plus_wallet_icoin\(selected.row + 1).png"
        didChangeAvatar?(UIImage(named: nameIcon)!, false, nameIcon)
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    private func setup() {
        setupStyles()
        addSubviews()
        setupConstraints()
    }

    private func addSubviews() {
        view.addSubview(avatarCollection!)
        view.addSubview(updateBtn)
    }

    private func setupStyles() {
        title = S.Profile.iconSelection
        view.backgroundColor = .white
        updateBtn.backgroundColor = .primaryButton
        updateBtn.isEnabled = true
        updateBtn.tintColor = .primaryText

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: C.padding[7], left: C.padding[2], bottom: C.padding[2], right: C.padding[2])
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20

        avatarCollection = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        avatarCollection?.dataSource = self
        avatarCollection?.delegate = self
        avatarCollection?.register(AvatarCollectionViewCell.self, forCellWithReuseIdentifier: AvatarCollectionViewCell.cellIdentifier)
        avatarCollection?.backgroundColor = UIColor.white
    }

    private func setupConstraints() {
        avatarCollection?.constrain([
            avatarCollection?.topAnchor.constraint(equalTo: view.topAnchor),
            avatarCollection?.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            avatarCollection?.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            avatarCollection?.bottomAnchor.constraint(equalTo: updateBtn.topAnchor, constant : -C.padding[1]) ])
        updateBtn.constrain([
            updateBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: E.isIPhoneX ? -C.padding[5] : -C.padding[2]),
            updateBtn.widthAnchor.constraint(equalToConstant: updateBtnWidth),
            updateBtn.heightAnchor.constraint(equalToConstant: updateBtnHeight) ])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 48
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier:
                                AvatarCollectionViewCell.cellIdentifier, for: indexPath as IndexPath) as? AvatarCollectionViewCell else {
            return AvatarCollectionViewCell()
        }
       // let imageName = "plus_wallet_icoin" + String(indexPath.row + 1)
        let imageName = "plus_wallet_icoin\(indexPath.row + 1)"
        cell.imageView.image = UIImage(named: imageName)
        if imageName == selectedAvatarName {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            cell.imageTicked.isHidden = false
            selectedIndexPath = indexPath
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AvatarCollectionViewCell else {
            return
        }

        cell.imageTicked.isHidden = false
        selectedIndexPath = indexPath
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AvatarCollectionViewCell else {
            return
        }
        cell.imageTicked.isHidden = true
        selectedIndexPath = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
