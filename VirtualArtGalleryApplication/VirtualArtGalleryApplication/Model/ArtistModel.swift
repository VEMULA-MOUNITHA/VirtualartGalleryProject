//
//  ArtistModel.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 08/11/2023.
//

import Foundation


struct ArtistModel: Codable {
    
    var id: String?
    var name: String?
    var email: String?
    var phone: String?
    var image: String?
    var description: String?
    
    init() {}
}
