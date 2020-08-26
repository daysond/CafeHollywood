//
//  MenuManaged+CoreDataProperties.swift
//  
//
//  Created by Dayson Dong on 2020-08-25.
//
//

import Foundation
import CoreData


extension MenuManaged {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MenuManaged> {
        return NSFetchRequest<MenuManaged>(entityName: "MenuManaged")
    }

    @NSManaged public var imageURL: String?
    @NSManaged public var mealsInUID: String?
    @NSManaged public var menuDetail: String?
    @NSManaged public var menuTitle: String?
    @NSManaged public var menuType: String?
    @NSManaged public var uid: String?

}
