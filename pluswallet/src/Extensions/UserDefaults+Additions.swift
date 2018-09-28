//
//  UserDefaults+Additions.swift
//  pluswallet
//
//  Created by Kieu Quoc Chien on 2018/07/23.
//  Copyright © 2018 株式会社エンジ. All rights reserved.
//

import Foundation
import UIKit
enum UDefaultKey {
    static let defaults = UserDefaults.standard
    static let isBiometricsEnabledKey = "istouchidenabled"
    static let defaultCurrencyCodeKey = "defaultcurrency"
    static let hasAquiredShareDataPermissionKey = "has_acquired_permission"
    static let legacyWalletNeedsBackupKey = "WALLET_NEEDS_BACKUP"
    static let writePaperPhraseDateKey = "writepaperphrasedatekey"
    static let hasPromptedBiometricsKey = "haspromptedtouched"
    static let isBtcSwappedKey = "isBtcSwappedKey"
    static let maxDigitsKey = "SETTINGS_MAX_DIGITS"
    static let pushTokenKey = "pushTokenKey"
    static let currentRateKey = "currentRateKey"
    static let customNodeIPKey = "customNodeIPKey"
    static let customNodePortKey = "customNodePortKey"
    static let hasPromptedShareDataKey = "hasPromptedShareDataKey"
//    static let hasShownWelcomeKey = "hasShownBCHWelcomeKey"
    static let hasCompletedKYC = "hasCompletedKYCKey"
    static let hasAgreedToCrowdsaleTermsKey = "hasAgreedToCrowdsaleTermsKey"
    static let feesKey = "feesKey"
    static let selectedCurrencyCodeKey = "selectedCurrencyCodeKey"
    static let mostRecentSelectedCurrencyCodeKey = "mostRecentSelectedCurrencyCodeKey"
    static let hasSetSelectedCurrencyKey = "hasSetSelectedCurrencyKey"
    static let hasBchConnectedKey = "hasBchConnectedKey"
    static let rescanStateKeyPrefix = "lastRescan" // append uppercased currency code for key

    // profile key
    static let profileName = "profile_name"
    static let profileId = "userId"
    static let profileFromGallery = "imageFromGallery"
    static let profileAvatar = "avatar"
    static let profileURL = "imageURL"
    static let addressBTC = "addressBTC"
    static let addressBCH = "addressBCH"
    static let addressETH = "addressETH"
}

extension UserDefaults {

    static var isBiometricsEnabled: Bool {
        get {
            guard  self.standard.object(forKey: UDefaultKey.isBiometricsEnabledKey) != nil else {
                return false
            }
            return  self.standard.bool(forKey: UDefaultKey.isBiometricsEnabledKey)
        }
        set { self.standard.set(newValue, forKey: UDefaultKey.isBiometricsEnabledKey) }
    }

    static var defaultCurrencyCode: String {
        get {
            guard self.standard.object(forKey: UDefaultKey.defaultCurrencyCodeKey) != nil else {
                return Locale.current.currencyCode ?? "USD"
            }
            return self.standard.string(forKey: UDefaultKey.defaultCurrencyCodeKey)!
        }
        set { self.standard.set(newValue, forKey: UDefaultKey.defaultCurrencyCodeKey) }
    }

    static var hasAquiredShareDataPermission: Bool {
        get { return self.standard.bool(forKey: UDefaultKey.hasAquiredShareDataPermissionKey) }
        set { self.standard.set(newValue, forKey: UDefaultKey.hasAquiredShareDataPermissionKey) }
    }

    static var isBtcSwapped: Bool {
        get { return self.standard.bool(forKey: UDefaultKey.isBtcSwappedKey)
        }
        set { self.standard.set(newValue, forKey: UDefaultKey.isBtcSwappedKey) }
    }

    //
    // 2 - bits
    // 5 - mBTC
    // 8 - BTC
    //
    static var maxDigits: Int {
        get {
            guard self.standard.object(forKey: UDefaultKey.maxDigitsKey) != nil else {
                return Currencies.btc.commonUnit.decimals
            }
            let maxDigits = self.standard.integer(forKey: UDefaultKey.maxDigitsKey)
            if maxDigits == 5 {
                return 8 //Convert mBTC to BTC
            } else {
                return maxDigits
            }
        }
        set { self.standard.set(newValue, forKey: UDefaultKey.maxDigitsKey) }
    }

    static var pushToken: Data? {
        get {
            guard self.standard.object(forKey: UDefaultKey.pushTokenKey) != nil else {
                return nil
            }
            return self.standard.data(forKey: UDefaultKey.pushTokenKey)
        }
        set { self.standard.set(newValue, forKey: UDefaultKey.pushTokenKey) }
    }

