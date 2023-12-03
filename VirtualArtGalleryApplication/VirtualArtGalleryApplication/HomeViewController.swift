//
//  HomeViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 03/11/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SDWebImage
import CoreData
import AVKit


class HomeViewController: UIViewController {

    let db = Firestore.firestore()
    var artistsList: [ArtistModel] = []
    
    var selectedArtist: ArtistModel?
    
    @IBOutlet weak var dataCV: UICollectionView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favArtistsLists: [Artists] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        dataCV.delegate = self
        dataCV.dataSource = self
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: Favorites
    func getFavoriteList() -> Void {
        
        do {
            favArtistsLists = try context.fetch(Artists.fetchRequest())
            self.getArtists()
        } catch {
            
            print(error.localizedDescription)
            self.getArtists()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.getFavoriteList()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "artistGallery" {
            
            let vc = segue.destination as! ArtistGalleryViewController
            vc.artist_id = self.selectedArtist?.id ?? ""
            vc.artist_name = self.selectedArtist?.name ?? ""
        }
    }
    
    
    
    func getArtists() -> Void {
        
        let path = "Artists"
        
        let id = Auth.auth().currentUser?.uid ?? ""
        
        let docRef = db.collection(path)
            .whereField("user_id", isNotEqualTo: id)
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                self.artistsList.removeAll()
                
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
                    
                    
                    self.artistsList.append(a)
                    
                    
                }
                
                self.dataCV.reloadData()
            }
        }
    }
    
    
    @objc func favoriteClicked(sender: UIButton) -> Void {
        
        let tag = sender.tag
        let artist = self.artistsList[tag]
        
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound(systemSoundID)
        
        let artist_id = artist.id ?? ""
        if self.checkIsFavorite(artistID: artist_id) {
            
            if let index = self.favArtistsLists.firstIndex(where: { $0.id == artist_id }) {
                
                let fav = favArtistsLists[index]
                self.context.delete(fav)
                do {
                    
                    self.getFavoriteList()
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            
            
        }else {
            
            let fav = Artists(context: self.context)
            fav.id = artist_id
            fav.name = artist.name ?? ""
            fav.image = artist.image ?? ""
            
            do {
                try context.save()
                self.getFavoriteList()
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func checkIsFavorite(artistID: String) -> Bool {
        
        if let _ = self.favArtistsLists.firstIndex(where: { $0.id == artistID }) {
            
            return true
        }else {
            
            return false
        }
    }
    
}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.artistsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.size.width / 2
        return CGSize(width: width - 12, height: width + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : ArtistCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "artist", for: indexPath) as! ArtistCVC
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.contantView.layer.cornerRadius = 8
        cell.contantView.clipsToBounds = true
        
        
        let artist = self.artistsList[indexPath.item]
        cell.nameLbl.text = artist.name ?? ""
        
        let url = artist.image ?? ""
        cell.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
        
        let artist_id = artist.id ?? ""
        if self.checkIsFavorite(artistID: artist_id) {
            
            cell.btn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else {
            
            cell.btn.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        cell.btn.tag = indexPath.item
        cell.btn.addTarget(self, action: #selector(favoriteClicked(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedArtist = self.artistsList[indexPath.item]
        self.performSegue(withIdentifier: "artistGallery", sender: self)
    }
}
