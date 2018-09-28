//
//  FirebaseManager.swift
//  pluswallet
//
//  Created by Kieu Quoc Chien on 2018/09/06.
//  Copyright © 2018 株式会社エンジ. All rights reserved.
//

//import Foundation
//import FirebaseAuth
//import FirebaseFirestore
//import FirebaseStorage
//
//class FirebaseManager {
//    var db: Firestore
//    private static let shared = FirebaseManager()
//
//    init() {
//        db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
//        setup()
//    }
//
//    private func setup() {
//        // Observing Authentication State
//        Auth.auth().addStateDidChangeListener { _, user in
//            // TODO: store user Info in firebase system, not in 'users' collection
//            if user != nil {
//                guard let userId = user?.uid else {
//                    return
//                }
//
//                // cheat userId
//                guard let userID = Store.state.wallets[Currencies.eth.code]?.receiveAddress else {
//                    return
//                }
//
//                self.db.collection("users").document(userID)
//                    .addSnapshotListener { snapshot, error in
//                        guard let document = snapshot else {
//                            print("Error fetching document: \(error!)")
//                            return
//                        }
//                        guard let data = document.data() else {
//                            print("Document data was empty.")
//                            return
//                        }
//
//                        Store.perform(action: ProfileChange.setProfileId(userId))
//
//                        // Create reference to the file whose metadata we want to retrieve
//                        if let username = data["username"] {
//                            Store.perform(action: ProfileChange.setUsername(username as! String))
//                        }
//
//                        if let imageUrl = data["userimage"] as? String, !imageUrl.isEmpty {
//                            let isFromGallery = imageUrl.range(of: "avatar") != nil || imageUrl.range(of: "http") != nil
//                            let storageRef = Storage.storage().reference()
//                            Store.perform(action: ProfileChange.setProfileUrl(imageUrl, isFromGallery: isFromGallery))
//                            if !isFromGallery {
//                                let img = UIImage(named: imageUrl)!
//                                let imgValue = max((img.size.width), (img.size.height))
//                                var userImage: Data
//                                if imgValue > 3000 {
//                                    userImage = UIImageJPEGRepresentation(img, 0.1)! as Data
//                                } else if imgValue > 2000 {
//                                    userImage = UIImageJPEGRepresentation(img, 0.3)! as Data
//                                } else {
//                                    userImage = UIImagePNGRepresentation(img)! as Data
//                                }
//
//                                Store.perform(action: ProfileChange.setProfileAvatar(userImage))
//                                return
//                            }
//                            // Create a reference to the file you want to download
//                            let imageRef = storageRef.child(imageUrl)
//
//                            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//                            imageRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
//                                if let error = error {
//                                    // Uh-oh, an error occurred!
//                                    print("Error fetching image: \(error)")
//                                } else {
//                                    Store.perform(action: ProfileChange.setProfileAvatar(data! as Data))
//                                }
//                            }
//                        }
//                }
//            } else {
//                // No User is signed in. Show user the login screen
//            }
//        }
//    }
//
//    static func loginUser(userId: String, password: String, completion: @escaping () -> Void) {
//        Auth.auth().signIn(withEmail: userId, password: password) { (user, error) in
//            if let error = error, user == nil {
//                let alert = UIAlertController(title: "Sign In Failed",
//                                              message: error.localizedDescription,
//                                              preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//            }
//            completion()
//        }
//    }
//
//    static func uploadAvatar(imgPath: String?, data: Data?) {
//        guard let userId: String = Auth.auth().currentUser!.uid else {
//            return
//        }
//        guard let imgPath = imgPath, let data = data else {
//            return
//        }
//        //Image upload to Firebase
//        let storageRef = Storage.storage().reference().child(imgPath)
//        storageRef.putData(data, metadata: nil, completion: { (_, error) in
//            if error != nil {
//                print("Error upload data to Firebase Storage. Detail: \(String(describing: error))")
//                return
//            }
//            Store.perform(action: ProfileChange.setProfileAvatar(data))
//        })
//    }
//
//    static func updateUserInfo() {
//        guard let userId: String = Auth.auth().currentUser!.uid else {
//            return
//        }
//
//        let docData: [String: Any] = [
//            "username": Store.state.userState.userName,
//            "userimage": Store.state.userState.imageURL
//        ]
//
//        // cheat userId
//        guard let userID = Store.state.wallets[Currencies.eth.code]?.receiveAddress else {
//            return
//        }
//
//        shared.db.collection("users").document(userID).setData(docData, merge: true) { err in
//            if let err = err {
//                print("Error writing document: \(err)")
//            } else {
//                print("User is updated successfully!")
//            }
//        }
//    }
//
//    static func updateWalletAddress() {
//        guard let user = Auth.auth().currentUser else {
//            return
//        }
//
//        var addressArr: [String: String] = [:]
//        Store.state.wallets.values.forEach {
//            guard let address = $0.receiveAddress else {
//                return
//            }
//            addressArr.updateValue(address, forKey: $0.currency.code)
//        }
//
//        // cheat userId
//        guard let userID = Store.state.wallets[Currencies.eth.code]?.receiveAddress else {
//            return
//        }
//        // Update address on BTC & BCH collections
//        let batch = shared.db.batch()
//        Store.state.wallets.forEach {
//            guard let address = $0.value.receiveAddress else {
//                return
//            }
//            let ref = shared.db.collection("address\($0.key)").document(address)
//            batch.setData([ "userID": userID ], forDocument: ref)
//        }
//
//        let userRef = shared.db.collection("users").document(userID)
//        batch.setData([ "address": addressArr ], forDocument: userRef, merge: true)
//        // Commit the batch
//        batch.commit { err in
//            if let err = err {
//                print("Error writing document: \(err)")
//            } else {
//                print("addressBCH is updated successfully!")
//            }
//        }
//    }
//
//    static func fetchUserInfo(userId: String?, completion: @escaping (_ data: [String: Any]) -> Void) {
//        guard let id = userId else {
//            print("Error fetching user info: userId param is nil")
//            return
//        }
//
//        shared.db.collection("users").document(id).getDocument { snapshot, error in
//            guard let document = snapshot else {
//                print("Error fetching document: \(error!)")
//                return
//            }
//
//            guard let data = document.data() else {
//                print("Document data was empty.")
//                return
//            }
//
//            return completion(data)
//        }
//    }
//
//    static func fetchUserInfoByAddress(tag: String?, address: String?, completion: @escaping (_ data: [String: Any]) -> Void) {
//        guard let tag = tag else {
//            print("Error fetching user info: userId param is nil")
//            return
//        }
//        guard let address = address else {
//            print("Error fetching user info: userId param is nil")
//            return
//        }
//
//        shared.db.collection("address\(tag)").document(address).getDocument { snapshot, error in
//            guard let document = snapshot else {
//                print("Error fetching document: \(error!)")
//                return
//            }
//            guard let data = document.data() else {
//                print("Document data was empty.")
//                return
//            }
//
//            guard let userId = data["userID"] as? String else {
//                print("User id was empty.")
//                return
//            }
//
//            FirebaseManager.fetchUserInfo(userId: userId, completion: completion)
//        }
//    }
//}