    static func currentRate(forCode: String) -> Rate? {
        guard let data = self.standard.object(forKey: UDefaultKey.currentRateKey + forCode.uppercased()) as? [String: Any] else {
            return nil
        }
        return Rate(dictionary: data)
    }

    static func currentRateData(forCode: String) -> [String: Any]? {
        guard let data = self.standard.object(forKey: UDefaultKey.currentRateKey + forCode.uppercased()) as? [String: Any] else {
            return nil
        }
        return data
    }

    static func setCurrentRateData(newValue: [String: Any], forCode: String) {
        self.standard.set(newValue, forKey: UDefaultKey.currentRateKey + forCode.uppercased())
    }

    static var customNodeIP: Int? {
        get {
            guard self.standard.object(forKey: UDefaultKey.customNodeIPKey) != nil else { return nil }
            return self.standard.integer(forKey: UDefaultKey.customNodeIPKey)
        }
        set { self.standard.set(newValue, forKey: UDefaultKey.customNodeIPKey) }
    }

    static var customNodePort: Int? {
        get {
            guard self.standard.object(forKey: UDefaultKey.customNodePortKey) != nil else { return nil }
            return self.standard.integer(forKey: UDefaultKey.customNodePortKey)
        }
        set { self.standard.set(newValue, forKey: UDefaultKey.customNodePortKey) }
    }

    static var hasPromptedShareData: Bool {
        get { return self.standard.bool(forKey: UDefaultKey.hasPromptedBiometricsKey) }
        set { self.standard.set(newValue, forKey: UDefaultKey.hasPromptedBiometricsKey) }
    }

//    static var hasShownWelcome: Bool {
//        get { return self.standard.bool(forKey: UDefaultKey.hasShownWelcomeKey) }
//        set { self.standard.set(newValue, forKey: UDefaultKey.hasShownWelcomeKey) }
//    }

    // TODO:BCH not used, remove?
    static var fees: Fees? {
        //Returns nil if feeCacheTimeout exceeded
        get {
            if let feeData = self.standard.data(forKey: UDefaultKey.feesKey), let fees = try? JSONDecoder().decode(Fees.self, from: feeData) {
                return (Date().timeIntervalSince1970 - fees.timestamp) <= C.feeCacheTimeout ? fees : nil
            } else {
                return nil
            }
        }
        set {
            if let fees = newValue, let data = try? JSONEncoder().encode(fees) {
                self.standard.set(data, forKey: UDefaultKey.feesKey)
            }
        }
    }

    static func rescanState(for currency: CurrencyDef) -> RescanState? {
        let key = UDefaultKey.rescanStateKeyPrefix + currency.code.uppercased()
        guard let data = self.standard.object(forKey: key) as? Data else { return nil }
        return try? PropertyListDecoder().decode(RescanState.self, from: data)
    }

    static func setRescanState(for currency: CurrencyDef, to state: RescanState) {
        let key = UDefaultKey.rescanStateKeyPrefix + currency.code.uppercased()
        self.standard.set(try? PropertyListEncoder().encode(state), forKey: key)
    }
}

// MARK: - Wallet Requires Backup
extension UserDefaults {
    static var legacyWalletNeedsBackup: Bool? {
        guard self.standard.object(forKey: UDefaultKey.legacyWalletNeedsBackupKey) != nil else {
            return nil
        }
        return self.standard.bool(forKey: UDefaultKey.legacyWalletNeedsBackupKey)
    }

    static func removeLegacyWalletNeedsBackupKey() {
        self.standard.removeObject(forKey: UDefaultKey.legacyWalletNeedsBackupKey)
    }

    static var writePaperPhraseDate: Date? {
        get {
            guard let date = self.standard.object(forKey: UDefaultKey.writePaperPhraseDateKey) as? Date else {
                // Display a UIAlertController telling the user to check for an updated app..
                return Date()
            }
            return date
            
        }
        set { self.standard.set(newValue, forKey: UDefaultKey.writePaperPhraseDateKey) }
    }

    static var walletRequiresBackup: Bool {
        if UserDefaults.writePaperPhraseDate != nil {
             print("WalletRequiresbackup da ton tai")
            return false
        }
        if let legacyWalletNeedsBackup = UserDefaults.legacyWalletNeedsBackup, legacyWalletNeedsBackup == true {
            print("yeu cau phai backup ben WalletRequiresbackup")
            return true
        }
        if UserDefaults.writePaperPhraseDate == nil {
             print("WalletRequiresbackup chua ton tai")
            return true
        }
        return false
    }
}

