//
//  Extensions.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 08/11/2023.
//

import Foundation
import UIKit


//MARK: Show Spinner
var vSpinner : UIView?
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
        
        var x = self.view.frame.size.width/2
        x -= 50
        
        var y = self.view.frame.size.height/2
        y -= 50
        
        let spinnerView1 = UIView.init(frame: CGRect(x: x, y: y, width: 100, height: 100))
        spinnerView1.backgroundColor = .black
        spinnerView1.layer.cornerRadius = 16
        
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.frame = CGRect(x: 25, y: 16, width: 50, height: 50)
        spinnerView1.addSubview(ai)
        
        let textLabel = UILabel.init(frame: CGRect(x: 5, y: 60, width: 90, height: 40))
        textLabel.backgroundColor = .clear
        textLabel.textColor = .white
        spinnerView1.layer.cornerRadius = 16
        textLabel.text = "Please Wait"
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        textLabel.font = UIFont.boldSystemFont(ofSize: 13)
        spinnerView1.addSubview(textLabel)
        
        DispatchQueue.main.async {
            spinnerView.addSubview(spinnerView1)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
