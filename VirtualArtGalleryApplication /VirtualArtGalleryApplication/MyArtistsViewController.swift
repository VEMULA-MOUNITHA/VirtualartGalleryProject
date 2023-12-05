//
//  MyArtistsViewController.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 02/12/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import AnimatedGradientView

class MyArtistsViewController: UIViewController {

    @IBOutlet weak var dataCV: UICollectionView!
    
    let db = Firestore.firestore()
    var artistsList: [ArtistModel] = []
    
    var selectedArtist: ArtistModel?
    @IBOutlet var noRecordLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataCV.backgroundColor = .clear
        //dataCV.delegate = self
        //dataCV.delegate = self
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        getArtists()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "paintings" {
            
            let vc = segue.destination as! MyArtistPaintingsViewController
            vc.artist_id = self.selectedArtist?.id ?? ""
            vc.artist_name = self.selectedArtist?.name ?? ""
        }
    }

    @IBAction func addBtn(_ sender: Any) {
        
        self.performSegue(withIdentifier: "add", sender: self)
    }
    
    func getArtists() -> Void {
        
        let path = "Artists"
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let docRef = db.collection(path)
            .whereField("user_id", isEqualTo: id)
        
        self.showSpinner(onView: self.view)
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                
                self.removeSpinner()
            } else {
                
                self.removeSpinner()
                
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
                
                self.noRecordLbl.isHidden = true
                self.dataCV.isHidden = false
                if self.artistsList.count == 0 {
                    
                    self.noRecordLbl.isHidden = false
                    self.dataCV.isHidden = true
                }
                
                self.dataCV.reloadData()
            }
        }
    }
    
    
    @objc func removeClicked(sender: UIButton) -> Void {
        
        let tag = sender.tag
        let artist = self.artistsList[tag]
        let id = artist.id ?? ""
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this Artist?", preferredStyle: .alert)
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
        
        let docRef = db.collection("Artists").document(id)
        docRef.delete() { err in
            if let err = err {
                
                self.showAlert(str: err.localizedDescription)
            } else {
                
                self.getArtists()
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
}


extension MyArtistsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
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
        
        let cell : ArtistCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "artist1", for: indexPath) as! ArtistCVC
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.contantView.layer.cornerRadius = 8
        cell.contantView.clipsToBounds = true
        
        
        let artist = self.artistsList[indexPath.item]
        cell.nameLbl.text = artist.name ?? ""
        
        let url = artist.image ?? ""
        cell.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
        

        cell.btn.tag = indexPath.item
        cell.btn.addTarget(self, action: #selector(removeClicked(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedArtist = self.artistsList[indexPath.item]
        self.performSegue(withIdentifier: "paintings", sender: self)
    }
}
