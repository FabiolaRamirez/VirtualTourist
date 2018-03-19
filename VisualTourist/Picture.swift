//
//  Picture.swift
//  VisualTourist
//
//  Created by Fabiola Ramirez on 3/13/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import Foundation

class Picture {
    
    let id:String
    let secret:String
    let server:String
    let farm:Int
    
    init(id: String, secret: String, server: String, farm: Int) {
        
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    }
    
    func imageURLString() -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
    
}

