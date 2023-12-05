//
//  AddPaintingViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula  on 01/12/2023.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import AnimatedGradientView

protocol addPaintingDelegate {
    
    func didAdded() -> Void
}

class AddPaintingViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var delegte: addPaintingDelegate?
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var descTF: UITextField!
    
    var artist_id = ""
    var painting_id = ""
    
    var selectedImage: UIImage?
    var imageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imgView.layer.cornerRadius = imgView.frame.size.height * 0.5
        imgView.clipsToBounds = true
        
        let animatedGradient = AnimatedGradientView(frame: view.bounds)
        animatedGradient.direction = .up
        animatedGradient.animationValues = [(colors: ["#2BC0E4", "#EAECC6"], .up, .axial),
        (colors: ["#833ab4", "#fd1d1d", "#fcb045"], .right, .axial),
        (colors: ["#003973", "#E5E5BE"], .down, .axial),
        (colors: ["#1E9600", "#FFF200", "#FF0000"], .left, .axial)]
        //self.view.layer.insertSublayer(animatedGradient.layer, at: 0)
        self.view.insertSubview(animatedGradient, at: 0)
        
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
        }else if priceTF.text == "" {
            
            self.showAlert(str: "Please enter price")
        }else if descTF.text == "" {
            
            self.showAlert(str: "Please enter description")
        }else {
            
            self.showSpinner(onView: self.view)
            self.uploadArtistPaintingImage {
                
                self.savePainting()
            }
            
        }
    }
    
    
    func uploadArtistPaintingImage(completion: @escaping () -> ()) {
        
        var imageData:Data = selectedImage!.pngData()! as Data
        if imageData.count <= 0 {
            
            imageData = selectedImage!.jpegData(compressionQuality: 1.0)! as Data
        }
        
        let uid = UUID()
        let name = "\(uid).png"
        
        let storageRef = Storage.storage().reference().child("Paintings").child("\(name)")
        
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
    
    func savePainting() -> Void {
        
        let params = ["artist_id": artist_id,
                      "name": nameTF.text!,
                      "price": priceTF.text ?? "0",
                      "image": imageURL,
                      "description": descTF.text!]
        

        let path = String(format: "%@", "Paintings")
        let db = Firestore.firestore()

        db.collection(path).document().setData(params) { err in
            if let err = err {

                self.removeSpinner()
                self.showAlert(str: err.localizedDescription)

            } else {

                self.removeSpinner()
                let alert = UIAlertController(title: "", message: "Painting added successfully", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in

                    self.delegte?.didAdded()
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


