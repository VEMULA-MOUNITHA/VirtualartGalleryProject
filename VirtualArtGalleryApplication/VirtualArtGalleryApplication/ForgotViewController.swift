//
//  ForgotViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 01/11/2023.
//

import UIKit
import FirebaseAuth

class ForgotViewController: UIViewController {

    @IBOutlet var emailTF: UITextField!
    
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
    @IBAction func send(_ sender: Any) {
        
        if emailTF.text == "" {
            
            self.showAlert(str: "Please enter email")
            
        }else {
            
            self.showSpinner(onView: self.view)
            Auth.auth().sendPasswordReset(withEmail: emailTF.text!) { error in
                
                self.removeSpinner()
                if let error = error {
                    
                    self.showAlert(str: error.localizedDescription )
                    return
                }
                
                self.showAlert(str: "OTP sent to \(self.emailTF.text!)" )
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
