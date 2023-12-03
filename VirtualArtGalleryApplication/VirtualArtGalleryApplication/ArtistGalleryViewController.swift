//
//  ArtistGalleryViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 03/11/2023.
//

import UIKit
import FirebaseFirestore
import SDWebImage
import CoreData
import AVKit

class ArtistGalleryViewController: UIViewController {

    @IBOutlet weak var dataCV: UICollectionView!
    
    let db = Firestore.firestore()
    var artist: ArtistModel?
    
    var artist_id = ""
    var artist_name = ""
    
    var artistGalleryList: [ArtistGalleryModel] = []
    var selectedGallery: ArtistGalleryModel?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favArtistPaintingsLists: [Paintings] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.title = artist_name
        self.tabBarController?.tabBar.isHidden = true
        
        
        dataCV.delegate = self
        dataCV.dataSource = self
        // Do any additional setup after loading the view.
        
        self.getFavoriteList()
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.getArtistGallery {
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.getArtistDetails {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
        }
        
    }
    
    //MARK: Favorites
    func getFavoriteList() -> Void {
        
        do {
            favArtistPaintingsLists = try context.fetch(Paintings.fetchRequest())
            self.dataCV.reloadData()
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    
    func getArtistGallery(completion: @escaping () -> ()) {
        
        let id = artist_id
        let docRef = db.collection("Paintings")
            .whereField("artist_id", isEqualTo: id)
        
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                
                completion()
            } else {
                
                self.artistGalleryList.removeAll()
                
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
                    
                    self.artistGalleryList.append(obj)
                }
                
                self.dataCV.reloadData()
                completion()
            }
        }
    }
    
    func getArtistDetails(completion: @escaping () -> ()) {
        
        let path = "Artists"
        
        let id = artist_id
        let docRef = db.collection(path)
            .whereField("id", isEqualTo: id)
        
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "details" {
            
            let vc = segue.destination as! GalleryDetailsViewController
            vc.artist_id = self.artist?.id ?? ""
            vc.painting_id = self.selectedGallery?.id ?? ""
        }
    }
    
    
    @objc func favoriteClicked(sender: UIButton) -> Void {
        
        let tag = sender.tag
        let painting = self.artistGalleryList[tag]
        
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound(systemSoundID)
        
        let painting_id = painting.id ?? ""
        if self.checkIsFavorite(id: painting_id) {
            
            if let index = self.favArtistPaintingsLists.firstIndex(where: { $0.id == painting_id }) {
                
                let fav = favArtistPaintingsLists[index]
                self.context.delete(fav)
                do {
                    
                    self.getFavoriteList()
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            
            
        }else {
            
            let fav = Paintings(context: self.context)
            fav.id = painting_id
            fav.name = painting.name ?? ""
            fav.image = painting.image ?? ""
            fav.artist_id = painting.artist_id ?? ""
            
            do {
                try context.save()
                self.getFavoriteList()
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func checkIsFavorite(id: String) -> Bool {
        
        if let _ = self.favArtistPaintingsLists.firstIndex(where: { $0.id == id }) {
            
            return true
        }else {
            
            return false
        }
    }
    

}


extension ArtistGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.artistGalleryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.size.width / 2
        return CGSize(width: width - 12, height: width + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : ArtistGalleryCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "gallery", for: indexPath) as! ArtistGalleryCVC
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.contantView.layer.cornerRadius = 8
        cell.contantView.clipsToBounds = true
        
        let painting = self.artistGalleryList[indexPath.item]
        let url = painting.image ?? ""
        cell.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
        
        let painting_id = painting.id ?? ""
        if self.checkIsFavorite(id: painting_id) {
            
            cell.btn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else {
            
            cell.btn.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        cell.btn.tag = indexPath.item
        cell.btn.addTarget(self, action: #selector(favoriteClicked(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedGallery = self.artistGalleryList[indexPath.item]
        self.performSegue(withIdentifier: "details", sender: self)
    }
}
