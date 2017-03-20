//
//  Comment+CoreDataProperties.swift
//  
//
//  Created by Pet Minuta on 15/03/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment");
    }

    @NSManaged public var comment: String?
    @NSManaged public var review: Review?

}