//
//  FirebaseManager.swift
//  pluswallet
//
//  Created by Kieu Quoc Chien on 2018/09/06.
//  Copyright © 2018 株式会社エンジ. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    var db: Firestore
    private static let shared = FirebaseManager()
    
    init() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        setup()
    }
    
    private func setup() {
        // Observing Authentication State
        Auth.auth().addStateDidChangeListener { _, user in
            // TODO: store user Info in firebase system, not in 'users' collection
            if user != nil {
                guard let userId = user?.uid else {
                    return
                }
                
                // cheat userId
                guard let userID = Store.state.wallets[Currencies.eth.code]?.receiveAddress else {
                    return
                }
                
                self.db.collection("users").document(userID)
                    .addSnapshotListener { snapshot, error in
                        guard let document = snapshot else {
                            print("Error fetching document: \(error!)")
                            return
                        }
                        guard let data = document.data() else {
                            print("Document data was empty.")
                            return
                        }
                        
                        Store.perform(action: ProfileChange.setProfileId(userId))
                        
                        // Create reference to the file whose metadata we want to retrieve
                        if let username = data["username"] {
                            Store.perform(action: ProfileChange.setUsername(username as! String))
                        }
                        
                        if let imageUrl = data["userimage"] as? String, !imageUrl.isEmpty {
                            let isFromGallery = imageUrl.range(of: "avatar") != nil || imageUrl.range(of: "http") != nil
                            let storageRef = Storage.storage().reference()
                            Store.perform(action: ProfileChange.setProfileUrl(imageUrl, isFromGallery: isFromGallery))
                            if !isFromGallery {
                                let img = UIImage(named: imageUrl)!
                                let imgValue = max((img.size.width), (img.size.height))
                                var userImage: Data
                                if imgValue > 3000 {
                                    userImage = UIImageJPEGRepresentation(img, 0.1)! as Data
                                } else if imgValue > 2000 {
                                    userImage = UIImageJPEGRepresentation(img, 0.3)! as Data
                                } else {
                                    userImage = UIImagePNGRepresentation(img)! as Data
                                }
                                
                                Store.perform(action: ProfileChange.setProfileAvatar(userImage))
                                return
                            }
                            // Create a reference to the file you want to download
                            let imageRef = storageRef.child(imageUrl)
                            
                            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                            imageRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
                                if let error = error {
                                    // Uh-oh, an error occurred!
                                    print("Error fetching image: \(error)")
                                } else {
                                    Store.perform(action: ProfileChange.setProfileAvatar(data! as Data))
                                }
                            }
                        }
                }
            } else {
                // No User is signed in. Show user the login screen
            }
        }
    }
    
    static func loginUser(userId: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: userId, password: password) { (user, error) in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
            }
            completion()
        }
    }
    
    static func uploadAvatar(imgPath: String?, data: Data?) {
        guard let userId: String = Auth.auth().currentUser!.uid else {
            return
        }
        guard let imgPath = imgPath, let data = data else {
            return
        }
        //Image upload to Firebase
        let storageRef = Storage.storage().reference().child(imgPath)
        storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("Error upload data to Firebase Storage. Detail: \(String(describing: error))")
                return
            }
            Store.perform(action: ProfileChange.setProfileAvatar(data))
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                
                Store.perform(action: ProfileChange.setProfileUrl(downloadURL.absoluteString, isFromGallery: true))
                FirebaseManager.updateUserInfo()
            }
        })
    }
    
    static func updateUserInfo() {
        guard let userId: String = Auth.auth().currentUser!.uid else {
            return
        }
        
        let address: [String: Any] = [
            "BCH": Store.state.wallets[Currencies.bch.code]?.receiveAddress,
            "BTC": Store.state.wallets[Currencies.btc.code]?.receiveAddress,
            "ETH": Store.state.wallets[Currencies.eth.code]?.receiveAddress
        ]
        
        let docData: [String: Any] = [
            "username": Store.state.userState.userName,
            "userimage": Store.state.userState.imageURL,
            "address": address
        ]
        
//        let docData: [String: Any] = [
//            "username": Store.state.userState.userName,
//            "userimage": Store.state.userState.imageURL
//        ]
        
        
        
        // cheat userId
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        shared.db.collection("users").document(userID).setData(docData, merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("User is updated successfully!")
            }
        }
        updateWalletAddress()
    }
    
    static func updateWalletAddress() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        var addressArr: [String: String] = [:]
        Store.state.wallets.values.forEach {
            guard let address = $0.receiveAddress else {
                return
            }
            addressArr.updateValue(address, forKey: $0.currency.code)
        }
        
        // cheat userId
        guard let userID = Store.state.wallets[Currencies.eth.code]?.receiveAddress else {
            return
        }
        // Update address on BTC & BCH collections
        let batch = shared.db.batch()
        Store.state.wallets.forEach {
            guard let address = $0.value.receiveAddress else {
                return
            }
            let ref = shared.db.collection("address\($0.key)").document(address)
            batch.setData([ "userID": userID ], forDocument: ref)
        }
        
        let userRef = shared.db.collection("users").document(userID)
        batch.setData([ "address": addressArr ], forDocument: userRef, merge: true)
        // Commit the batch
        batch.commit { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("addressBCH is updated successfully!")
            }
        }
    }
    
    static func fetchUserInfo(userId: String?, completion: @escaping (_ data: [String: Any]) -> Void) {
        guard let id = userId else {
            print("Error fetching user info: userId param is nil")
            return
        }
        
        shared.db.collection("users").document(id).getDocument { snapshot, error in
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            return completion(data)
        }
    }
    
    
    
    static func fetchUserInfoByAddress(tag: String?, address: String?, completion: @escaping (_ data: [String: Any]) -> Void) {
        guard let tag = tag else {
            print("Error fetching user info: userId param is nil")
            return
        }
        guard let address = address else {
            print("Error fetching user info: userId param is nil")
            return
        }
        
        shared.db.collection("address\(tag)").document(address).getDocument { snapshot, error in
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            guard let userId = data["userID"] as? String else {
                print("User id was empty.")
                return
            }
            
            FirebaseManager.fetchUserInfo(userId: userId, completion: completion)
        }
    }
}

