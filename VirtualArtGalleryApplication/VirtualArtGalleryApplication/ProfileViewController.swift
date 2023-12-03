//
//  ProfileViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 03/11/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import SDWebImage
import CoreData
import FirebaseFirestore


class ProfileViewController: UIViewController {

    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var phoneLBL: UILabel!
    
    var selectedImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editBtn.layer.cornerRadius = editBtn.frame.size.height / 2
        nameView.layer.cornerRadius = 8
        phoneView.layer.cornerRadius = 8
        passwordView.layer.cornerRadius = 8
        logoutView.layer.cornerRadius = 8
        
        
        imgView.layer.cornerRadius = imgView.frame.size.height / 2
        imgView.clipsToBounds = true
        // Do any additional setup after loading the view.
        
        self.getProfileData()
    }
    
    func getProfileData() -> Void {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let path1 = String(format: "Users/%@", id)
        let db = Firestore.firestore()
        
        let docRef = db.document(path1)
        docRef.getDocument(completion: { snap, error in
            
            guard let data = snap?.data(), error == nil else {
                
                return
            }
            
            if error == nil {
                
                self.nameLBL.text = data["name"] as? String ?? ""
                self.phoneLBL.text = data["phone"] as? String ?? ""
                let url = data["image"] as? String ?? ""
                self.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholder"))
            }
        })
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func edit(_ sender: Any) {
        
        let obj = SelectImage()
        obj.VC = self
        obj.delegate = self
        obj.select()
    }
    
    func uploadProfileImage() -> Void {
        
        self.showSpinner(onView: self.view)
        var imageData:Data = selectedImage!.pngData()! as Data
        if imageData.count <= 0 {
            
            imageData = selectedImage!.jpegData(compressionQuality: 1.0)! as Data
        }
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let name = "\(id).png"
        
        let storageRef = Storage.storage().reference().child("uploads\(name)")
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if error != nil {
                print("error")
                
            } else {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                
                storageRef.downloadURL(completion: { (url, error) in
                    
                    let str = url?.absoluteString
                    let fileUrl = URL(string: str ?? "")
                    changeRequest?.photoURL = fileUrl
                    changeRequest?.commitChanges { (error) in
                        
                        self.updateProfileImageInDB(url: str ?? "")
                    }
                })
            }
        }
    }
    
    func updateProfileImageInDB(url: String) -> Void {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let db = Firestore.firestore()
        
        
        let path = "Users"
        let docRef = db.collection(path).document(id)
        docRef.updateData(["image": url]) { err in
            if let err = err {
                
                self.removeSpinner()
                self.showAlert(str: err.localizedDescription)
            } else {
                
                self.removeSpinner()
                self.showAlert(str: "Profile picture updated successfully")
            }
        }
    }
    
    
    @IBAction func password(_ sender: Any) {
        
        self.performSegue(withIdentifier: "password", sender: self)
    }
    
    func showAlert(str: String) -> Void {
        
        
        // create the alert
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            do {
                try Auth.auth().signOut()
            } catch {}
            
            
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = true
            
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
            self.navigationController!.pushViewController(obj, animated: true)
        })
        
        let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}


extension ProfileViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage

        if let image = image {
            
            self.imgView.image = image
            self.selectedImage = image
        }
        
        self.uploadProfileImage()
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
