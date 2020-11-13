//
//  Preference.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-07.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation

protocol MealPreference {
    var isRequired: Bool { get }
    var name: String { get }
    var maxPick: Int { get }
}

class PreferenceCache {
    
    let preference: Preference
    init(_ preference: Preference) {
        self.preference = preference
    }
}


struct Preference: MealPreference {
    
    var uid: String
    
    var isRequired: Bool
    
    var name: String
    
    var maxPick: Int
    
    var maxItemQuantity: Int
    
    var preferenceItems: [PreferenceItem]
    
    var isSectionCollapsed: Bool
    
    init(uid: String, isRequired: Bool, name: String, maxPick: Int, preferenceItems: [PreferenceItem], maxItemQuantity: Int) {
        self.uid = uid
        self.isRequired = isRequired
        self.name = name
        self.maxPick = maxPick
        self.isSectionCollapsed = false
        self.preferenceItems = preferenceItems
        self.maxItemQuantity = maxItemQuantity
    }
    
    init?(managedObject: PreferenceManaged) {
        
        guard let uid = managedObject.uid, let name = managedObject.name else { return nil }
        
        let maxItemQuantity = managedObject.maxItemQuantity
        let isRequired = managedObject.isRequired
        let maxPick = managedObject.maxPick
        
        self.uid = uid
        self.isRequired = isRequired
        self.name = name
        self.maxPick = Int(maxPick)
        self.isSectionCollapsed = false
        self.maxItemQuantity = Int(maxItemQuantity)
        
        var items: [PreferenceItem] = []
        
        managedObject.preferenceItems?.forEach({ (itemManaged) in
            if let item = PreferenceItem(managedObject: itemManaged as! PreferenceItemManaged) {
                items.append(item)
            }
        })
        
        items.sort { $0.uid < $1.uid }
        
        self.preferenceItems = items
        
        
    }
    
}

struct PreferenceItem {
    
    var uid: String
    
    var name: String
    //    var detail: String?
    var itemDescription: String
    
    var price: Money?
    
    var isSelected: Bool
    
    var quantity: Int
    
    var comboTag: Int?
    
    init(name: String, price: Money?, uid: String, description: String) {
        self.uid = uid
        self.name = name
        self.price = price
        self.quantity = 1
        self.itemDescription = description
        self.isSelected = false
    }
    
    init?(managedObject: PreferenceItemManaged) {
        
        guard let uid = managedObject.uid, let name = managedObject.name, let itemDescription = managedObject.itemDescription else { return nil}
        
        self.uid = uid
        self.name = name
        self.quantity = 1
        self.isSelected = false
        self.itemDescription = itemDescription
        
        if let price = managedObject.price {
            self.price = Money(amt: price.decimalValue)
        }
        
        if let comboTag = managedObject.comboTag {
            self.comboTag = comboTag.intValue
        }
        
    }
    
}

extension Preference: JSONRepresentation {

    var representation: [String : Any] {
        
        var preferenceItemUID: [String] = []
        preferenceItems.forEach { (item) in
            preferenceItemUID.append(item.uid)
        }
        
        let rep: [String: Any] = [
            "uid": uid,
            "name": name,
            "isRequired": isRequired,
            "maxPick" : maxPick,
            "maxItemQuantity" : maxItemQuantity,
            "preferenceItems" : preferenceItemUID,
            
        ]

        return rep
    }
}

extension PreferenceItem: JSONRepresentation {
    
   var representation: [String : Any] {
        let rep: [String: Any] = [
            "uid": uid,
            "name": name,
            "price": price?.amount ?? "0",
            "isSelected" : isSelected,
            "quantity" : quantity,
        ]

        return rep
    }
}
