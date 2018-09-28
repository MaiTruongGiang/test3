//
//  TermAndConditionView.swift
//  breadwallet
//
//  Created by 株式会社エンジ on 2018/06/29.
//  Copyright © 2018年 breadwallet LLC. All rights reserved.
//

import UIKit

class TermAndConditionView: UIViewController {
   // let circleRadius: CGFloat = 12.0
    let term1lbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "保管する通貨へのアクセス種がこの端末にのみ存在し、外部のサーバー等に一切保管されていないことを理解しました。"
        lbl.numberOfLines = 3
        lbl.lineBreakMode = NSLineBreakMode.byCharWrapping
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        return lbl
    }()
    let term2lbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "アプリを消除した場合、端末が壊れた場合、機種変更した場合、保有した通貨を復元するためには、バックアップキーが絶対に必要であることを理解しました"
        lbl.numberOfLines = 4
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        return lbl
    }()
    let term3lbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "をよく読み、内容に同意します。"
        lbl.numberOfLines = 1
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        return lbl
    }()
     let contentbtn: UIButton = {
        let button = UIButton()
        let yourAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),
            NSAttributedStringKey.foregroundColor: UIColor.blue,
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: "利用規約",
                                                        attributes: yourAttributes)
        button.setAttributedTitle(attributeString, for: .normal)
        return button
    }()
     let circle1 = DrawableCircle()
//     let circle2 = DrawableCircle()
//     let circle3 = DrawableCircle()
    override func viewDidLoad() {
         super.viewDidLoad()
        view.addSubview(circle1)
//        view.addSubview(circle2)
//        view.addSubview(circle3)
        view.addSubview(term1lbl)
        view.addSubview(term2lbl)
        view.addSubview(contentbtn)
        view.addSubview(term3lbl)
    circle1.constrain([
        circle1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        circle1.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        circle1.heightAnchor.constraint(equalToConstant: 12*2.0),
        circle1.widthAnchor.constraint(equalToConstant: 12*2.0)
        ])
//    circle1.constrain([
//            circle1.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
//            circle1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
//            circle1.heightAnchor.constraint(equalToConstant: circleRadius*2.0),
//            circle1.widthAnchor.constraint(equalToConstant: circleRadius*2.0) ])
//    circle2.constrain([
//            circle2.topAnchor.constraint(equalTo: term1lbl.bottomAnchor, constant: 30),
//            circle2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
//            circle2.heightAnchor.constraint(equalToConstant: circleRadius*2.0),
//            circle2.widthAnchor.constraint(equalToConstant: circleRadius*2.0) ])
//    circle3.constrain([
//            circle3.topAnchor.constraint(equalTo: term2lbl.bottomAnchor, constant: 35),
//            circle3.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
//            circle3.heightAnchor.constraint(equalToConstant: circleRadius*2.0),
//            circle3.widthAnchor.constraint(equalToConstant: circleRadius*2.0) ])
    term1lbl.constrain([
        term1lbl.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
        term1lbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
        term1lbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    term2lbl.constrain([
        term2lbl.topAnchor.constraint(equalTo: term1lbl.bottomAnchor, constant: 30),
        term2lbl.leadingAnchor.constraint(equalTo: term1lbl.leadingAnchor),
        term2lbl.trailingAnchor.constraint(equalTo: term1lbl.trailingAnchor)
        ])
    contentbtn.constrain([
            contentbtn.topAnchor.constraint(equalTo: term2lbl.bottomAnchor, constant: 30),
            contentbtn.leadingAnchor.constraint(equalTo: term1lbl.leadingAnchor)
            //contentbtn.trailingAnchor.constraint(equalTo: term1lbl.trailingAnchor),
            ])
    term3lbl.constrain([
        term3lbl.topAnchor.constraint(equalTo: term2lbl.bottomAnchor, constant: 35),
        term3lbl.leadingAnchor.constraint(equalTo: contentbtn.trailingAnchor),
        term3lbl.trailingAnchor.constraint(equalTo: term1lbl.trailingAnchor)
        ])
        contentbtn.tap = extendContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       circle1.show()
//        circle2.show()
//        circle3.show()
    }
    func extendContent() {
        print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
//        let alert = UIAlertController(title: "利用規約", message: "Terms and Conditions are a set of rules and", preferredStyle: UIAlertControllerStyle.alert)
//        let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
//        alert.addAction(ok)
//        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        let alert = UIAlertController(title: "利用規約", message: "サッカーワールドカップロシア大会の１次リーグ、グループＨの日本は第３戦でポーランドと対戦し、０対１で敗れましたが、日本はもう１試合のセネガル対コロンビアでコロンビアが勝ったことからグループＨで２位となり、２大会ぶりの決勝トーナメント進出が決まりました。/nここまで１勝１引き分けの勝ち点「４」で、グループ１位だった日本は28日、ボルゴグラードで行われた第３戦で、すでに１次リーグ敗退が決まっているポーランドと対戦しました。/nこの試合に勝つか引き分けで、ほかの試合の結果にかかわらず決勝トーナメント進出が決まる日本は、第２戦から先発６人を入れ替えて臨みました。", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
