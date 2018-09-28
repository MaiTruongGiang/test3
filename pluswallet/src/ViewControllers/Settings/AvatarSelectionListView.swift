//
//  AvatarSelectionListView.swift
//  pluswallet
//
//  Created by Kieu Quoc Chien on 2018/07/23.
//  Copyright © 2018 株式会社エンジ LLC. All rights reserved.
//

import UIKit

class AvatarSelectionView: UICollectionViewController {
    private let cellIdentifier = "CellIdentifier"

    private let cellSize: CGFloat = 50.0

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.white
        //clearsSelectionOnViewWillAppear = false
    }

    //データの個数を返すメソッド
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    //セル選択時の呼び出しメソッド
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        //セグエを実行する
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //セルを取得し、イメージビューに画像を設定して返す。
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "plus_wallet_icoin" + String(indexPath.row))
//        imageView.image = UIImage(contentsOfFile: (self.items[indexPath.item]["productImage"] as! CKAsset).fileURL.path)

        //セル選択時の背景色を設定する。
        let selectedView = UIView()
        selectedView.backgroundColor = .red
        cell.selectedBackgroundView = selectedView

        cell.constrain([
            cell.widthAnchor.constraint(equalToConstant: cellSize),
            cell.heightAnchor.constraint(equalToConstant: cellSize) ])

        return cell
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
