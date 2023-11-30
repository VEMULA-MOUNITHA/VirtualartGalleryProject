//
//  ChangePasswordViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 03/11/2023.
//

import UIKit
import FirebaseAuth

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var newPasswordTF: UITextField!
    
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    

    @IBAction func save(_ sender: Any) {
        
        if passwordTF.text == "" {
            
            self.showAlert(str: "Please enter password")
        }else if newPasswordTF.text == "" {
            
            self.showAlert(str: "Please enter new password")
        }else if confirmPasswordTF.text == "" {
            
            self.showAlert(str: "Please confirm new password")
        }else {
            
            
            if newPasswordTF.text != confirmPasswordTF.text {
                
                self.showAlert(str: "Password mismatched.")
            }else {
                
                self.showSpinner(onView: self.view)
                Auth.auth().currentUser?.updatePassword(to: newPasswordTF.text!) { (error) in
                    
                    self.removeSpinner()
                    if error != nil {
                        
                        self.showAlert(str: "Relogin")
                    }else {
                        
                        let title = "Password updated successfully"
                        let alert = UIAlertController(title: "Success", message: title, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
                            
                            self.navigationController?.popViewController(animated: true)
                        })
                        alert.addAction(ok)
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true)
                        })
                    }
                }
                
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
