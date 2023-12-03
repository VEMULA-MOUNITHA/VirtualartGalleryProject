//
//  AddArtistViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 01/12/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class AddArtistViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var descTF: UITextField!
    
    
    var selectedImage: UIImage?
    var imageURL = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imgView.layer.cornerRadius = imgView.frame.size.height * 0.5
        imgView.clipsToBounds = true
        
        self.tabBarController?.tabBar.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func selectImageBtn(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
            
            self.gallery()
            
            
        }))

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            
            self.camera()
            
            
        }))

        self.present(actionSheet, animated: true)
    }
    
    
    func gallery() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        self.present(pickerController, animated: true)
    }

    func camera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        self.present(imagePicker, animated: true)
    }
    

    @IBAction func saveBtn(_ sender: Any) {
            
        if selectedImage == nil {
            
            self.showAlert(str: "Please select image")
        }else if nameTF.text == "" {
            
            self.showAlert(str: "Please enter name")
        }else if descTF.text == "" {
            
            self.showAlert(str: "Please enter description")
        }else {
            
            self.showSpinner(onView: self.view)
            self.uploadArtistImage {
                
                self.saveArtist()
            }
            
        }
    }
    
    func uploadArtistImage(completion: @escaping () -> ()) {
        
        var imageData:Data = selectedImage!.pngData()! as Data
        if imageData.count <= 0 {
            
            imageData = selectedImage!.jpegData(compressionQuality: 1.0)! as Data
        }
        
        let uid = UUID()
        let name = "\(uid).png"
        
        let storageRef = Storage.storage().reference().child("Artists").child("\(name)")
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if error != nil {
                print("error")
                self.removeSpinner()
                completion()
                
            }else {
                
                storageRef.downloadURL(completion: { (url, error) in
                    
                    let str = url?.absoluteString
                    self.imageURL = str ?? ""
                    completion()
                })
            }
        }
    }
    
    
    func saveArtist() -> Void {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let params = ["user_id": id,
                      "name": nameTF.text!,
                      "email": emailTF.text ?? "",
                      "phone": phoneTF.text ?? "",
                      "image": imageURL,
                      "description": descTF.text!]
        

        let path = String(format: "%@", "Artists")
        let db = Firestore.firestore()

        db.collection(path).document().setData(params) { err in
            if let err = err {

                self.removeSpinner()
                self.showAlert(str: err.localizedDescription)

            } else {

                self.removeSpinner()
                let alert = UIAlertController(title: "", message: "Artist added successfully", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in

                    // do something like...
                    self.navigationController?.popViewController(animated: true)

                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    func showAlert(str: String) -> Void {
        
        
        // create the alert
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage

        if let _ = image {
            
            self.imgView.image = image
            self.selectedImage = image
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
