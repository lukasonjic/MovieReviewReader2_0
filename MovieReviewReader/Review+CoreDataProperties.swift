//
//  Review+CoreDataProperties.swift
//  
//
//  Created by Pet Minuta on 15/03/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Review {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Review> {
        return NSFetchRequest<Review>(entityName: "Review");
    }

    @NSManaged public var imageURL: String?
    @NSManaged public var linkText: String?
    @NSManaged public var linkURL: String?
    @NSManaged public var movieTitle: String?
    @NSManaged public var reviewDate: String?
    @NSManaged public var reviewer: String?
    @NSManaged public var reviewTitle: String?
    @NSManaged public var summary: String?
    @NSManaged public var comment: Comment?

}
