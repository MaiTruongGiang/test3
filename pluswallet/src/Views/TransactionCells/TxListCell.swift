//
//  TxListCell.swift
//  plusWallet
//
//  Created by Zan on 2018-07-23.
//  Copyright © 2018 pluswallet LLC. All rights reserved.
//

import UIKit

class TxListCell: UITableViewCell {

    // MARK: - Views

    private let timestamp = UILabel(font: .customBody(size: 16.0), color: .darkGray)
    private let descriptionLabel = UILabel(font: .customBody(size: 14.0), color: .lightGray)
    private let amount = UILabel(font: .customBold(size: 18.0))
    private let separator = UIView(color: .separatorGray)
    private let statusIndicator = TxStatusIndicator(width: 44.0)
    private let failedIndicator = UIButton(type: .system)
    private var pendingConstraints = [NSLayoutConstraint]()
    private var completeConstraints = [NSLayoutConstraint]()
    private var directionIcon = UIImageView()
    private var symbol: UIImageView = {
       let img = UIImageView()
        img.layer.cornerRadius = C.padding[3]
        img.clipsToBounds = true
        return img
    }()
    private var completebtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 4
        btn.setTitle(S.TxListCell.completed, for: UIControlState.normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn

    }()
    private var pendingbtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 4
        btn.setTitle(S.TxListCell.pending, for: UIControlState.normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: Vars

    private var viewModel: TxListViewModel!

    // MARK: - Init

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    func setTransaction(_ viewModel: TxListViewModel, isBtcSwapped: Bool, rate: Rate, maxDigits: Int, isSyncing: Bool) {
        self.viewModel = viewModel
       // symbol = viewModel.symbol!
        timestamp.text = viewModel.longTimestamp
        descriptionLabel.text = viewModel.shortDescription
        amount.attributedText = viewModel.amount(isBtcSwapped: isBtcSwapped, rate: rate)

        statusIndicator.status = viewModel.status

        symbol.image = UIImage(named: viewModel.currency.code.lowercased())
    //    print(viewModel.direction)
        switch viewModel.direction {
        case .sent:
            directionIcon.image = #imageLiteral(resourceName: "icon_up")
        case .received:
            directionIcon.image = #imageLiteral(resourceName: "icon_down")
        default:
            directionIcon.image = #imageLiteral(resourceName: "icon_change_profile")
        }
        switch viewModel.status {
        case .invalid:
            failedIndicator.isHidden = false
            statusIndicator.isHidden = true
            timestamp.isHidden = true
            completebtn.isHidden = true
            pendingbtn.isHidden = true
          //  print("invalid")
        case .complete:
            failedIndicator.isHidden = true
            statusIndicator.isHidden = true
            timestamp.isHidden = false
           // print("complete")

            pendingbtn.isHidden = true
            completebtn.isHidden = false
        default:
            failedIndicator.isHidden = true
            statusIndicator.isHidden = false
            timestamp.isHidden = true
          //  print("default")
            pendingbtn.isHidden = false
            completebtn.isHidden = true
        }
    }

    // MARK: - Private

    private func setupViews() {
        addSubviews()
        addConstraints()
        setupStyle()
    }

    private func addSubviews() {
        contentView.addSubview(timestamp)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(statusIndicator)
        contentView.addSubview(failedIndicator)
        contentView.addSubview(amount)
        contentView.addSubview(separator)
        contentView.addSubview(symbol)
        contentView.addSubview(directionIcon)
        contentView.addSubview(completebtn)
        contentView.addSubview(pendingbtn)
    }

    private func addConstraints() {

        symbol.constrain([
            symbol.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            symbol.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: C.padding[2]),
            symbol.widthAnchor.constraint(equalToConstant: C.padding[6]),
            symbol.heightAnchor.constraint(equalTo: symbol.widthAnchor)
            ])
        directionIcon.constrain([
            directionIcon.centerXAnchor.constraint(equalTo: symbol.centerXAnchor, constant: 20),
            directionIcon.bottomAnchor.constraint(equalTo: symbol.bottomAnchor, constant: 5),
            directionIcon.widthAnchor.constraint(equalToConstant: C.padding[3]),
            directionIcon.heightAnchor.constraint(equalToConstant: C.padding[3])
            ])
        descriptionLabel.constrain([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: C.padding[1]),
            descriptionLabel.leadingAnchor.constraint(equalTo: symbol.trailingAnchor, constant: C.padding[3]),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40)
//            descriptionLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        amount.constrain([
            amount.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: C.padding[1]),
            amount.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor)
            ])

        timestamp.constrain([
            timestamp.topAnchor.constraint(equalTo: amount.bottomAnchor, constant: C.padding[1]),
            timestamp.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor)])

//        descriptionLabel.constrain([
//            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -C.padding[2]),
//            descriptionLabel.trailingAnchor.constraint(equalTo: timestamp.trailingAnchor)])
        pendingbtn.constrain([
            pendingbtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -C.padding[1]),
            pendingbtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pendingbtn.widthAnchor.constraint(equalToConstant: 75),
            pendingbtn.heightAnchor.constraint(equalToConstant: 20)
            ])
        completebtn.constrain([completebtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -C.padding[1]),
                               completebtn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                               completebtn.widthAnchor.constraint(equalToConstant: 75),
                               completebtn.heightAnchor.constraint(equalToConstant: 20)])
//        statusIndicator.constrain([
//            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            statusIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: C.padding[2]),
//            statusIndicator.widthAnchor.constraint(equalToConstant: statusIndicator.width),
//            statusIndicator.heightAnchor.constraint(equalToConstant: statusIndicator.height)])
        failedIndicator.constrain([
            failedIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -C.padding[1]),
            failedIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            failedIndicator.widthAnchor.constraint(equalToConstant: 70),
            failedIndicator.heightAnchor.constraint(equalToConstant: 20)])

        separator.constrainBottomCorners(height: 0.5)

    }

    private func setupStyle() {
        selectionStyle = .none
        amount.textAlignment = .right
        amount.setContentHuggingPriority(.required, for: .horizontal)
        timestamp.setContentHuggingPriority(.required, for: .vertical)
        descriptionLabel.lineBreakMode = .byTruncatingTail

        failedIndicator.setTitle(S.Transaction.failed, for: .normal)
        failedIndicator.titleLabel?.font = .customBold(size: 12.0)
        failedIndicator.setTitleColor(.white, for: .normal)
        failedIndicator.backgroundColor = .failedRed
        failedIndicator.layer.cornerRadius = 3
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
