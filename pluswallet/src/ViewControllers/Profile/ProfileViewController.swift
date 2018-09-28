//
//  ProfileViewController.swift
//  pluswallet
//
//  Created by Kieu Quoc Chien on 2018/07/20.
//  Copyright © 2018 株式会社エンジ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth
class ProfileViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate, UITextFieldDelegate{

//    var didTapChangeAvatar: (() -> Void)?
    let picker = UIImagePickerController()
    var imageData: Data?
    var imageFromGallery: Bool = Store.state.userState.imageFromGallery
    var nameIcon: String = ""
    private let avatarSize: CGFloat = 100.0
    private let textFieldSize: CGFloat = 50.0

    private let updateBtnWidth: CGFloat = 250.0
    private let updateBtnHeight: CGFloat = 50.0

    // Sub views
    private let scrollView = UIScrollView()
    //let avatarView = AvatarHeaderView()
    let avatarView = UIView()
    let avatar = UIImageView()
    private let changeBtn = UIButton.icon(image: #imageLiteral(resourceName: "icon_change_48px"), accessibilityLabel: "")
    private let updateBtn = UIButton.rounded(title: S.Profile.update, color: UIColor.blue)
    private let logoutBtn = UIButton.rounded(title: S.Profile.logout, color: UIColor.blue)

    private let nameLabel = UILabel()
    let nameTextField = UITextField()

    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
        changeBtn.addTarget(self, action: #selector(self.changeAvatarOnClick), for: .touchUpInside)
        updateBtn.addTarget(self, action: #selector(self.updateProfileOnClick(_:)), for: .touchUpInside)
        logoutBtn.addTarget(self, action: #selector(self.logout), for: .touchUpInside)
    }

    override func viewDidLoad() {
        setup()
        avatar.isUserInteractionEnabled = true// tuong tac voi ng dung dc bat
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatarOnClick)))
        nameTextField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        if !imageFromGallery {
            avatar.contentMode = .center
        } else {
            avatar.contentMode = .scaleAspectFill
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    private func setup() {
        setupSubscribe()
        setupStyles()
        addSubviews()
        setupConstraints()
    }

    private func setupSubscribe() {
        nameTextField.rx.text
            .subscribe(onNext: {value in
                self.setActiveBtn(value != Store.state.userState.userName)
            }).disposed(by: disposeBag)
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(avatar)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(updateBtn)
        scrollView.addSubview(logoutBtn)
        avatar.addSubview(changeBtn)

    }

    private func setActiveBtn(_ active: Bool = false) {
        updateBtn.backgroundColor = active ? .primaryButton : .gray
        updateBtn.isEnabled = active
        updateBtn.tintColor = .primaryText
    }

    private func setupStyles() {
        title = S.Profile.title

        avatar.image = UIImage(data: Store.state.userState.avatar)

        avatar.layer.cornerRadius = avatarSize / 2
        avatar.layer.masksToBounds = true
        avatar.clipsToBounds = true

        scrollView.backgroundColor = .whiteBackground
        scrollView.alwaysBounceVertical = true
        scrollView.panGestureRecognizer.delaysTouchesBegan = false

        changeBtn.backgroundColor = .darkGrayTransparent

        nameLabel.attributedText = NSAttributedString(string: S.Profile.username, attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.grayText,
                NSAttributedStringKey.font: UIFont.customBold(size: 16.0)
            ])

        nameTextField.attributedText = NSAttributedString(string: Store.state.userState.userName, attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.black,
                NSAttributedStringKey.font: UIFont.customBody(size: 16.0)
            ])
        nameTextField.placeholder = S.Profile.unamePlaceholder
        nameTextField.backgroundColor = .grayBackground
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: nameTextField.frame.height))
        nameTextField.leftViewMode = .always
        logoutBtn.tintColor = .white
    }

    private func setupConstraints() {
        scrollView.constrain([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor) ])
        //chien
//        avatarView.constrain([
//            avatarView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            avatarView.widthAnchor.constraint(equalToConstant: avatarSize),
//            avatarView.heightAnchor.constraint(equalToConstant: avatarSize),
//            avatarView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: C.padding[3]) ])

        //////zan
        avatar.constrain([
            avatar.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            avatar.widthAnchor.constraint(equalToConstant: avatarSize),
            avatar.heightAnchor.constraint(equalToConstant: avatarSize),
            avatar.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: C.padding[3]) ])

        //////
        changeBtn.constrain([
            changeBtn.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            changeBtn.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            changeBtn.widthAnchor.constraint(equalTo: avatar.widthAnchor),
            changeBtn.heightAnchor.constraint(equalTo: avatar.heightAnchor) ])

        nameLabel.constrain([
            nameLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: C.padding[2]),
            nameLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: C.padding[3]) ])

        nameTextField.constrain([
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: C.padding[1]),
            nameTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: C.padding[2]),
            nameTextField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: C.padding[2]),
            nameTextField.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: textFieldSize) ])

        updateBtn.constrain([
            updateBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateBtn.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: C.padding[2]),
            updateBtn.widthAnchor.constraint(equalToConstant: updateBtnWidth),
            updateBtn.heightAnchor.constraint(equalToConstant: updateBtnHeight) ])
        logoutBtn.constrain([
            logoutBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutBtn.topAnchor.constraint(equalTo: updateBtn.bottomAnchor, constant: C.padding[2]),
            logoutBtn.widthAnchor.constraint(equalToConstant: updateBtnWidth),
            logoutBtn.heightAnchor.constraint(equalToConstant: updateBtnHeight) ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc func logout(){
        let  data = UIImagePNGRepresentation(#imageLiteral(resourceName: "plus_wallet_icoin1"))
        Store.perform(action: ProfileChange.setUsername("Guest"))
        Store.perform(action: ProfileChange.setProfileAvatar(data!))
        Store.perform(action: ProfileChange.setProfileUrl("plus_wallet_icoin1", isFromGallery : false))
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        dismiss(animated: true, completion: nil)
        
    }
}
