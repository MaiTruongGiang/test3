//
//  HomeScreenCollectionViewController.swift
//  breadwallet
//
//  Created by zan on 2018/06/13.
//  Copyright © 2018年 株式会社エンジ LLC. All rights reserved.
//

import UIKit

class HomeScreenCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, Subscriber {

    var didSelectCurrency: ((CurrencyDef) -> Void)?
    var didTapAddWallet: (() -> Void)?
    var bienTest: String?

    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages  = 3
        pc.currentPageIndicatorTintColor = .red
        pc.pageIndicatorTintColor = .gray
       return pc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = .white
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView!.register(HomeScreenCollectionViewCell.self, forCellWithReuseIdentifier: HomeScreenCollectionViewCell.cellIdentifier)
        collectionView?.reloadData()
        Store.subscribe(self, selector: {
            var result = false
            let oldState = $0
            let newState = $1
            $0.displayCurrencies.forEach { currency in
                if oldState[currency]?.balance != newState[currency]?.balance
                    || oldState[currency]?.currentRate?.rate != newState[currency]?.currentRate?.rate
                    || oldState[currency]?.maxDigits != newState[currency]?.maxDigits {
                    result = true
                }
            }
            return result
        }, callback: { _ in
            self.collectionView?.reloadData()
        })

        Store.subscribe(self, selector: {
            $0.displayCurrencies.map { $0.code } != $1.displayCurrencies.map { $0.code }
        }, callback: { _ in
            self.collectionView?.reloadData()
            self.pageControl.numberOfPages = Store.state.displayCurrencies.count
        })
        layoutPapeControl()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.visibleCells.forEach {
            if let cell = $0 as? HomeScreenCollectionViewCell {
                cell.refreshAnimations()
            }
        }

    }

    func layoutPapeControl() {
        view.addSubview(pageControl)
        pageControl.constrain([
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 5),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
            ])

    }

    func reload() {
        collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return Store.state.displayCurrencies.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currency = Store.state.displayCurrencies[indexPath.item]
        let viewModel = AssetListViewModel(currency: currency)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
            HomeScreenCollectionViewCell.cellIdentifier, for: indexPath) as? HomeScreenCollectionViewCell else {
            return HomeScreenCollectionViewCell()
        }
        
        cell.set(viewModel: viewModel)

        // Configure the cell

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 10
        let heigh = view.frame.height - 20
        return CGSize(width: width, height: heigh)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath.item)
//        print(Store.state.displayCurrencies[indexPath.item].code)

        isAddWalletRow(row: indexPath.item) ? didTapAddWallet?() : didSelectCurrency?(Store.state.displayCurrencies[indexPath.item])
    }

    private func isAddWalletRow(row: Int) -> Bool {
        return row == Store.state.displayCurrencies.count
    }

    ///////スクロールの位置とpageControlのページを合わせる
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageControl.currentPage = Int(x / (view.frame.width - 10))
        print(Int(x / (view.frame.width - 10)))
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in

            self.collectionViewLayout.invalidateLayout()
            if self.pageControl.currentPage == 0 {
                self.collectionView?.contentOffset = .zero
            } else {
                let indexPath = IndexPath(item: self.pageControl.currentPage, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        })
    }

}
