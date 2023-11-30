//
//  ArtistProfileViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 03/11/2023.
//

import UIKit
import SDWebImage

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
