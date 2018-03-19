//
//  Service.swift
//  VisualTourist
//
//  Created by Fabiola Ramirez on 3/11/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import Foundation


class Service {
    
    
    static func getImages(lat: Double, long: Double, success: @escaping(_ pictures: [Picture]) -> (), failure: @escaping(_ errorResponse: ErrorResponse)-> ()) {
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.BaseUrl)?method=\(Constants.Search)&format=\(Constants.Format)&api_key=\(Constants.ApiKey)&lat=\(lat)&lon=\(long)&radius=\(Constants.Range)")!)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                
               
                let e = ErrorResponse(message: "Request error: \(String(describing: error))")
                failure(e)
                return
            }
            
            let range = Range(uncheckedBounds: (14, data!.count - 1))
            let newData = data?.subdata(in: range)
            
            if let json = try? JSONSerialization.jsonObject(with: newData!) as? [String:Any],
                let photosMeta = json?["photos"] as? [String:Any],
                let photos = photosMeta["photo"] as? [Any] {
                
                var pictures:[Picture] = []
                
                for photo in photos {
                    
                    if let pictureFlick = photo as? [String:Any],
                        let id = pictureFlick["id"] as? String,
                        let secret = pictureFlick["secret"] as? String,
                        let server = pictureFlick["server"] as? String,
                        let farm = pictureFlick["farm"] as? Int {
                        let picture = Picture(id: id, secret: secret, server: server, farm: farm)
                        pictures.append(picture)
                    }
                }
                
                success(pictures)
                
            } else {
                let e = ErrorResponse(message: "Key did not find")
                failure(e)
            }
        }
        
        task.resume()
    }
    
    
}
