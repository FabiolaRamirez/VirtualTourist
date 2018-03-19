//
//  Photo.swift
//  VisualTourist
//
//  Created by Fabiola Ramirez on 3/18/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {
    
    convenience init(index:Int, url: String, data: NSData?, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.index = Int16(index)
            self.url = url
            self.data = data
            
        } else {
            fatalError("Unable to find entity name")
        }
    }
    
}

extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }
    
    @NSManaged public var data: NSData?
    @NSManaged public var url: String?
    @NSManaged public var index: Int16
    @NSManaged public var pin: Pin?
    
}
