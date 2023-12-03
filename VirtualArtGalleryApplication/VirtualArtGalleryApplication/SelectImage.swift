//
//  SelectImage.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 03/11/2023.
//

import UIKit

class SelectImage: NSObject {
    
    var delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    var VC = UIViewController()
    var imgView = UIImageView()
    
    func select() -> Void {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
            
            self.selectImageFromGallery()
            
            
        }))

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            
            self.takeImageFromCamera()
            
            
        }))

        VC.present(actionSheet, animated: true)
        
    }
    
    func selectImageFromGallery() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = delegate
        VC.present(pickerController, animated: true)
    }

    func takeImageFromCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = delegate
        //imagePicker.showsCameraControls = false
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        VC.present(imagePicker, animated: true)
    }
}
