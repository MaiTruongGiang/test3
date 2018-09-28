//
//  PhraseView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-26.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

class PhraseView: UIView {

    private let phrase: String
    private let label = UILabel()
    private let gradientView = GradientView()

    static let defaultSize = CGSize(width: 128.0, height: 88.0)

    var xConstraint: NSLayoutConstraint?

    init(phrase: String) {
        self.phrase = phrase
        super.init(frame: CGRect())
        setupSubviews()
    }

    private func setupSubviews() {
        addSubview(gradientView)
        gradientView.addSubview(label)
       // addSubview(label)
        //gradientView.constrain(toSuperviewEdges: UIEdgeInsetsMake(0, 0, 0, 0))
        gradientView.constrain([
            gradientView.topAnchor.constraint(equalTo: self.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            ])
        label.constrain(toSuperviewEdges: UIEdgeInsets(top: C.padding[1], left: C.padding[2], bottom: -C.padding[1], right: -C.padding[2]))

        label.textColor = .white
        label.text = phrase
        label.font = UIFont.customBold(size: 16.0)
        label.textAlignment = .center
        //backgroundColor = .blue
        gradientView.layer.cornerRadius = 10.0
        gradientView.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
