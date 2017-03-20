//
//  DatabaseController.swift
//  MovieReviewReader
//
//  Created by Pet Minuta on 14/03/2017.
//  Copyright © 2017 Luka Sonjic. All rights reserved.
//

import Foundation
import CoreData

class DatabaseController {
    
    private init(){
        
    }
    
    class func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MovieReviewReader")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    class func saveContext(){
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    

}
