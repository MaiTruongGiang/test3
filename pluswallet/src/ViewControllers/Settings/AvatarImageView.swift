//
//  AvatarHeaderView.swift
//  pluswallet
//
//  Created by Kieu Quoc Chien on 2018/07/17.
//  Copyright © 2018 株式会社エンジ. All rights reserved.
//
import UIKit
import RxCocoa
import RxSwift

public typealias VerticalGradientColors = (top: UIColor, bottom: UIColor)
typealias HSVOffset = (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)

// MARK: Gradient Constant
let kGradientTopOffset: HSVOffset = (hue: -0.025, saturation: 0.05, brightness: 0, alpha: 0)
let kGradientBottomOffset: HSVOffset = (hue: 0.025, saturation: -0.05, brightness: 0, alpha: 0)
let kFontResizingProportion: CGFloat = 0.4
let kColorMinComponent: Int = 30
let kColorMaxComponent: Int = 214

class AvatarHeaderView: UIView {
    private let avatarSize: CGFloat = 100.0
    private let disposeBag = DisposeBag()
    let avatar = UIImageView()
    let avatarLabel = UILabel()

    init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    init(frame: CGRect, avatarName: String, avatarImg: UIImage?, circular: Bool, labelAttributes: [NSAttributedStringKey: AnyObject]?) {
        super.init(frame: frame)
        let attributes: [NSAttributedStringKey: AnyObject] = (labelAttributes != nil) ? labelAttributes! : [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.whiteBackground
        ]
        avatarLabel.attributedText = NSMutableAttributedString(string: avatarName, attributes: attributes)

        if avatarImg != nil {
            self.setAvatar(avatarImg)
        } else {
            setAvatarByName(name: avatarName, backgroundColor: UIColor.whiteBackground, circular: circular, textAttributes: nil, gradientColors: nil)
        }

        setup()
    }

    init(frame: CGRect, avatarName: String, backgroundColor: UIColor? = nil, circular: Bool,
         textAttributes: [NSAttributedStringKey: AnyObject]?, gradient: Bool = false) {
        super.init(frame: frame)
        setAvatarByName(name: avatarName, backgroundColor: backgroundColor, circular: circular,
                        textAttributes: textAttributes, gradient: gradient, gradientColors: nil)
        setup()
    }

    public func setAvatarName(string: String) {
        avatarLabel.text = string
    }

    public func setAvatar(_ image: UIImage?) {
        guard let img = image else {
            return
        }
        avatar.image = img
    }

    public func setText(string: String, font: UIFont?) {
        avatarLabel.text = string
        avatarLabel.font = font
        avatarLabel.textColor = UIColor.whiteTint
    }
    private func setup() {

        // Avatar Setting
        if !Store.state.userState.imageFromGallery {
            avatar.contentMode = UIViewContentMode.center
        } else {
            avatar.contentMode = UIViewContentMode.scaleToFill
        }

        avatar.backgroundColor = UIColor.whiteBackground
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = avatarSize / 2

        UserDefaults.standard.rx
            .observe(Bool.self, UDefaultKey.profileFromGallery)
            .subscribe(onNext: { (value) in
                let imageFromGallery = value ?? false
                if !imageFromGallery {
                    self.avatar.contentMode = UIViewContentMode.center
                } else {
                    self.avatar.contentMode = UIViewContentMode.scaleAspectFill
                }
            })
            .disposed(by: disposeBag)

        addSubview(avatar)
        addSubview(avatarLabel)

        avatar.constrain([
            avatar.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            avatar.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: avatarSize),
            avatar.heightAnchor.constraint(equalToConstant: avatarSize)
        ])

