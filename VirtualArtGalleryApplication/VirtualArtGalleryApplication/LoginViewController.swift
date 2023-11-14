//
//  LoginViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 01/11/2023.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
    }


    @IBAction func login(_ sender: Any) {
        
        self.navigationController?.navigationBar.isHidden = true
        
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "myTabBar") as! UITabBarController
        self.navigationController!.pushViewController(obj, animated: true)
    }
}

