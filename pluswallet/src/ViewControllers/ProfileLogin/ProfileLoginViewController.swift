//
//  ProfileLoginViewController.swift
//  pluswallet
//
//  Created by 株式会社エンジ on 2018/09/18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth
import SwiftyJSON
import JGProgressHUD
import FirebaseStorage
import FirebaseDatabase
import GoogleSignIn

class ProfileLoginViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    var suserId: String? = ""
    var name: String? = ""
    var username: String? = ""
    var email: String? = ""
    var profileImage: UIImage?
    var imageData: Data?
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    let txtEmail: UITextField = {
        let txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 15)
        txt.placeholder = "Email"
        txt.borderStyle = UITextBorderStyle.roundedRect
        txt.returnKeyType = UIReturnKeyType.done
        txt.clearButtonMode = UITextFieldViewMode.always
        txt.tag = 1
        return txt
    }()
    
    let lblErrorEmail: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 10)
        txt.textColor = UIColor.red
        txt.text = ""
        return txt
    }()
    
    let txtPass: UITextField = {
        let txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 15)
        txt.placeholder = "Password"
        txt.borderStyle = UITextBorderStyle.roundedRect
        txt.returnKeyType = UIReturnKeyType.done
        txt.clearButtonMode = UITextFieldViewMode.always
        txt.tag = 2
        return txt
    }()
    
    let lblErrorPass: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 10)
        txt.textColor = UIColor.red
        txt.text = ""
        return txt
    }()
    
    let btnLogin: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .blue
        btn.setTitle("Login", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = 7
        btn.addTarget(self, action: #selector(loginWithFirebase), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    private let btnSignup: UIButton = {
        let button = UIButton()
        let yourAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor: UIColor.blue,
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
        ]
        let attributeString = NSMutableAttributedString(string: "Create Account", attributes: yourAttributes)
        button.setAttributedTitle(attributeString, for: .normal)
        button.addTarget(self, action: #selector(signUpFireBase), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    private let btnForgetPass: UIButton = {
        let button = UIButton()
        let yourAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor: UIColor.blue,
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
        ]
        let attributeString = NSMutableAttributedString(string: "Forget Password", attributes: yourAttributes)
        button.setAttributedTitle(attributeString, for: .normal)
        button.addTarget(self, action: #selector(forgetPass), for: UIControlEvents.touchUpInside)
        return button
    }()
        
    let btnFacebook: UIButton = {
        let btn = UIButton()
        //        btn.backgroundColor = .FacebookColor
        //        btn.setTitle("Facebook", for: .normal)
        //        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setImage(#imageLiteral(resourceName: "fb-sign-in-button"), for: .normal)
        //btn.setImage( imageLiteral(resourceName: "fb-sign-in-button"), for: .normal)
        //        btn.contentMode = .scaleToFill
        btn.layer.cornerRadius = 7
        btn.addTarget(self, action: #selector(handleSingInWithFacebookButtonTapped), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    let btnGmail = GIDSignInButton()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteBackground
        
        navigationController?.navigationBar.applyNavigationGradient(colors: [UIColor.gradientStart , UIColor.gradientEnd])
        navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationItem.title = "Login"
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        txtEmail.delegate = self
        txtPass.delegate = self
        addSubviews()
        addConstrains()
        
        //btnSignup.target(forAction: #selector(signup), withSender: )
        //        btnSignup.addTarget(self, action: #selector(signup), for: UIControlEvents.touchUpInside)
        
        //        let stackView = UIStackView(arrangedSubviews: [btnFacebook, btnGmail])
        //        stackView.translatesAutoresizingMaskIntoConstraints = false
        //        stackView.distribution = .fillEqually
        //        stackView.spacing = 10
        
        //        view.addSubview(stackView)
        //        stackView.constrain([
        //            stackView.topAnchor.constraint(equalTo: btnSignup.bottomAnchor, constant: 20),
        //            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
        //            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        //            stackView.heightAnchor.constraint(equalToConstant: 30)
        //            ])
        //Tat ban phim cac 1
        //        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(undisplayKeyboard)))
    }
    
    
    
    //    @objc func undisplayKeyboard(){
    //
    //        txtUser.resignFirstResponder()
    //        txtPass.resignFirstResponder()
    //    }
    
    //Tat ban phim cach 2, phai khai bao UITextFieldDelegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    private func addSubviews(){
        view.addSubview(txtEmail)
        view.addSubview(lblErrorEmail)
        view.addSubview(txtPass)
        view.addSubview(lblErrorPass)
        view.addSubview(btnLogin)
        view.addSubview(btnSignup)
        view.addSubview(btnForgetPass)
        view.addSubview(btnFacebook)
        view.addSubview(btnGmail)
    }
    
    private func addConstrains() {
        txtEmail.constrain([
            txtEmail.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            txtEmail.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            txtEmail.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            txtEmail.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        lblErrorEmail.constrain([
            lblErrorEmail.topAnchor.constraint(equalTo: txtEmail.bottomAnchor, constant: 1),
            lblErrorEmail.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            lblErrorEmail.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblErrorEmail.heightAnchor.constraint(equalToConstant: 15)
            ])
        
        txtPass.constrain([
            txtPass.topAnchor.constraint(equalTo: txtEmail.bottomAnchor, constant: 20),
            txtPass.leadingAnchor.constraint(equalTo: txtEmail.leadingAnchor),
            txtPass.trailingAnchor.constraint(equalTo: txtEmail.trailingAnchor),
            txtPass.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        lblErrorPass.constrain([
            lblErrorPass.topAnchor.constraint(equalTo: txtPass.bottomAnchor, constant: 1),
            lblErrorPass.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            lblErrorPass.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblErrorPass.heightAnchor.constraint(equalToConstant: 15)
            ])
        
        btnLogin.constrain([
            btnLogin.topAnchor.constraint(equalTo: txtPass.bottomAnchor, constant: 30),
            btnLogin.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnLogin.heightAnchor.constraint(equalToConstant: 30),
            btnLogin.widthAnchor.constraint(equalToConstant: 100)
            ])
        
        btnSignup.constrain([
            btnSignup.topAnchor.constraint(equalTo: btnLogin.bottomAnchor, constant: 10),
            btnSignup.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            btnSignup.heightAnchor.constraint(equalToConstant: 30)
            //btnSignup.widthAnchor.constraint(equalToConstant: 200)
            ])
        btnForgetPass.constrain([
            btnForgetPass.topAnchor.constraint(equalTo: btnLogin.bottomAnchor, constant: 10),
            btnForgetPass.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            btnForgetPass.heightAnchor.constraint(equalToConstant: 30)
//            btnForgetPass.widthAnchor.constraint(equalToConstant: 200)
            ])
        
        btnFacebook.constrain([
            btnFacebook.topAnchor.constraint(equalTo: btnSignup.bottomAnchor, constant: 10),
            btnFacebook.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnFacebook.heightAnchor.constraint(equalToConstant: 30),
            btnFacebook.widthAnchor.constraint(equalToConstant: 300)
            ])
        
        btnGmail.constrain([
            btnGmail.topAnchor.constraint(equalTo: btnFacebook.bottomAnchor, constant: 10),
            btnGmail.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnGmail.heightAnchor.constraint(equalToConstant: 30),
            btnGmail.widthAnchor.constraint(equalToConstant: 300)
            ])
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            let txt = view.viewWithTag(2)
            txt?.becomeFirstResponder()
        } else if textField.tag == 2 {
            textField.resignFirstResponder()
        }
        return true
    }
    @objc func handleSingInWithFacebookButtonTapped() {
        hud.textLabel.text = "Logging in with Facebook..."
        hud.show(in: view, animated: true)
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ReadPermission.publicProfile, .email], viewController: self) { (result) in
            switch result {
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                print("success logged in into Facebook")
                self.signIntoFirebase()
            case .failed(let err) :
                print(err)
            case .cancelled :
                print("cancelled")
            }
        }
    }
    
    @objc func handleSingInWithGoogleButtonTapped() {
//        guard let authentication = user.authentication else { return }
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                       accessToken: authentication.accessToken)
//        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
//            if let error = error {
//                // ...
//                return
//            }
//            // User is signed in
//            // ...
//        }
        GIDSignIn.sharedInstance().signIn()
    }

    fileprivate func signIntoFirebase() {
        let authenticationToken = AccessToken.current?.authenticationToken
        let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken!)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, err) in
            if let err = err {
                print(err)
                return
            }
            if Auth.auth().currentUser != nil {
                print("da log in")
                
            }
            self.fetchFacebookUser()
            print("success")
        }
        print("Succesfully authenticated with Firebase.")
        
        //fetchFacebookUser()
    }
    
    func firebaseLoginGoogle(_ credential: AuthCredential) {
            if let user = Auth.auth().currentUser {
                // [START link_credential]
                user.linkAndRetrieveData(with: credential) { (authResult, error) in
                    // [START_EXCLUDE]
                    // [END_EXCLUDE]
                }
                // [END link_credential]
            } else {
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                    if let error = error {
                        // ...
                        return
                    }
                    // User is signed in
                    print("Succesfully authenticated with Firebase.")
                }
            }
    }
    
    func pushPageToProfile(){
        //        if Auth.auth().currentUser != nil {
        //            let profile = ProfileViewController()
        //            navigationController?.isNavigationBarHidden = false
        //            navigationController?.pushViewController(profile, animated: true)
        //        } else{
        //            let profileLogin = ProfileLoginViewController()
        //            navigationController?.isNavigationBarHidden = false
        //            navigationController?.pushViewController(profileLogin, animated: true)
        //        }
        
        let profilevc = ProfileViewController()
        self.hud.dismiss(animated: true)
//        self.present(profilevc, animated: true, completion: nil)
//        navigationController?.pushViewController(profilevc, animated: true)
//        UIApplication.shared.keyWindow?.rootViewController = profilevc
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    fileprivate func fetchFacebookUser() {
        
        //        guard  let uid = Auth.auth().currentUser?.uid else {return}
        let uid = Auth.auth().currentUser?.uid
        let graphRequestConnection = GraphRequestConnection()
        print("toi day ko")
        let graphRequest = GraphRequest(graphPath: "/me", parameters: ["fields": "id, email, name, picture.type(large)"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
        print("toi day ko1 ")
        graphRequestConnection.add(graphRequest, completion: { (httpResponse, result) in
            print(result)
            switch result {
            case .success(response: let response):
                print("toi day ko3")
                guard let responseDict = response.dictionaryValue else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
                let json = JSON(responseDict)
                self.name = json["name"].string
                self.email = json["email"].string
                guard let profilePictureUrl = json["picture"]["data"]["url"].string else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
                guard let url = URL(string: profilePictureUrl) else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
                Store.perform(action: ProfileChange.setProfileId(uid!))
                Store.perform(action: ProfileChange.setUsername(self.name!))
                Store.perform(action: ProfileChange.setProfileUrl(profilePictureUrl, isFromGallery: true))
                do{
                    let data = try Data(contentsOf: url)
                    Store.perform(action: ProfileChange.setProfileAvatar(data))
                }catch {
                }
                self.pushPageToProfile()
                Store.trigger(name: .updateUserProfile)
//                URLSession.shared.dataTask(with: url) { (data, response, err) in
//                    if err != nil {
//                        guard let err = err else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
//                        Service.dismissHud(self.hud, text: "Fetch error", detailText: err.localizedDescription, delay: 3)
//                        return
//                    }
//                    guard let data = data else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3); return }
//                    self.profileImage = UIImage(data: data)
//                    //                    self.saveUserIntoFirebaseDatabase()
//
//                    Store.perform(action: ProfileChange.setProfileAvatar(data))
//
//                    Store.trigger(name: .uploadAvatar(profilePictureUrl, data))
//                    /////////////
//                    Store.trigger(name: .updateUserProfile)
//                    }.resume()
                break
            case .failed(let err):
                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to get Facebook user with error: \(err)", delay: 3)
                break
            }
        })
        graphRequestConnection.start()
    }
    
    //    fileprivate func saveUserIntoFirebaseDatabase() {
    //        guard let uid = Auth.auth().currentUser?.uid,
    //            let name = self.name,
    //            let username = self.username,
    //            let email = self.email,
    //            let profileImage = profileImage,
    //            let profileImageUploadData = UIImageJPEGRepresentation(profileImage, 0.3) else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user.", delay: 3); return }
    //        let fileName = UUID().uuidString
    //        print("anh nam o day:")
    //        print(profileImage)
    //        Storage.storage().reference().child("profileImages").child(fileName).putData(profileImageUploadData, metadata: nil) { (metadata, err) in
    //            if let err = err {
    //                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user with error: \(err)", delay: 3);
    //                return
    //            }
    ////            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user.", delay: 3); return }
    //            let profileImageUrl = Storage.storage().reference().downloadURL(completion: { (url, error) in
    //                if error != nil {
    //                    print(error!)
    //                } else {
    //                    let profileImageUrl = url!.absoluteString
    //                    print(profileImageUrl)
    //                }
    //
    //            print("Successfully uploaded profile image into Firebase storage with URL:", profileImageUrl)
    //
    //            let dictionaryValues = ["name": name,
    //                                    "email": email,
    //                                    "username": username,
    //                                    "profileImageUrl": profileImageUrl]
    //            let values = [uid : dictionaryValues]
    //
    //            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
    //                if let err = err {
    //                    Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user info with error: \(err)", delay: 3)
    //                    return
    //                }
    //                print("Successfully saved user info into Firebase database")
    //                // after successfull save dismiss the welcome view controller
    //                self.hud.dismiss(animated: true)
    //                self.dismiss(animated: true, completion: nil)
    //            })
    //        }
    //    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func signup(){
        let signUpViewController = ProfileSignUpViewController()
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print(error)
            return
        }
        //let userId = user.userID                  // For client-side use only!
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        if user.profile.hasImage
        {
            let pic = user.profile.imageURL(withDimension: 100)
            Store.perform(action: ProfileChange.setProfileUrl((pic?.absoluteString)!, isFromGallery: true))
            do{
                let data = try Data(contentsOf: pic!)
                Store.perform(action: ProfileChange.setProfileAvatar(data))
            }catch {
            }
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                print(error)
                return
            }
            let userId = authResult?.user.uid
            Store.perform(action: ProfileChange.setUsername(fullName!))
            
            Store.perform(action: ProfileChange.setProfileId(userId!))
            
            self.pushPageToProfile()
            Store.trigger(name: .updateUserProfile)
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    @objc func signUpFireBase(){
        let profileSignUpVC = ProfileSignUpViewController()
        self.navigationController?.pushViewController(profileSignUpVC, animated: true)
    }
    
    @objc func loginWithFirebase(){
        let semail = txtEmail.text
        let spass = txtPass.text
        let checkvalue = checkValid()
        if(checkvalue){
            Auth.auth().signIn(withEmail: semail!, password: spass!) { (user, error) in
                if let user = user{
                    let userId = Auth.auth().currentUser?.uid
                    Store.perform(action: ProfileChange.setProfileId(userId!))
                    FirebaseManager.fetchUserInfo(userId: userId, completion: { (data) in
                        
                        let disgroup = DispatchGroup()
                        disgroup.enter()
                        
                        let taskOne = {
                            if let username : String = data["username"] as? String {
                                Store.perform(action: ProfileChange.setUsername(username))
                            }
                            disgroup.leave()
                        }
                        taskOne()
                        
                        disgroup.enter()
                        let taskTwo = {
                            if let imageUrl: String = data["userimage"] as? String {
                                let isIcon = imageUrl.range(of: "http") == nil
                                Store.perform(action: ProfileChange.setProfileUrl(imageUrl, isFromGallery : !isIcon ))
                                if isIcon {
                                    let dataImage : Data = UIImagePNGRepresentation(UIImage(named: imageUrl)!)!
                                    Store.perform(action: ProfileChange.setProfileAvatar(dataImage))
                                }else {
                                    do{
                                        let url = URL(fileURLWithPath: imageUrl)
                                        let dataImage = try Data(contentsOf: url)
                                        Store.perform(action: ProfileChange.setProfileAvatar(dataImage))
                                    }catch{ }
                                    }
                                
                                }
                            disgroup.leave()
                        }
                        taskTwo()
                        
                        disgroup.notify(queue: .main, execute: {
                            print("Da dang nhap dc ")
                            self.navigationController?.pushViewController(ProfileViewController(), animated: true)
                        })
                       
                    })
                    
                }
            }
            
        } else{
            print("Khong dang nhap duoc")
        }
    }
    
    func checkValid()->Bool{
        var checkvalue = true
        let predicate = NSPredicate(format: "SELF MATCHES %@",
                                    "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        if ((predicate.evaluate(with: txtEmail.text) == false) || (txtEmail.text?.isEmpty)!){
            lblErrorEmail.text = "Email is invalid"
            lblErrorEmail.isHidden = false
            checkvalue = false
        } else{
            lblErrorEmail.isHidden = true
        }
        if((txtPass.text?.isEmpty)!){
            lblErrorPass.text = "Password is invalid"
            lblErrorPass.isHidden = false
            checkvalue = false
        }
        else{
            lblErrorPass.isHidden = true
        }
        
        return checkvalue
    }
    
    @objc func forgetPass(){
        navigationController?.pushViewController(ForgetPassViewController(), animated: true)
    }
    
}