        avatarLabel.constrain([
            avatarLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            avatarLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: C.padding[1])
        ])
    }

    private func setAvatarByName(name: String, backgroundColor: UIColor?, circular: Bool, textAttributes: [NSAttributedStringKey: AnyObject]?, gradient: Bool = false, gradientColors: VerticalGradientColors?) {
        let initials: String = getInitialsChar(string: name)
        let color: UIColor = (backgroundColor != nil) ? backgroundColor! : randomColor(for: name)
        let gradientColors = gradientColors ?? gradientTopAndBottom(for: color)
        let attributes: [NSAttributedStringKey: AnyObject] = (textAttributes != nil) ? textAttributes! : [
            NSAttributedStringKey.font: self.fontForAvatar(fontName: nil),
            NSAttributedStringKey.foregroundColor: UIColor.whiteBackground
        ]

        avatar.image = generateTextAvatar(text: initials, backgroundColor: color, circular: circular, textAttributes: attributes, gradient: gradient, gradientColors: gradientColors)

    }

    private func generateTextAvatar(text imageText: String, backgroundColor: UIColor, circular: Bool, textAttributes: [NSAttributedStringKey: AnyObject], gradient: Bool, gradientColors: VerticalGradientColors) -> UIImage {

        let scale: CGFloat = UIScreen.main.scale

        var size: CGSize = self.bounds.size
        if (self.contentMode == .scaleToFill ||
            self.contentMode == .scaleAspectFill ||
            self.contentMode == .scaleAspectFit ||
            self.contentMode == .redraw) {

            size.width = (size.width * scale) / scale
            size.height = (size.height * scale) / scale
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        let context: CGContext = UIGraphicsGetCurrentContext()!

        if circular {
            // Clip context to a circle
            let path: CGPath = CGPath(ellipseIn: self.bounds, transform: nil)
            context.addPath(path)
            context.clip()
        }

        if gradient {
            // Draw a gradient from the top to the bottom
            let baseSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [gradientColors.top.cgColor, gradientColors.bottom.cgColor]
            let gradient = CGGradient(colorsSpace: baseSpace, colors: colors as CFArray, locations: nil)!

            let startPoint = CGPoint(x: self.bounds.midX, y: self.bounds.minY)
            let endPoint = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)

            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        } else {
            // Fill background of context
            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        // Draw text in the context
        let textSize: CGSize = imageText.size(withAttributes: textAttributes)
        let bounds: CGRect = self.bounds

        imageText.draw(in: CGRect(x: bounds.midX - textSize.width / 2,
                                  y: bounds.midY - textSize.height / 2,
                                  width: textSize.width,
                                  height: textSize.height),
                       withAttributes: textAttributes)

        let snapshot: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return snapshot
    }

    private func getInitialsChar(string: String) -> String {
        return string.components(separatedBy: .whitespacesAndNewlines).reduce("") {
            ($0.isEmpty ? "" : "\($0.uppercased().first!)") + ($1.isEmpty ? "" : "\($1.uppercased().first!)")
        }
    }

    private func fontForAvatar(fontName: String?) -> UIFont {
        let fontSize = self.bounds.width * kFontResizingProportion
        if fontName != nil {
            return UIFont(name: fontName!, size: fontSize)!
        } else {
            return UIFont.systemFont(ofSize: fontSize)
        }
    }

    private func randomColorComponent() -> Int {
        let limit = kColorMaxComponent - kColorMinComponent
        return kColorMinComponent + Int(drand48() * Double(limit))
    }

    private func randomColor(for string: String) -> UIColor {
        srand48(string.hashValue)

        let red = CGFloat(randomColorComponent()) / 255.0
        let green = CGFloat(randomColorComponent()) / 255.0
        let blue = CGFloat(randomColorComponent()) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    private func clampColorComponent(_ value: CGFloat) -> CGFloat {
        return min(max(value, 0), 1)
    }

    private func correctColorComponents(of color: UIColor, withHSVOffset offset: HSVOffset) -> UIColor {

        var hue = CGFloat(0)
        var saturation = CGFloat(0)
        var brightness = CGFloat(0)
        var alpha = CGFloat(0)
        if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            hue = clampColorComponent(hue + offset.hue)
            saturation = clampColorComponent(saturation + offset.saturation)
            brightness = clampColorComponent(brightness + offset.brightness)
            alpha = clampColorComponent(alpha + offset.alpha)
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }

        return color
    }

    private func gradientTopAndBottom(for color: UIColor, withTopHSVOffset topHSVOffset: HSVOffset = kGradientTopOffset, withBottomHSVOffset bottomHSVOffset: HSVOffset = kGradientBottomOffset) -> VerticalGradientColors {
        let topColor = correctColorComponents(of: color, withHSVOffset: topHSVOffset)
        let bottomColor = correctColorComponents(of: color, withHSVOffset: bottomHSVOffset)
        return (top: topColor, bottom: bottomColor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
