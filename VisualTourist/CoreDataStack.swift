//
//  CoreDataStack.swift
//  VisualTourist
//
//  Created by Fabiola Ramirez on 3/18/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataStack {
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dataBaseURL: URL
    let context: NSManagedObjectContext
    
    init?(modelName: String) {
        
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find the model in the main Bundle")
            return nil
        }
        
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Unable to create the model")
            return nil
        }
        
        self.model = model
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        let fileManager = FileManager.default
        
        guard let fileUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to seach the file")
            return nil
        }
        
        self.dataBaseURL = fileUrl.appendingPathComponent("VirtualT.sqlite")
        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: true]
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dataBaseURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("Unable to add store")
        }
    }
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dataBaseURL, options: nil)
    }
    
}

internal extension CoreDataStack  {
    
    func dropAllData() throws {
        try coordinator.destroyPersistentStore(at: dataBaseURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dataBaseURL, options: nil)
    }
    
    func saveContext() throws {
        
        if context.hasChanges {
            
            try context.save()
        }
    }
    
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            
            do {
                try saveContext()
                print("Autosaving")
            } catch {
                print("Error While Autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
}


