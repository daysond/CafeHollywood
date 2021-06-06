//
//  Food.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-12.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation

enum ComboType: Int {
 
    case drink = 0
    case wing = 1
    
    var deductionAmount: Decimal {
        
        switch self {
        case .drink:
            if let dcr = userDefaults.value(forKey: Key.drinkCredit) as? Int {
                return Decimal(dcr/100)
            }
            return Decimal(1.5)
        case .wing:
            if let wcr = userDefaults.value(forKey: Key.wingCredit) as? Int {
                return Decimal(wcr/100)
            }
            return Decimal(9.96)
        }
    }
    
}

class MealCache {
    
    let meal: Meal
    init(_ meal: Meal) {
        self.meal = meal
    }
}



struct Meal {
    
    let uid: String
    let name: String
    let price: Decimal
    let details: String?
    let imageURL: String?
    var preferences: [Preference]?
    var quantity: Int
    var instruction: String?
    let mealDescription: String
    
    var isFavourite: Bool {
        return APPSetting.favouriteList.contains(uid)
    }
    
    var isSelected: Bool = false
    
    var isBOGO: Bool = false
    
    var comboType: ComboType?
    
    var isModificationRequired: Bool {
        if preferences == nil {
            return false
        } else {
            
            var isRequired = false
            
            preferences?.forEach({ (preference) in
                if preference.isRequired {
                    for item in preference.preferenceItems {
                        
                        if item.isSelected == true {
                            isRequired = false
                            break
                        } else {
                            isRequired = true
                        }
                    }
                }
            })
            
            return isRequired
            
        }
    }
    
    private var comboMealTag: Int?
    
    var comboTag: Int? {
        if comboMealTag != nil {
            return comboMealTag
        } else {
            
            guard let preferences = preferences else { return nil}
            
            for preference in preferences {
                if preference.isRequired {
                    for item in preference.preferenceItems {
                        if item.isSelected && item.comboTag != nil {
                            return item.comboTag!
                        }
                    }
                }
            }
            return nil
        }
    }
    
    var addonPirce: Money {
           guard let preferences = preferences else { return Money(amt: 0.0) }
           var total = Money(amt: 0.0)
           preferences.forEach { (preference) in
               preference.preferenceItems.forEach { (item) in
                   if item.isSelected && item.price != nil {
                       total = total + item.price! * Float(item.quantity)
                   }
               }
           }
           
           return total
       }
    
    var totalPrice: Money {
        
        return (addonPirce + Money(amt: price)) * Float(quantity)
        
//        switch isBOGO {
//        case false:
//            return (addonPirce + Money(amt: price)) * Float(quantity)
//        default:
//            let q = quantity % 2 == 0 ? quantity / 2 : (quantity/2) + 1
//            return (addonPirce + Money(amt: price)) * Float(q)
//        }
          
       }
    
    var addOnInfo: String {
        var addOnDetails: String = ""
        
        if preferences == nil {
            return addOnDetails
        } else {
            preferences!.forEach { (preference) in
                preference.preferenceItems.forEach { (item) in
                    if item.isSelected == true {
                        
                        addOnDetails = item.quantity == 1 ? "\(addOnDetails)\(item.name)" : "\(addOnDetails)\(item.quantity) \(item.name)"
                        
                        addOnDetails = item.price == nil ? "\(addOnDetails)\n" : "\(addOnDetails) ($\((item.price! * Float(item.quantity) ).amount.stringRepresentation))\n"
                    }
                }
            }
            
            return String(addOnDetails.dropLast())
        }
    }
    
