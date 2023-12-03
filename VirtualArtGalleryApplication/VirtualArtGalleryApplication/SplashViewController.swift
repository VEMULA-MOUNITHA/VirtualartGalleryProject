//
//  SplashViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 01/11/2023.
//

import UIKit
import FirebaseAuth
class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            
            if Auth.auth().currentUser == nil {
                
                self.performSegue(withIdentifier: "welcome", sender: self)
            }else {
                
                self.navigationController?.navigationBar.isHidden = true
                
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "myTabBar") as! UITabBarController
                self.navigationController!.pushViewController(obj, animated: true)
            }
        }
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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
