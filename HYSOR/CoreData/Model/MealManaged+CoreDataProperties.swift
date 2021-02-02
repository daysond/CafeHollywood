//
//  MealManaged+CoreDataProperties.swift
//  
//
//  Created by Dayson Dong on 2020-09-06.
//
//

import Foundation
import CoreData


extension MealManaged {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealManaged> {
        return NSFetchRequest<MealManaged>(entityName: "MealManaged")
    }

    @NSManaged public var comboMealTag: NSNumber?
    @NSManaged public var comboType: NSNumber?
    @NSManaged public var detail: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var name: String?
    @NSManaged public var price: NSDecimalNumber?
    @NSManaged public var uid: String?
    @NSManaged public var mealDescription: String?
    @NSManaged public var preferences: NSSet?
    @NSManaged public var isBOGO: Bool

}

// MARK: Generated accessors for preferences
extension MealManaged {

    @objc(addPreferencesObject:)
    @NSManaged public func addToPreferences(_ value: PreferenceManaged)

    @objc(removePreferencesObject:)
    @NSManaged public func removeFromPreferences(_ value: PreferenceManaged)

    @objc(addPreferences:)
    @NSManaged public func addToPreferences(_ values: NSSet)

    @objc(removePreferences:)
    @NSManaged public func removeFromPreferences(_ values: NSSet)

}
