//
//  MyArtistPaintingsViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula  on 02/12/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AnimatedGradientView

class MyArtistPaintingsViewController: UIViewController {

    @IBOutlet var noRecordLbl: UILabel!
    let db = Firestore.firestore()
    var artist: ArtistModel?
    
    var artist_id = ""
    var artist_name = ""
    
    @IBOutlet weak var dataCV: UICollectionView!
    
    var artistGalleryList: [ArtistGalleryModel] = []
    var selectedGallery: ArtistGalleryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = artist_name
        self.tabBarController?.tabBar.isHidden = true
        
        dataCV.backgroundColor = .clear
        dataCV.delegate = self
        dataCV.dataSource = self
        // Do any additional setup after loading the view.
        
//        let dispatchGroup = DispatchGroup()
//        dispatchGroup.enter()
        self.getArtistGallery {
            
            //dispatchGroup.leave()
            
//            self.getArtistDetails {
//                //dispatchGroup.leave()
//            }
        }
        
        //dispatchGroup.enter()
//        self.getArtistDetails {
//            dispatchGroup.leave()
//        }
        
//        dispatchGroup.notify(queue: .main) {
//
//        }
        
        let animatedGradient = AnimatedGradientView(frame: view.bounds)
        animatedGradient.direction = .up
        animatedGradient.animationValues = [(colors: ["#2BC0E4", "#EAECC6"], .up, .axial),
        (colors: ["#833ab4", "#fd1d1d", "#fcb045"], .right, .axial),
        (colors: ["#003973", "#E5E5BE"], .down, .axial),
        (colors: ["#1E9600", "#FFF200", "#FF0000"], .left, .axial)]
        //self.view.layer.insertSublayer(animatedGradient.layer, at: 0)
        self.view.insertSubview(animatedGradient, at: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    @IBAction func add(_ sender: Any) {
        
        self.performSegue(withIdentifier: "painting", sender: self)
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
                
                self.noRecordLbl.isHidden = true
                self.dataCV.isHidden = false
                if self.artistGalleryList.count == 0 {
                    
                    self.noRecordLbl.isHidden = false
                    self.dataCV.isHidden = true
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
        
        
        if segue.identifier == "painting" {
            
            let vc = segue.destination as! AddPaintingViewController
            vc.delegte = self
            vc.artist_id = self.artist_id
            vc.painting_id = self.selectedGallery?.id ?? ""
        }
    }
    
    @objc func removeClicked(sender: UIButton) -> Void {
        
        let tag = sender.tag
        let artist = self.artistGalleryList[tag]
        let id = artist.id ?? ""
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this Painting?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.delete(id: id)
        })
        
        let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        
    }
    
    
    func delete(id: String) -> Void {
        
        let db = Firestore.firestore()
        
        let docRef = db.collection("Paintings").document(id)
        docRef.delete() { err in
            if let err = err {
                
                self.showAlert(str: err.localizedDescription)
            } else {
                
                self.getArtistGallery {
                    
                }
            }
        }
    }
    
    func showAlert(str: String) -> Void {
        
        
        // create the alert
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
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


extension MyArtistPaintingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        
        let cell : ArtistGalleryCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "gallery1", for: indexPath) as! ArtistGalleryCVC
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.contantView.layer.cornerRadius = 8
        cell.contantView.clipsToBounds = true
        
        let painting = self.artistGalleryList[indexPath.item]
        let url = painting.image ?? ""
        cell.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
        
       
        cell.btn.tag = indexPath.item
        cell.btn.addTarget(self, action: #selector(removeClicked(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        self.selectedGallery = self.artistGalleryList[indexPath.item]
//        self.performSegue(withIdentifier: "painting", sender: self)
    }
}


extension MyArtistPaintingsViewController: addPaintingDelegate {
    
    func didAdded() {
        
        self.getArtistGallery {
            
        }
    }
}
