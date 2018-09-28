//
//  GradientButton.swift
//  pluswallet
//
//  Created by 株式会社エンジ on 2018/08/07.
//  Copyright © 2018年 breadwallet LLC. All rights reserved.
//

import UIKit
private let minTargetSize: CGFloat = 48.0
class GradientButton: UIControl {
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        accessibilityLabel = title
        setupViews()
    }
   // var isToggleable = false
    var title: String {
        didSet {
            label.text = title
        }
    }
    private var container = GradientView()
    private let shadowView = UIView()
    private let label = UILabel()
    private let shadowYOffset: CGFloat = 4.0
    private let cornerRadius: CGFloat = 4.0
    private var imageView: UIImageView?

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.04, animations: {
                    let shrink = CATransform3DMakeScale(0.97, 0.97, 1.0)
                    let translate = CATransform3DTranslate(shrink, 0, 4.0, 0)
                    self.container.layer.transform = translate
                })
            } else {
                UIView.animate(withDuration: 0.04, animations: {
                    self.container.transform = CGAffineTransform.identity
                })
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            label.textColor = .white
            container.layer.borderColor = nil
            container.layer.borderWidth = 0.0
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOpacity = 0.15
            imageView?.tintColor = .darkText
        }
    }

    private func setupViews() {
        addShadowView()
        addContent()
       addTarget(self, action: #selector(GradientButton.touchUpInside), for: .touchUpInside)
        setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
    }
    private func addShadowView() {
        addSubview(shadowView)
        shadowView.constrain([
            NSLayoutConstraint(item: shadowView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.5, constant: 0.0),
            shadowView.constraint(.bottom, toView: self),
            shadowView.constraint(.centerX, toView: self),
            NSLayoutConstraint(item: shadowView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0.0) ])
        shadowView.layer.cornerRadius = 4.0
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.backgroundColor = .white
        shadowView.isUserInteractionEnabled = false
    }

    private func addContent() {
        addSubview(container)
       // container.backgroundColor = .primaryButton
        container.layer.cornerRadius = cornerRadius
        container.isUserInteractionEnabled = false
        container.constrain(toSuperviewEdges: nil)
        label.text = title
        label.textColor = .white
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.font = UIFont.customMedium(size: 16.0)
        setupLabelOnly()

    }

    private func setupLabelOnly() {
        container.addSubview(label)
        label.constrain(toSuperviewEdges: UIEdgeInsets(top: C.padding[1], left: C.padding[1], bottom: -C.padding[1], right: -C.padding[1]))
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden || isUserInteractionEnabled else { return nil }
        let deltaX = max(minTargetSize - bounds.width, 0)
        let deltaY = max(minTargetSize - bounds.height, 0)
        let hitFrame = bounds.insetBy(dx: -deltaX/2.0, dy: -deltaY/2.0)
        return hitFrame.contains(point) ? self : nil
    }

    @objc private func touchUpInside() {
        isSelected = !isSelected
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
