//
//  MealInfo.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-11-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation

struct MealInfo {
    
    let mealInfoID: String
    let name: String
    let quantity: Int
    let totalPrice: Double
    let addOnInfo: String
    let instruction: String
    let comboType: ComboType?
    let comboTag: Int?

    init?(id: String, data: [String: Any]) {
        
        guard
            let name = data["name"] as? String,
            let quantity = data["quantity"] as? Int,
            let totalPrice = data["totalPrice"] as? Double,
            let addOnInfo = data["addOnInfo"] as? String,
            let instruction = data["instruction"] as? String
            else { return nil }
        
        self.mealInfoID = id
        self.name = name
        self.quantity = quantity
        self.totalPrice = totalPrice
        self.addOnInfo = addOnInfo
        self.instruction = instruction
        
        if let comboTypeInt = data["comboType"] as? Int  {
            self.comboType = ComboType(rawValue: comboTypeInt)
        } else {
            self.comboType = nil
        }
        
        if let comboTag = data["comboTag"] as? Int {
            self.comboTag = comboTag
        } else {
            self.comboTag = nil
        }
        
    }
    
}
