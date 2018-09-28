//
//  PortofolioViewController.swift
//  pluswallet
//
//  Created by Zan on 2018/07/25.
//  Copyright © 2018年 PlusWallet LLC. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON

class PortofolioViewController: UIViewController {

    lazy var pieChart: PieChartView = {
        let p = PieChartView()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.noDataText = "No data to display"
        p.delegate = self
        p.legend.enabled = false
        p.rotationEnabled = false // off rotation
        p.drawEntryLabelsEnabled = false // off lable
        return p
    }()
    let headerView = GradientView()
    var name: [String] = []
    var currencyValue: [Decimal] = []
    var updownPercent: [String: Double] = [:]
    var fiatTotal: Decimal = 0.0
    var colorPieChart: [UIColor] = []
    let titlelbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Portofolio"
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    private let balancelbl: UILabel = {
       let lbl = UILabel()
        lbl.text = S.PortofolioViewController.totalBalance
        lbl.textAlignment = .left
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .gray
        return lbl
    }()
    private let currencyCountTitlelbl: UILabel = {
        let lbl = UILabel()
        lbl.text = S.PortofolioViewController.numberOfCurrencyOwned
        lbl.textAlignment = .left
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .gray
        return lbl
    }()

    private let currencyCountlbl = UILabel(font: UIFont.systemFont(ofSize: 25))
    private let currencyListlbl: UILabel = {
        let lbl = UILabel()
        lbl.text = S.PortofolioViewController.ownedCurrencyList
        lbl.textAlignment = .left
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .gray
        return lbl
    }()

