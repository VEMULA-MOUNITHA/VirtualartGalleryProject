//
//  FavoritesViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 30/11/2023.
//

import UIKit
import CoreData
import AVKit

class FavoritesViewController: UIViewController {

    @IBOutlet var dataCV: UICollectionView!
    @IBOutlet var segment: UISegmentedControl!
    @IBOutlet var emptyLbl: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favArtistsLists: [Artists] = []
    var favArtistPaintingsLists: [Paintings] = []
    
    var selectedArtist: Artists?
    var selectedPainting: Paintings?
    
    var selectedTab = "artist"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        dataCV.delegate = self
        dataCV.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.getFavoriteArtists {
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.getFavoritePaintings {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
            self.dataCV.reloadData()
        }
        
    }
    
    //MARK: Favorites Artists
    func getFavoriteArtists(completion: @escaping () -> ()) {
        
        do {
            favArtistsLists = try context.fetch(Artists.fetchRequest())
            completion()
        } catch {
            
            print(error.localizedDescription)
            completion()
        }
    }
    
    //MARK: Favorites
    func getFavoritePaintings(completion: @escaping () -> ()) {
        
        do {
            favArtistPaintingsLists = try context.fetch(Paintings.fetchRequest())
            completion()
        } catch {
            
            print(error.localizedDescription)
            completion()
        }
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "artistGallery" {
            
            let vc = segue.destination as! ArtistGalleryViewController
            vc.artist_id = self.selectedArtist?.id ?? ""
            vc.artist_name = self.selectedArtist?.name ?? ""
        }else if segue.identifier == "details" {
            
            let vc = segue.destination as! GalleryDetailsViewController
            vc.artist_id = self.selectedPainting?.artist_id ?? ""
            vc.painting_id = self.selectedPainting?.id ?? ""
        }
    }

    @IBAction func segments(_ sender: UISegmentedControl) {
        
        if segment.selectedSegmentIndex == 0 {
            
            selectedTab = "artist"
            self.emptyLbl.isHidden = true
            if self.favArtistsLists.count == 0 {
                
                self.emptyLbl.isHidden = false
            }
            
        }else {
            
            selectedTab = "painting"
            self.emptyLbl.isHidden = true
            if self.favArtistsLists.count == 0 {
                
                self.emptyLbl.isHidden = false
            }
        }
        
        self.dataCV.reloadData()
    }
    
    @objc func artistFavoriteClicked(sender: UIButton) -> Void {
        
        let tag = sender.tag
        let artist = self.favArtistsLists[tag]
        
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound(systemSoundID)
        
        self.context.delete(artist)
        do {
            
            self.getFavoriteArtists {
                
                self.dataCV.reloadData()
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    @objc func paintingFavoriteClicked(sender: UIButton) -> Void {
        
        let tag = sender.tag
        let artist = self.favArtistPaintingsLists[tag]
        
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound(systemSoundID)
        
        self.context.delete(artist)
        do {
            
            self.getFavoritePaintings {
                
                self.dataCV.reloadData()
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}


extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if selectedTab == "artist" {
            
            return self.favArtistsLists.count
        }
        
        return self.favArtistPaintingsLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.size.width / 2
        return CGSize(width: width - 12, height: width + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if selectedTab == "artist" {
            
            let cell : ArtistCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "artistFav", for: indexPath) as! ArtistCVC
            
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.contantView.layer.cornerRadius = 8
            cell.contantView.clipsToBounds = true
            
            
            let artist = self.favArtistsLists[indexPath.item]
            cell.nameLbl.text = artist.name ?? ""
            
            let url = artist.image ?? ""
            cell.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
            
            cell.btn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            cell.btn.tag = indexPath.item
            cell.btn.addTarget(self, action: #selector(artistFavoriteClicked(sender:)), for: .touchUpInside)
            
            return cell
            
        }else {
            
            let cell : ArtistGalleryCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryFav", for: indexPath) as! ArtistGalleryCVC
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.contantView.layer.cornerRadius = 8
            cell.contantView.clipsToBounds = true
            
            let painting = self.favArtistPaintingsLists[indexPath.item]
            let url = painting.image ?? ""
            cell.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
            
            cell.btn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            cell.btn.tag = indexPath.item
            cell.btn.addTarget(self, action: #selector(paintingFavoriteClicked(sender:)), for: .touchUpInside)
            
            return cell
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedTab == "artist" {
            
            let artist = favArtistsLists[indexPath.row]
            self.selectedArtist = artist
            
            self.performSegue(withIdentifier: "artistGallery", sender: self)
        }else {
            
            let paingint = favArtistPaintingsLists[indexPath.row]
            self.selectedPainting = paingint
            
            self.performSegue(withIdentifier: "details", sender: self)
        }
    }
}
