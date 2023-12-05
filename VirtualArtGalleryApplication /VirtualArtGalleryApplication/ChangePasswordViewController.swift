//
//  ChangePasswordViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 03/11/2023.
//

import UIKit
import FirebaseAuth
import AnimatedGradientView

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var newPasswordTF: UITextField!
    
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
        
        let animatedGradient = AnimatedGradientView(frame: view.bounds)
        animatedGradient.direction = .up
        animatedGradient.animationValues = [(colors: ["#2BC0E4", "#EAECC6"], .up, .axial),
        (colors: ["#833ab4", "#fd1d1d", "#fcb045"], .right, .axial),
        (colors: ["#003973", "#E5E5BE"], .down, .axial),
        (colors: ["#1E9600", "#FFF200", "#FF0000"], .left, .axial)]
        //self.view.layer.insertSublayer(animatedGradient.layer, at: 0)
        self.view.insertSubview(animatedGradient, at: 0)
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
