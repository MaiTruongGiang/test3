//
//  Setting.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-04-01.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import Foundation
import UIKit
struct Setting {
    let icon = UIImageView()
    let title: String
    let accessoryText: (() -> String)?
    let callback: () -> Void
}

extension Setting {
    init(title: String, callback: @escaping () -> Void) {
//        self.icon.image = icon
        self.title = title
        self.accessoryText = nil
        self.callback = callback
    }
}
