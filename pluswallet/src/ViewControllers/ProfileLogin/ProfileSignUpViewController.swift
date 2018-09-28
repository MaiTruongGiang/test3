//
//  ProfileSignUpViewController.swift
//  pluswallet
//
//  Created by 株式会社エンジ on 2018/09/19.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit
import Firebase

class ProfileSignUpViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    var scrollView = UIScrollView()
    
    var activeTextField = UITextField()
    
    let lblErrorEmail: UILabel = {
       let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 10)
        txt.textColor = UIColor.red
        txt.text = ""
        return txt
    }()
    
    let lblErrorName: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 10)
        txt.textColor = UIColor.red
        txt.text = ""
        return txt
    }()
    
    let lblErrorPass: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 10)
        txt.textColor = UIColor.red
        txt.text = ""
        return txt
    }()
    
    let lblErrorPassConfirm: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 10)
        txt.textColor = UIColor.red
        txt.text = ""
        return txt
    }()
    
    let lblEmail: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 15)
        txt.text = "Email"
        return txt
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
    let lblDisplayName: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 15)
        txt.text = "Display Name"
        return txt
    }()
    let txtDisplayName: UITextField = {
        let txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 15)
        txt.placeholder = "Display Name"
        txt.borderStyle = UITextBorderStyle.roundedRect
        txt.returnKeyType = UIReturnKeyType.done
        txt.clearButtonMode = UITextFieldViewMode.always
        txt.tag = 2
        return txt
    }()
    let lblPass: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 15)
        txt.text = "Password"
        return txt
    }()
    let txtPass: UITextField = {
        let txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 15)
        txt.placeholder = "Password"
        txt.borderStyle = UITextBorderStyle.roundedRect
        txt.returnKeyType = UIReturnKeyType.done
        txt.clearButtonMode = UITextFieldViewMode.always
        txt.tag = 3
        txt.isSecureTextEntry = true
        return txt
    }()
    
    let lblConfirmPass: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 15)
        txt.text = "Confirm Password"
        return txt
    }()
    
    let txtConfirmPass: UITextField = {
        let txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 15)
        txt.placeholder = "Confirm Password"
        txt.borderStyle = UITextBorderStyle.roundedRect
        txt.returnKeyType = UIReturnKeyType.done
        txt.clearButtonMode = UITextFieldViewMode.always
        txt.tag = 4
        txt.isSecureTextEntry = true
        return txt
    }()
    
    let btnSignUp: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .blue
        btn.setTitle("Sign Up", for: .normal)
        btn.setTitleColor(UIColor.green, for: .normal)
        btn.layer.cornerRadius = 7
        btn.addTarget(self, action: #selector(signUpFirebase), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    let lblAlreadyAccount: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 10)
        txt.text = "Already have an account? Login here"
        return txt
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteBackground
        
        navigationController?.navigationBar.applyNavigationGradient(colors: [UIColor.gradientStart , UIColor.gradientEnd])
        navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationItem.title = "Sign Up"
        txtEmail.delegate = self
        txtDisplayName.delegate = self
        txtPass.delegate = self
        txtConfirmPass.delegate = self
        scrollView.delegate = self
        addSubviews()
        addConstrains()
        
        //Them
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }
    
    private func addSubviews(){
        view.addSubview(scrollView)
        
        scrollView.addSubview(lblErrorEmail)
        scrollView.addSubview(lblErrorName)
        scrollView.addSubview(lblErrorPass)
        scrollView.addSubview(lblErrorPassConfirm)
        scrollView.addSubview(lblEmail)
        scrollView.addSubview(txtEmail)
        scrollView.addSubview(lblDisplayName)
        scrollView.addSubview(txtDisplayName)
        scrollView.addSubview(lblPass)
        scrollView.addSubview(txtPass)
        scrollView.addSubview(lblConfirmPass)
        scrollView.addSubview(txtConfirmPass)
        scrollView.addSubview(btnSignUp)
        scrollView.addSubview(lblAlreadyAccount)
    }
    
    private func addConstrains() {
        scrollView.constrain(toSuperviewEdges: nil)
        
        lblEmail.constrain([
            lblEmail.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            lblEmail.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            lblEmail.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblEmail.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        txtEmail.constrain([
            txtEmail.topAnchor.constraint(equalTo: lblEmail.bottomAnchor, constant: 10),
            txtEmail.leadingAnchor.constraint(equalTo: lblEmail.leadingAnchor),
            txtEmail.trailingAnchor.constraint(equalTo: lblEmail.trailingAnchor),
            txtEmail.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        lblErrorEmail.constrain([
            lblErrorEmail.topAnchor.constraint(equalTo: txtEmail.bottomAnchor, constant: 1),
            lblErrorEmail.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            lblErrorEmail.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblErrorEmail.heightAnchor.constraint(equalToConstant: 15)
            ])
        
        lblDisplayName.constrain([
            lblDisplayName.topAnchor.constraint(equalTo: txtEmail.bottomAnchor, constant: 10),
            lblDisplayName.leadingAnchor.constraint(equalTo: txtEmail.leadingAnchor),
            lblDisplayName.trailingAnchor.constraint(equalTo: txtEmail.trailingAnchor),
            lblDisplayName.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        txtDisplayName.constrain([
            txtDisplayName.topAnchor.constraint(equalTo: lblDisplayName.bottomAnchor, constant: 10),
            txtDisplayName.leadingAnchor.constraint(equalTo: lblDisplayName.leadingAnchor),
            txtDisplayName.trailingAnchor.constraint(equalTo: lblDisplayName.trailingAnchor),
            txtDisplayName.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        lblErrorName.constrain([
            lblErrorName.topAnchor.constraint(equalTo: txtDisplayName.bottomAnchor, constant: 1),
            lblErrorName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            lblErrorName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblErrorName.heightAnchor.constraint(equalToConstant: 15)
            ])
        
        lblPass.constrain([
            lblPass.topAnchor.constraint(equalTo: txtDisplayName.bottomAnchor, constant: 10),
            lblPass.leadingAnchor.constraint(equalTo: txtDisplayName.leadingAnchor),
            lblPass.trailingAnchor.constraint(equalTo: txtDisplayName.trailingAnchor),
            lblPass.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        txtPass.constrain([
            txtPass.topAnchor.constraint(equalTo: lblPass.bottomAnchor, constant: 10),
            txtPass.leadingAnchor.constraint(equalTo: lblPass.leadingAnchor),
            txtPass.trailingAnchor.constraint(equalTo: lblPass.trailingAnchor),
            txtPass.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        lblErrorPass.constrain([
            lblErrorPass.topAnchor.constraint(equalTo: txtPass.bottomAnchor, constant: 1),
            lblErrorPass.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            lblErrorPass.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblErrorPass.heightAnchor.constraint(equalToConstant: 15)
            ])
        
        lblConfirmPass.constrain([
            lblConfirmPass.topAnchor.constraint(equalTo: txtPass.bottomAnchor, constant: 10),
            lblConfirmPass.leadingAnchor.constraint(equalTo: txtPass.leadingAnchor),
            lblConfirmPass.trailingAnchor.constraint(equalTo: txtPass.trailingAnchor),
            lblConfirmPass.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        txtConfirmPass.constrain([
            txtConfirmPass.topAnchor.constraint(equalTo: lblConfirmPass.bottomAnchor, constant: 10),
            txtConfirmPass.leadingAnchor.constraint(equalTo: lblConfirmPass.leadingAnchor),
            txtConfirmPass.trailingAnchor.constraint(equalTo: lblConfirmPass.trailingAnchor),
            txtConfirmPass.heightAnchor.constraint(equalToConstant: 25)
            ])
        
        lblErrorPassConfirm.constrain([
            lblErrorPassConfirm.topAnchor.constraint(equalTo: txtConfirmPass.bottomAnchor, constant: 1),
            lblErrorPassConfirm.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            lblErrorPassConfirm.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblErrorPassConfirm.heightAnchor.constraint(equalToConstant: 15)
            ])
        
        btnSignUp.constrain([
            btnSignUp.topAnchor.constraint(equalTo: txtConfirmPass.bottomAnchor, constant: 30),
            btnSignUp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnSignUp.heightAnchor.constraint(equalToConstant: 30),
            btnSignUp.widthAnchor.constraint(equalToConstant: 100)
            ])
        
        lblAlreadyAccount.constrain([
            lblAlreadyAccount.topAnchor.constraint(equalTo: btnSignUp.bottomAnchor, constant: 10),
            lblAlreadyAccount.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lblAlreadyAccount.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblAlreadyAccount.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.scrollView.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1{
            let txt = view.viewWithTag(2)
            txt?.becomeFirstResponder()
        } else if textField.tag == 2{
            let txt = view.viewWithTag(3)
            txt?.becomeFirstResponder()
        } else if textField.tag == 3{
            let txt = view.viewWithTag(4)
            txt?.becomeFirstResponder()
        }
        else if textField.tag == 4 {
            textField.resignFirstResponder()
        }
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //Them
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        addObservers()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        removeObservers()
//    }
    
    @objc func didTapView(gesture: UITapGestureRecognizer){
        //This should hide keyboard for the view
        view.endEditing(true)
    }
    @objc func signUpFirebase(){
        let semail : String = txtEmail.text!
        let sname : String = txtDisplayName.text!
        let spass : String = txtPass.text!
        let sconfirmpass : String = txtConfirmPass.text!
//        let checkvalue = checkValid(email: semail, pass: spass, confirmpass: sconfirmpass)
        let checkvalue = checkValid()
        
        if(checkvalue){
            Auth.auth().createUser(withEmail: semail, password: spass) { (authResult, error) in
                // ...
//
//                guard let user = authResult?.user else { return }
//                print(user)
                guard let userId = authResult?.user.uid else { return }
                
                Store.perform(action: ProfileChange.setProfileId(userId))
                Store.perform(action: ProfileChange.setUsername(sname))
//                Store.trigger(name: .updateUserProfile)
                self.pushPageToProfile()
            }
        } else{
            print("Khong dang nhap duoc")
        }
    }
    
//    func checkValid(email : String, pass : String, confirmpass : String)-> Bool{
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
        if(txtDisplayName.text?.isEmpty)!{
            lblErrorName.text = "Display name is invalid"
            lblErrorName.isHidden = false
            checkvalue = false
        }
        else{
            lblErrorName.isHidden = true
        }
        if(((txtPass.text!.elementsEqual(txtConfirmPass.text!)) == false)){
            lblErrorPassConfirm.text = "Password is invalid"
            lblErrorPassConfirm.isHidden = false
            checkvalue = false
        }
        else{
            lblErrorPassConfirm.isHidden = true
        }
        if((txtPass.text?.isEmpty)! || (txtConfirmPass.text?.count)! < 6){
            lblErrorPass.text = "Password is invalid"
            lblErrorPass.isHidden = false
            checkvalue = false
        }
        else{
            lblErrorPass.isHidden = true
        }
        if((txtConfirmPass.text?.isEmpty)! || (txtConfirmPass.text?.count)! < 6){
            lblErrorPassConfirm.text = "Password is invalid"
            lblErrorPassConfirm.isHidden = false
            checkvalue = false
        }
        else{
            lblErrorPassConfirm.isHidden = true
        }
        
        return checkvalue
    }
    
    func pushPageToProfile(){
        let profileVC = ProfileViewController()
        
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
}