    private let updownIcon = UIImageView(image: UIImage(named: "portofolio_up"))
    private let updownlbl = UILabel(font: .systemFont(ofSize: 15), color: .green)
    private let total = UILabel(font: .systemFont(ofSize: 25), color: .black)
    private let underView = UIView(color: .lightGray)
    var surveyData = [String: Double]()
    let portofolioTableView = PortfolioCurrencyTableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteBackground
        setNavigation()
        let activity: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activity.center = self.view.center
        activity.color = UIColor.black
        view.addSubview(activity)
        activity.startAnimating()
        Alamofire.request("https://api.coinmarketcap.com/v2/ticker/?limit=10").responseJSON { (response) in
            guard let data = response.result.value else { return }
            activity.stopAnimating()
            let json = JSON(data)["data"]
            let id = ["1", "1027", "1831"] // id cua BTC, ETH, BCH
            for i in id {
                let value = json[i]["quotes"]["USD"]["percent_change_1h"].double!
                let key = json[i]["symbol"].string!
                self.updownPercent.updateValue(value, forKey: key)

            }
            self.portofolioTableView.updownPercent = self.updownPercent

            self.currencyCountlbl.text = String(Store.state.displayCurrencies.count)
            self.updateTotalAssets()

            self.addSubViews()
            self.setLayout()

            self.setPieChart()
            self.getTotalPercent()
        }
    }
    override func viewWillAppear(_ animated: Bool) {

    }
    func addSubViews() {
        view.addSubview(headerView)
        headerView.addSubview(titlelbl)
        view.addSubview(pieChart)
        view.addSubview(total)
        view.addSubview(balancelbl)
        view.addSubview(currencyCountTitlelbl)
        view.addSubview(currencyCountlbl)
        view.addSubview(currencyListlbl)
        view.addSubview(updownlbl)
        view.addSubview(updownIcon)
        view.addSubview(underView)

    }
    func setLayout() {
        headerView.constrain([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: E.isIPhoneX ? 100 : 72)
            ])
        titlelbl.constrain([
            titlelbl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -C.padding[2]),
            titlelbl.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
            ])

        balancelbl.constrain([
            balancelbl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: C.padding[3]),
            balancelbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            balancelbl.trailingAnchor.constraint(equalTo: pieChart.leadingAnchor, constant: C.padding[2])

            ])
        updownlbl.constrain([
            updownlbl.topAnchor.constraint(equalTo: balancelbl.topAnchor),
            updownlbl.trailingAnchor.constraint(equalTo: pieChart.leadingAnchor, constant: -C.padding[2] )
            ])
        updownIcon.constrain([
            updownIcon.topAnchor.constraint(equalTo: balancelbl.topAnchor),
            updownIcon.trailingAnchor.constraint(equalTo: updownlbl.leadingAnchor, constant: -C.padding[1]),
            updownIcon.heightAnchor.constraint(equalTo: updownlbl.heightAnchor),
            updownIcon.widthAnchor.constraint(equalTo: updownIcon.heightAnchor)
            ])

        total.constrain([
            total.topAnchor.constraint(equalTo: balancelbl.bottomAnchor, constant: 1.5 * C.padding[1]),
            total.leadingAnchor.constraint(equalTo: balancelbl.leadingAnchor),
            total.trailingAnchor.constraint(equalTo: balancelbl.trailingAnchor)
            ])
        currencyCountTitlelbl.constrain([
            currencyCountTitlelbl.topAnchor.constraint(equalTo: total.bottomAnchor, constant: C.padding[1]),
            currencyCountTitlelbl.leadingAnchor.constraint(equalTo: balancelbl.leadingAnchor),
            currencyCountTitlelbl.trailingAnchor.constraint(equalTo: balancelbl.trailingAnchor)
            ])
        currencyCountlbl.constrain([
            currencyCountlbl.topAnchor.constraint(equalTo: currencyCountTitlelbl.bottomAnchor, constant: C.padding[1]),
            currencyCountlbl.leadingAnchor.constraint(equalTo: balancelbl.leadingAnchor),
            currencyCountlbl.trailingAnchor.constraint(equalTo: balancelbl.trailingAnchor)
            ])
        pieChart.constrain([
            pieChart.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: C.padding[3]),
            pieChart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[1]),
            pieChart.heightAnchor.constraint(equalToConstant: 160),
            pieChart.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/10)
            ])
        currencyListlbl.constrain([
            currencyListlbl.topAnchor.constraint(equalTo: pieChart.bottomAnchor, constant: C.padding[0]),
            currencyListlbl.leadingAnchor.constraint(equalTo: balancelbl.leadingAnchor),
            currencyListlbl.trailingAnchor.constraint(equalTo: balancelbl.trailingAnchor)
            ])
        underView.constrain([
            underView.bottomAnchor.constraint(equalTo: currencyListlbl.bottomAnchor, constant: C.padding[2]),
            underView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            underView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            underView.heightAnchor.constraint(equalToConstant: 1)
            ])
        addChildViewController(portofolioTableView, layout: {
        portofolioTableView.view.constrain([
            portofolioTableView.view.topAnchor.constraint(equalTo: underView.bottomAnchor),
            portofolioTableView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            portofolioTableView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            portofolioTableView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: E.isIPhoneX ? -20 : 0)
            ])
        }
        )

    }
    func setPieChart() {
        var pieArray: [ChartDataEntry] = []

        for i in 0..<name.count {
            let percent = currencyValue[i] / fiatTotal
            let data: ChartDataEntry = ChartDataEntry(x: Double(i), y: Double(truncating: percent as NSNumber))
            pieArray.append(data)
        }
        let pieDataSet: PieChartDataSet = PieChartDataSet(values: pieArray, label: "Percent")
        pieDataSet.colors = colorPieChart
        pieDataSet.sliceSpace = 2
        pieDataSet.selectionShift = 5
        pieDataSet.drawValuesEnabled = false

        let pieChartData: PieChartData = PieChartData(dataSet: pieDataSet)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        pieChartData.accessibilityLabel = ""
//        let d = Description()
//        d.text = ""

       // pieChart.drawEntryLabelsEnabled = false
        //pieChart.usePercentValuesEnabled = false
        //pieChart.
        pieChart.chartDescription?.text = ""
        pieChart.holeRadiusPercent = 0.6
        pieChart.transparentCircleColor = UIColor.clear

        guard var percent: Double = Double(truncating: currencyValue[0] / fiatTotal as NSNumber) else { return }
        if percent.isNaN {
            percent = 0
        }
        let value = formatter.string(for: percent)

        let code = name[0]

        pieChart.centerAttributedText = NSAttributedString(string: code + "\n" + value!, attributes: [NSAttributedStringKey.foregroundColor: colorPieChart[0],
            NSAttributedStringKey.font: UIFont.customBold(size: 17.0)]
           )
        pieChart.data = pieChartData
    }
    func setNavigation() {
        navigationController?.setClearNavbar()
        navigationItem.hidesBackButton = false
        navigationController?.navigationBar.tintColor = .white
//        let close = UIButton.close
//        close.tintColor = .white

//        close.frame = CGRect(x: 0, y: -10, width: 50, height: 50)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: close)
//        close.tap = {
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    private func updateTotalAssets() {
        fiatTotal = Store.state.displayCurrencies.map {
            print($0)
            guard let balance = Store.state[$0]?.balance,
                let rate = Store.state[$0]?.currentRate else { return 0.0 }
            let amount = Amount(amount: balance,
                                currency: $0,
                                rate: rate)
            let code = String($0.code)
            let color: UIColor = $0.colors.1
            let value = amount.fiatValue
            name.append(code)
            currencyValue.append(value)
            colorPieChart.append(color)
            return amount.fiatValue
            }.reduce(0.0, +)

        let format = NumberFormatter()
        format.isLenient = true
        format.numberStyle = .currency
        format.generatesDecimalNumbers = true
        format.negativeFormat = format.positiveFormat.replacingCharacters(in: format.positiveFormat.range(of: "#")!, with: "-#")
        format.currencySymbol = Store.state[Currencies.btc]?.currentRate?.currencySymbol ?? ""
        self.total.text = format.string(from: fiatTotal as NSDecimalNumber)
    }
    func getTotalPercent() {
        var value = 0.0
        for i in 0..<currencyValue.count {
            let b = updownPercent[name[i]] ?? 0.0
            if (fiatTotal != 0) {
                value += Double(truncating: currencyValue[i] / fiatTotal as NSNumber) * b
            } else {
                value = 0.0
            }
        }
        if value < 0 {
            updownIcon.image = UIImage(named: "portofolio_down")
            updownlbl.textColor = .pink
            value = fabs(value)
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2

        updownlbl.text = formatter.string(for: value)!  + "%"

    }
}
extension PortofolioViewController: ChartViewDelegate {

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        let value = formatter.string(from: NSNumber(value: highlight.y))
        let code = name[Int(entry.x)]

        pieChart.centerAttributedText = NSAttributedString(string: code + "\n" + value!, attributes: [NSAttributedStringKey.foregroundColor: colorPieChart[Int(entry.x)],
            NSAttributedStringKey.font: UIFont.customBold(size: 17.0)]
        )

    }
}
