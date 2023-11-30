//
//  LoginViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 01/11/2023.
//

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController {

    
    
    
    
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
    }


    @IBAction func login(_ sender: Any) {
        
        if emailTF.text == "" {
            
            self.showAlert(str: "Please enter email")
        }else if passwordTF.text == "" {
            
            self.showAlert(str: "Please enter password")
        }else {
            
            self.showSpinner(onView: self.view)
            Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) { [weak self] authResult, error in
              guard let strongSelf = self else { return }
                print(strongSelf)
              
                self?.navigationController?.navigationBar.isHidden = true
                
                let obj = self?.storyboard?.instantiateViewController(withIdentifier: "myTabBar") as! UITabBarController
                self?.navigationController!.pushViewController(obj, animated: true)
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
    
}

