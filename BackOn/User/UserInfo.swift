//
//  UserInfo.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import Foundation
import SwiftUI

class UserInfo {
    var photo: URL
    var name: String
    var surname: String
    var identity: String {
        return "\(name) \(surname)"
    }
    var email: String?
    var profilePic: Image?
    
    init(photo: URL, name: String, surname: String) {
        self.photo = photo
        self.name = name
        self.surname = surname
    }
    
//    Costruttore aggiuntivo utilizzato al momento dell'accesso con Google
    init(photo: URL, name: String, surname: String, email: String) {
        self.photo = photo
        self.name = name
        self.surname = surname
        self.email = email
    }

    init(photo: String, name: String, surname: String, email: String, url: URL) {
        self.photo = url
        self.name = name
        self.surname = surname
        self.email = email
        do {
            profilePic = try Image(uiImage: UIImage(data: Data(contentsOf: url))!)
        } catch {}
    }
}
