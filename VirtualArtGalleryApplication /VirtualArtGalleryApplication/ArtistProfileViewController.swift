//
//  ArtistProfileViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 03/11/2023.
//

import UIKit
import SDWebImage
import AnimatedGradientView

class ArtistProfileViewController: UIViewController {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    
    @IBOutlet var phoneTL: UILabel!
    @IBOutlet var phoneLbl: UILabel!
    
    @IBOutlet var descriptionLbl: UILabel!
    
    
    var artist: ArtistModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.title = "Artist Profile"
        
        let url = artist?.image ?? ""
        imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
        
        nameLbl.text = artist?.name ?? ""
        descriptionLbl.text = artist?.description ?? ""
        let phone = artist?.phone ?? ""
        phoneLbl.text = phone
        
        if phone == "" {
            
            phoneTL.isHidden = true
            phoneLbl.isHidden = true
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
