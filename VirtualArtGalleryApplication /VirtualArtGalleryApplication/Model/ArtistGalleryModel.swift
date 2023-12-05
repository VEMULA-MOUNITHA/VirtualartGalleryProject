//
//  ArtistGalleryModel.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 09/11/2023.
//

import Foundation

struct ArtistGalleryModel: Codable {
    
    var id: String?
    var artist_id: String?
    var name: String?
    var price: String?
    var image: String?
    var description: String?
    
    init() {}
}