// MARK: - Prompts
extension UserDefaults {
    static var hasPromptedBiometrics: Bool {
        get { return self.standard.bool(forKey: UDefaultKey.hasPromptedBiometricsKey) }
        set { self.standard.set(newValue, forKey: UDefaultKey.hasPromptedBiometricsKey) }
    }
}

// MARK: - KYC
extension UserDefaults {
    static func hasCompletedKYC(forContractAddress: String) -> Bool {
        return self.standard.bool(forKey: "\(hasCompletedKYC)\(forContractAddress)")
    }

    static func setHasCompletedKYC(_ hasCompleted: Bool, contractAddress: String) {
        self.standard.set(hasCompleted, forKey: "\(hasCompletedKYC)\(contractAddress)")
    }

    static var hasAgreedToCrowdsaleTerms: Bool {
        get { return self.standard.bool(forKey: UDefaultKey.hasAgreedToCrowdsaleTermsKey) }
        set { self.standard.set(newValue, forKey: UDefaultKey.hasAgreedToCrowdsaleTermsKey) }
    }
}

// MARK: - State Restoration
extension UserDefaults {
    static var selectedCurrencyCode: String? {
        get {
            if self.hasSetSelectedCurrency {
                return self.standard.string(forKey: UDefaultKey.selectedCurrencyCodeKey)
            } else {
                return Currencies.btc.code
            }
        }
        set {
            self.hasSetSelectedCurrency = true
            self.standard.setValue(newValue, forKey: UDefaultKey.selectedCurrencyCodeKey)
        }
    }

    static var hasSetSelectedCurrency: Bool {
        get { return self.standard.bool(forKey: UDefaultKey.hasSetSelectedCurrencyKey) }
        set { self.standard.setValue(newValue, forKey: UDefaultKey.hasSetSelectedCurrencyKey) }
    }

    static var mostRecentSelectedCurrencyCode: String {
        get {
            return self.standard.string(forKey: UDefaultKey.mostRecentSelectedCurrencyCodeKey) ?? Currencies.btc.code
        }
        set {
            self.standard.setValue(newValue, forKey: UDefaultKey.mostRecentSelectedCurrencyCodeKey)
        }
    }

    static var hasBchConnected: Bool {
        get { return self.standard.bool(forKey: UDefaultKey.hasBchConnectedKey) }
        set { self.standard.set(newValue, forKey: UDefaultKey.hasBchConnectedKey) }
    }
}

// MARK: - Profile
extension UserDefaults {
    static var profileName: String {
        get { return self.standard.string(forKey: UDefaultKey.profileName) ?? "Guest" }
        set { self.standard.set(newValue, forKey: UDefaultKey.profileName) }
    }
    static var profileId: String {
        get { return self.standard.string(forKey: UDefaultKey.profileId) ?? "" }
        set { self.standard.set(newValue, forKey: UDefaultKey.profileId) }
    }
    static var profileAvatar: Data {
        get {
            guard let avatar = self.standard.object(forKey: UDefaultKey.profileAvatar) as? Data else {
                // Display a UIAlertController telling the user to check for an updated app..
                return UIImagePNGRepresentation(#imageLiteral(resourceName: "plus_wallet_icoin1"))!
            }
            return avatar
        }
        set { self.standard.set(newValue, forKey: UDefaultKey.profileAvatar)}
    }
    static var profileFromGallery: Bool {
        get { return (self.standard.bool(forKey: UDefaultKey.profileFromGallery)) || false}
        set { self.standard.set(newValue, forKey: UDefaultKey.profileFromGallery)}
    }
    static var addressBTC: String {
        get { return self.standard.string(forKey: UDefaultKey.addressBTC) ?? "" }
        set { self.standard.set(newValue, forKey: UDefaultKey.addressBTC) }
    }
    static var addressBCH: String {
        get { return self.standard.string(forKey: UDefaultKey.addressBCH) ?? "" }
        set { self.standard.set(newValue, forKey: UDefaultKey.addressBCH) }
    }
    static var addressETH: String {
        get { return self.standard.string(forKey: UDefaultKey.addressETH) ?? "" }
        set { self.standard.set(newValue, forKey: UDefaultKey.addressETH) }
    }
    static var profileURL: String {
        get { return self.standard.string(forKey: UDefaultKey.profileURL) ?? "" }
        set { self.standard.set(newValue, forKey: UDefaultKey.profileURL) }
    }
}
