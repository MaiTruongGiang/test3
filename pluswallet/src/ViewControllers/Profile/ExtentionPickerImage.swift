//
//  ExtentionPickerImage.swift
//  pluswallet
//
//  Created by zan on 2018/08/21.
//  Copyright © 2018年 株式会社エンジ LLC. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseAuth
import FirebaseStorage

extension ProfileViewController {
    @objc func changeAvatarOnClick() {

        let alert: UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

        //Icon
        let iconAction = UIAlertAction(title: "Icon", style: UIAlertActionStyle.default) {_ in
            self.openIcon()
        }
        //camera
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) {_ in
            self.openCamera()
        }
        //gallery
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default) {_ in
            self.openGallery()
        }

        //cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)

        // Add the actions
        picker.delegate = self
        alert.addAction(iconAction)
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    func openIcon() {
        let avatarSelection = AvatarSelectionViewController()
        avatarSelection.didChangeAvatar = self.changeAvatar
        navigationController?.pushViewController(avatarSelection, animated: true)
    }

    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self .present(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Warning", message: "you dont have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in}))
            present(alert, animated: true, completion: nil)
        }
    }

    func openGallery() {
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

        // get image
        let img = info[UIImagePickerControllerOriginalImage] as? UIImage

        if img != nil {
            self.changeAvatar(img: img!, isGallery: true, iconName: "")
        } else {
            showAlert(title: "Image load failed", message: "Your image cannot be loaded", buttonLabel: "Close")
        }

        dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func changeAvatar(img: UIImage, isGallery: Bool, iconName: String) {
        let imgValue = max((img.size.width), (img.size.height))
        var userImage: Data
        if isGallery {
            let imgValue = max((img.size.width), (img.size.height))
            if imgValue > 3000 {
                userImage = UIImageJPEGRepresentation(img, 0.1)! as Data
            } else if imgValue > 2000 {
                userImage = UIImageJPEGRepresentation(img, 0.3)! as Data
            } else {
                userImage = UIImagePNGRepresentation(img)! as Data
            }
        }
        else {
            userImage = UIImagePNGRepresentation(img)! as Data
        }

        // Update avatar
        avatar.image = img
        imageData = userImage
        imageFromGallery = isGallery
        nameIcon = iconName
    }

    //////////////////
    @objc func updateProfileOnClick(_ sender: AnyObject) {
        Store.perform(action: ProfileChange.setUsername(nameTextField.text ?? ""))
        if let data: Data = self.imageData, imageFromGallery {
            Store.perform(action: ProfileChange.setProfileAvatar(data))
            // cheat userId
//            guard let userID = Store.state.wallets[Currencies.eth.code]?.receiveAddress else {
//                return
//            }
            guard let userID = Auth.auth().currentUser?.uid else{return}
            let imgPath = "avatar/\(Store.state.userState.userID).png"
    
//            Store.perform(action: ProfileChange.setProfileUrl(imgPath, isFromGallery: true))
            Store.trigger(name: .uploadAvatar(imgPath, data))
        }else{
            if nameIcon != ""{
                Store.perform(action: ProfileChange.setProfileAvatar(self.imageData!))
                Store.perform(action: ProfileChange.setProfileUrl(nameIcon, isFromGallery: false))
            }
            Store.trigger(name: .updateUserProfile)
        }
        /////////////
//        let settingsVC = SettingsViewController()
//        navigationController?.popToViewController(settingsVC, animated: true)
        let vcs: [UIViewController] = (self.navigationController?.viewControllers)!
        print(vcs)
     //   if(vcs.count == 4){
            self.navigationController?.popToViewController(vcs[0], animated: true)
     //   } else{
    }
    func alert(_ message: String, viewControler: UIViewController) {
        let alertController = UIAlertController(title: "Alert",
                                                message: message,
                                                preferredStyle: .alert)
        // add "Cancel" button
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { (_) in
                                            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        viewControler.present(alertController, animated: true, completion: nil)
    }
}
