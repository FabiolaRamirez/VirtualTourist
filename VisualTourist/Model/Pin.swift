//
//  Pin.swift
//  VisualTourist
//
//  Created by Fabiola Ramirez on 3/18/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: entity, insertInto: context)
            self.latitude   = latitude
            self.longitude  = longitude
            
        } else {
            fatalError("Unable to find entity name")
        }
    }
    
}

extension Pin {
    
    //Fetch Pin
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photo: NSSet?
    
    
    //Access Photo
    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)
    
    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)
    
    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)
    
    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)
}

