//
//  GalleryDetailsViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 03/11/2023.
//

import UIKit
import SDWebImage
import CoreData
import FirebaseFirestore

class GalleryDetailsViewController: UIViewController {
    
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    
    @IBOutlet var profileBtn: UIBarButtonItem!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favPaintingsLists: [Paintings] = []
    
    var artist: ArtistModel?
    var gallery: ArtistGalleryModel?
    
    var fullScreenView = UIView()
    
    let db = Firestore.firestore()
    
    var artist_id = ""
    var painting_id = ""
    var artist_name = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = artist_name
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.getPaintingDetails {
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.getArtistDetails {
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
            self.setData()
            self.addFullScreenImage()
        }
        
    }
    
    func setData() -> Void {
        
        self.titleLbl.text = gallery?.name ?? ""
        let url = gallery?.image ?? ""
        imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
        
        priceLbl.text = String(format: "$%@", gallery?.price ?? "100")
        descriptionLbl.text = gallery?.description ?? ""
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTaped))
        self.imgView.isUserInteractionEnabled = true
        tapGesture.numberOfTapsRequired = 2
        self.imgView.addGestureRecognizer(tapGesture)
    }
    
    func getPaintingDetails(completion: @escaping () -> ()) {
        
        let path = "Paintings"
        
        let id = artist_id
        let pid = painting_id
        let docRef = db.collection(path)
            .whereField("artist_id", isEqualTo: id)
            .whereField("id", isEqualTo: pid)
        
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion()
            } else {
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    
                    var obj = ArtistGalleryModel()
                    obj.id = document.documentID
                    obj.artist_id = data["artist_id"] as? String ?? ""
                    obj.name = data["name"] as? String ?? ""
                    obj.image = data["image"] as? String ?? ""
                    obj.price = data["price"] as? String ?? ""
                    obj.description = data["description"] as? String ?? ""
                    
                    
                    self.gallery = obj
                    
                    
                }
                
                completion()
            }
        }
    }
    
    
    func getArtistDetails(completion: @escaping () -> ()) {
        
        let path = "Artists"
        
        let docRef = db.collection(path)
            .whereField("id", isEqualTo: artist_id)
        
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion()
            } else {
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    
                    var a = ArtistModel()
                    a.id = document.documentID
                    a.name = data["name"] as? String ?? ""
                    a.email = data["email"] as? String ?? ""
                    a.phone = data["phone"] as? String ?? ""
                    a.image = data["image"] as? String ?? ""
                    a.description = data["description"] as? String ?? ""
                    
                    
                    self.artist = a
                    
                }
                completion()
            }
        }
    }
    
    
    @objc func imageTaped(sender: UITapGestureRecognizer) {
        
        self.navigationItem.hidesBackButton = true
        self.profileBtn.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.fullScreenView.alpha = 1
        }) { (finished) in
            self.fullScreenView.isHidden = false
        }
        
    }
    
    @objc func fullScreenTaped(sender: UITapGestureRecognizer) {
        
        self.navigationItem.hidesBackButton = false
        self.profileBtn.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.fullScreenView.alpha = 0
        }) { (finished) in
            self.fullScreenView.isHidden = true
        }
        
    }
    
    func addFullScreenImage() -> Void {
        

        let url = gallery?.image ?? ""
        imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
        imageView.frame = view.bounds
        
        fullScreenView.frame = self.view.bounds
        fullScreenView.backgroundColor = UIColor.black
        
        fullScreenView.addSubview(imageView)
        view.addSubview(fullScreenView)
        self.view.bringSubviewToFront(fullScreenView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(fullScreenTaped(sender: )))
        self.fullScreenView.isUserInteractionEnabled = true
        tapGesture.numberOfTapsRequired = 2
        self.fullScreenView.addGestureRecognizer(tapGesture)
        
        fullScreenView.isHidden = true
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
