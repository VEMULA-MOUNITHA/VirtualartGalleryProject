//
//  GalleryDetailsViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 03/11/2023.
//

import UIKit
import SDWebImage
import CoreData

class GalleryDetailsViewController: UIViewController {
    
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favPaintingsLists: [Paintings] = []
    
    var artist: ArtistModel?
    var gallery: ArtistGalleryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = artist?.name ?? ""
        
        self.titleLbl.text = gallery?.name ?? ""
        let url = gallery?.image ?? ""
        imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
        
        priceLbl.text = String(format: "$%@", gallery?.price ?? "100")
        descriptionLbl.text = gallery?.description ?? ""
        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "profile" {
            
            let vc = segue.destination as! ArtistProfileViewController
            vc.artist = self.artist
        }
    }
    

    @IBAction func actorProfile(_ sender: Any) {
        
        self.performSegue(withIdentifier: "profile", sender: self)
    }
}
