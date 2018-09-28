//
//  ForgetPassViewController.swift
//  pluswallet
//
//  Created by 株式会社エンジ on 2018/09/28.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgetPassViewController: UIViewController {
    
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
    
    let btnSend: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .blue
        btn.setTitle("Send", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = 7
        btn.addTarget(self, action: #selector(sendResetPassEmail), for: UIControlEvents.touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteBackground
        
        navigationController?.navigationBar.applyNavigationGradient(colors: [UIColor.gradientStart , UIColor.gradientEnd])
        navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationItem.title = "Forget Password"
        
        addSubviews()
        addConstrains()
        // Do any additional setup after loading the view.
    }
    
    private func addSubviews(){
        view.addSubview(txtEmail)
        view.addSubview(lblErrorEmail)
        view.addSubview(btnSend)
    }
    
    private func addConstrains(){
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
        
        btnSend.constrain([
            btnSend.topAnchor.constraint(equalTo: lblErrorEmail.bottomAnchor, constant: 30),
            btnSend.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnSend.heightAnchor.constraint(equalToConstant: 30),
            btnSend.widthAnchor.constraint(equalToConstant: 100)
            ])
    }
    
    @objc func sendResetPassEmail(){
        guard let semail = txtEmail.text else {return}
        Auth.auth().useAppLanguage()
        Auth.auth().sendPasswordReset(withEmail: semail) { (error) in
            print("Da gui mail")
        }
        navigationController?.popViewController(animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
