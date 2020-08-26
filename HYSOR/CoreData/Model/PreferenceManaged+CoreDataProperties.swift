//
//  PreferenceManaged+CoreDataProperties.swift
//  
//
//  Created by Dayson Dong on 2020-08-18.
//
//

import Foundation
import CoreData


extension PreferenceManaged {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PreferenceManaged> {
        return NSFetchRequest<PreferenceManaged>(entityName: "PreferenceManaged")
    }

    @NSManaged public var isRequired: Bool
    @NSManaged public var maxItemQuantity: Int64
    @NSManaged public var maxPick: Int64
    @NSManaged public var name: String?
    @NSManaged public var uid: String?
    @NSManaged public var preferenceItems: NSSet?
    @NSManaged public var meal: NSSet?

}

// MARK: Generated accessors for preferenceItems
extension PreferenceManaged {

    @objc(addPreferenceItemsObject:)
    @NSManaged public func addToPreferenceItems(_ value: PreferenceItemManaged)

    @objc(removePreferenceItemsObject:)
    @NSManaged public func removeFromPreferenceItems(_ value: PreferenceItemManaged)

    @objc(addPreferenceItems:)
    @NSManaged public func addToPreferenceItems(_ values: NSSet)

    @objc(removePreferenceItems:)
    @NSManaged public func removeFromPreferenceItems(_ values: NSSet)

}

// MARK: Generated accessors for meal
extension PreferenceManaged {

    @objc(addMealObject:)
    @NSManaged public func addToMeal(_ value: MealManaged)

    @objc(removeMealObject:)
    @NSManaged public func removeFromMeal(_ value: MealManaged)

    @objc(addMeal:)
    @NSManaged public func addToMeal(_ values: NSSet)

    @objc(removeMeal:)
    @NSManaged public func removeFromMeal(_ values: NSSet)

}
