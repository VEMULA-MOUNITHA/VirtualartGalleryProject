//
//  UserModel.swift
//  VirtualArtGalleryApplication
//
//  Created by Mounitha Vemula on 09/11/2023.
//

import Foundation

struct UserModel: Codable {
    
    var id: String?
    var name: String?
    var email: String?
    var phone: String?
    var image: String?
    
    init() {}
}
