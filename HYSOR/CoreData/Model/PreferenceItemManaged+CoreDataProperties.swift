//
//  PreferenceItemManaged+CoreDataProperties.swift
//  
//
//  Created by Dayson Dong on 2020-09-06.
//
//

import Foundation
import CoreData


extension PreferenceItemManaged {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PreferenceItemManaged> {
        return NSFetchRequest<PreferenceItemManaged>(entityName: "PreferenceItemManaged")
    }

    @NSManaged public var comboTag: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var price: NSDecimalNumber?
    @NSManaged public var uid: String?
    @NSManaged public var itemDescription: String?
    @NSManaged public var preference: NSSet?

}

// MARK: Generated accessors for preference
extension PreferenceItemManaged {

    @objc(addPreferenceObject:)
    @NSManaged public func addToPreference(_ value: PreferenceManaged)

    @objc(removePreferenceObject:)
    @NSManaged public func removeFromPreference(_ value: PreferenceManaged)

    @objc(addPreference:)
    @NSManaged public func addToPreference(_ values: NSSet)

    @objc(removePreference:)
    @NSManaged public func removeFromPreference(_ values: NSSet)

}
