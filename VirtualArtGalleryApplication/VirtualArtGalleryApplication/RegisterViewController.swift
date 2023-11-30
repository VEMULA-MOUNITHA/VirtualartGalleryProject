//
//  RegisterViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 01/11/2023.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore


class RegisterViewController: UIViewController {

    let db = Firestore.firestore()
    
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var phoneTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var cPasswordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func register(_ sender: Any) {
        
        if nameTF.text == "" {
            
            self.showAlert(str: "Please enter name")
        }else if emailTF.text == "" {
            
            self.showAlert(str: "Please enter email")
        }else if phoneTF.text == "" {
            
            self.showAlert(str: "Please enter phone number")
        }else if passwordTF.text == "" {
            
            self.showAlert(str: "Please enter password")
        }else if cPasswordTF.text == "" {
            
            self.showAlert(str: "Please enter confirm password")
        }else {
            
            if passwordTF.text != cPasswordTF.text {
                
                self.showAlert(str: "Password not matched.")
            }else {
                
                self.showSpinner(onView: self.view)
                Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) { authResult, error in
                  
                    if error != nil {
                        
                        self.removeSpinner()
                        self.showAlert(str: error?.localizedDescription ?? "Error in saving user")
                    }else{
                        
                        let profile = authResult?.user.createProfileChangeRequest()
                        profile?.displayName = self.nameTF.text!
                        profile?.commitChanges(completion: { error in
                            if error != nil {
                                
                                self.removeSpinner()
                                self.showAlert(str: error?.localizedDescription ?? "Error in saving user")
                            }else{
                                
                                self.registerUser()
                            }
                        })
                    }
                }
                
            }
            
        }
    }
    
    
    func registerUser() -> Void {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let params = ["id": id,
                      "name": nameTF.text!,
                      "email": emailTF.text!,
                      "phone": self.phoneTF.text!]
        
        
        let path = String(format: "%@", "Users")
        let db = Firestore.firestore()
        
        db.collection(path).document(id).setData(params) { err in
            if let err = err {
                
                self.removeSpinner()
                self.showAlert(str: err.localizedDescription)
                
            } else {
                
                self.loginUser()
            }
        }
    }
    
    
    func loginUser() -> Void {
        
        Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            print(strongSelf)
          
            self?.removeSpinner()
            
            self?.navigationController?.navigationBar.isHidden = true
            
            let obj = self?.storyboard?.instantiateViewController(withIdentifier: "myTabBar") as! UITabBarController
            self?.navigationController!.pushViewController(obj, animated: true)
            
        }
    }
    
    
    
    @IBAction func login(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlert(str: String) -> Void {
        
        
        // create the alert
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