    var addOnDescription: String {
        var addOnDetails: String = ""
        
        if preferences == nil {
            return addOnDetails
        } else {
            preferences!.forEach { (preference) in
                preference.preferenceItems.forEach { (item) in
                    if item.isSelected == true {
                        
                        addOnDetails = item.quantity == 1 ? "\(addOnDetails)\(item.itemDescription)" : "\(addOnDetails)\(item.quantity) \(item.itemDescription)"
                        
                        addOnDetails = item.price == nil ? "\(addOnDetails)\n" : "\(addOnDetails) ($\((item.price! * Float(item.quantity) ).amount.stringRepresentation))\n"
                    }
                }
            }
            
            return String(addOnDetails.dropLast())
        }
    }
    
    
    init(uid: String, name: String, price: Decimal, details: String?, imageURL: String?, preferences: [Preference]?, comboMealTag: Int?, description: String) {
        
        self.name = name
        self.price = price
        self.details = details
        self.imageURL = imageURL
        self.uid = uid
        self.preferences = preferences
        self.quantity = 1
        self.comboMealTag = comboMealTag
        self.mealDescription = description
    }
    
    init?(managedObject: MealManaged) {
        
        guard let name = managedObject.name, let price = managedObject.price, let uid = managedObject.uid, let mealDescription = managedObject.mealDescription else { return nil }
        
        self.name = name
        self.price = price.decimalValue
        self.uid = uid
        self.details = managedObject.detail
        self.imageURL = managedObject.imageURL
        self.comboMealTag = managedObject.comboMealTag?.intValue
        self.mealDescription = mealDescription
        if let type = managedObject.comboType {
            self.comboType = ComboType(rawValue: type.intValue)
        }
       
        
        var preferences: [Preference] = []
        
        managedObject.preferences?.forEach({ (preferenceManaged) in
            if let pref = Preference(managedObject: preferenceManaged as! PreferenceManaged) {
                preferences.append(pref)
            }
        })
        
        preferences.sort { (p1, p2) -> Bool in
            return p1.isRequired
        }
        
        self.preferences = preferences
        
        self.quantity = 1
        
        self.isBOGO = managedObject.isBOGO
        
    }
    
    var preferencesInJSON: [String: Any] {
        
        var data = [String: Any]()
        
        var preferencesInfo = [String: Any]()
        
        if let instruction = instruction {
            data["instruction"] = instruction
        }
        
        if preferences != nil {
            
            preferences!.forEach { (preference) in
                var selectedItems: [[String: Int]] = []
                preference.preferenceItems.forEach { (item) in
                    if item.isSelected == true {
                        selectedItems.append([item.uid : item.quantity])
                    }
                }
                
                if selectedItems.count > 0 {
                    preferencesInfo[preference.uid] = selectedItems
                }
                
            }
        }
        
        data["preferences"] = preferencesInfo

        return data
        
    }
    
    mutating func recoverPreferenceState() {
        
        let userDefaults = UserDefaults.standard
        
        guard let data = userDefaults.object(forKey: self.uid) as? [String: Any] else { return }
        
        if let instruction = data["instruction"] as? String {
            self.instruction = instruction
        }
        
        if let preferences = data["preferences"] as? [String: [[String:Int]]] {
            
            preferences.forEach { (key, infos) in
                
                if self.preferences != nil {
                    
                    for (pIndex, preference) in self.preferences!.enumerated() {
                        
                        if preference.uid == key{
                            
                            for info in infos {
                                
                                for (iIndex, item) in preference.preferenceItems.enumerated() {
                                    
                                    if info[item.uid] != nil {
                                        self.preferences![pIndex].preferenceItems[iIndex].isSelected = true
                                        self.preferences![pIndex].preferenceItems[iIndex].quantity = info[item.uid]!
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    


    
}

extension Meal: JSONRepresentation {
    
    var representation: [String : Any] {
        
        var rep: [String: Any] = [
            "uid": uid,
            "name": name,
            "instruction" : instruction ?? "",
            "quantity" : quantity,
            "totalPrice" : totalPrice.amount,
            "addOnInfo" : addOnInfo,
            "description": mealDescription,
            "addOnDescription": addOnDescription,
            
        ]
        
        if comboTag != nil {
            rep["comboTag"] = comboTag
        }
        
        if comboType != nil {
            rep["comboType"] = comboType?.rawValue
        }
        
        return rep
    }
    
}

