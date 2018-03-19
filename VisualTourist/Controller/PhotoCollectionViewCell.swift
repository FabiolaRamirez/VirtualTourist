//
//  PhotoCollectionViewCell.swift
//  VisualTourist
//
//  Created by Fabiola Ramirez on 3/18/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //Get Photos
    func initWithPhoto(_ photo: Photo) {
        
        if photo.data != nil {
            DispatchQueue.main.async {
                self.photoImageView.image = UIImage(data: photo.data! as Data)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidesWhenStopped = true
            }
        } else {
            downloadImage(photo)
        }
    }
    
    //Download Images
    func downloadImage(_ photo: Photo) {
        URLSession.shared.dataTask(with: URL(string: photo.url!)!) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.photoImageView.image = UIImage(data: data! as Data)
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidesWhenStopped = true
                    self.saveImageDataToCoreData(photo: photo, data: data! as NSData)
                }
            }
            }
            .resume()
    }
    
    //Save Images
    func saveImageDataToCoreData(photo: Photo, data: NSData) {
        do {
            photo.data = data
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            try stack.saveContext()
        } catch {
            print("Saving photo data failed")
        }
    }
    
    
    
    
}
