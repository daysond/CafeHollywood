//
//  Receipt.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-16.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import UIKit

enum OrderStatus: Int {
    case cancelled = 0
    case unconfirmed = 1
    case confirmed = 2
    case ready = 3
    case completed = 4
    case sent = 5
    case scheduled = 6
    
    var status: String {
        switch self {
        case .unconfirmed:
            return "Unconfirmed"
        case .confirmed:
            return "Comfirmed"
        case .ready:
            return "Ready for pick up"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        case .sent:
            return "Sent"
        case .scheduled:
            return "Scheduled:"
        
        }
    }
    
    var image: UIImage {
        
        switch self {
        case .unconfirmed:
            return UIImage(named: "unconfirmed")!
        case .confirmed:
            return UIImage(named: "confirmed")!
        case .ready:
            return UIImage(named: "ready")!
        case .completed:
            return UIImage(named: "completed")!
        case .cancelled:
            return UIImage(named: "cancel")!
        case .sent:
            return UIImage(named: "comfirmed")!
        case .scheduled:
            return UIImage(named: "unconfirmed")!
        
        }
    }
}


class Receipt {
    
    let orderID: String
    let customerID: String
    let orderTimestamp: String
    let orderNote: String
    let discount: Double
    let promotion: Double
    let subtotal: Double
    let taxes: Double
    let total:Double
    let mealsInfo: [MealInfo]
    let restaurantName: String
    var status: OrderStatus
    let customerName: String
    
    
    init?(id: String, data: [String: Any]) {

        guard let customerID = data["customerID"] as? String,
        
            let restaurantName = data["restaurantName"] as? String,
            let orderTimestamp = data["orderTimestamp"] as? String,
            let orderNote = data["orderNote"] as? String,
            let discount = data["discount"] as? Double,
            let promotion = data["promotion"] as? Double,
            let taxes = data["taxes"] as? Double,
            let subtotal = data["subtotal"] as? Double,
            let total = data["total"] as? Double,
            let orderStatusInt = data["status"] as? Int,
            let customerName = data["customerName"] as? String,
            let orderStatus = OrderStatus(rawValue: orderStatusInt),
            let mealsInfo = data["mealsInfo"] as? [Dictionary<String,Any>]
            else { return nil}

        var mealsInfoObj: [MealInfo] = []
        
        for (index,info) in mealsInfo.enumerated() {
            if let uid = info["uid"] as? String, let mealInfo = MealInfo(id: "\(index)-\(uid)", data: info) {
                mealsInfoObj.append(mealInfo)
            }
        }

        self.orderID = id
        self.customerID = customerID
   
        self.orderTimestamp = orderTimestamp
        self.orderNote = orderNote
        self.discount = discount
        self.promotion = promotion
        self.subtotal = subtotal
        self.taxes = taxes
        self.total = total
        self.mealsInfo = mealsInfoObj
        self.restaurantName = restaurantName
        self.customerName = customerName
        self.status = orderStatus

    }
    
}

class TableOrder {
    
    let orderID: String
    let customerID: String
    let customerPhoneNumber: String
    let customerName: String
    let orderTimestamp: String
    let meals: [MealInfo]
    var status: OrderStatus
    
    let table: String
    
    
    init?(id: String, data: [String: Any]) {

        guard let customerID = data["customerID"] as? String,
              let customerName = data["customerName"] as? String,
              let customerPhoneNumber = data["customerPhoneNumber"] as? String,
        
            let orderTimestamp = data["orderTimestamp"] as? String,

            let orderStatusInt = data["status"] as? Int,
            let table = data["table"] as? String,
            let orderStatus = OrderStatus(rawValue: orderStatusInt),
            let mealsInfo = data["mealsInfo"] as? [Dictionary<String,Any>]
            else { return nil}

        var mealsInfoObj: [MealInfo] = []
        
        for (index,info) in mealsInfo.enumerated() {
            if let uid = info["uid"] as? String, let mealInfo = MealInfo(id: "\(index)-\(uid)", data: info) {
                mealsInfoObj.append(mealInfo)
            }
        }

        self.orderID = id
        self.customerID = customerID
        self.customerName = customerName
        self.customerPhoneNumber = customerPhoneNumber
        self.orderTimestamp = orderTimestamp
        self.meals = mealsInfoObj
        self.table = table
        self.status = orderStatus

    }
    
}

struct MealInfo {
    
    let mealInfoID: String
    let name: String
    let quantity: Int
    let totalPrice: Double
    let addOnInfo: String
    let instruction: String
    let comboType: ComboType?
    let comboTag: Int?
//    let mealDescription: String
//    let addOnDescription: String
//
    init?(id: String, data: [String: Any]) {
        
        guard
            let name = data["name"] as? String,
            let quantity = data["quantity"] as? Int,
            let totalPrice = data["totalPrice"] as? Double,
            let addOnInfo = data["addOnInfo"] as? String,
            let instruction = data["instruction"] as? String
//            let addOnDescription = data["addOnDescription"] as? String,
//            let mealDescription = data["description"] as? String
            else { return nil }
        
        self.mealInfoID = id
        self.name = name
        self.quantity = quantity
        self.totalPrice = totalPrice
        self.addOnInfo = addOnInfo
        self.instruction = instruction
//        self.addOnDescription = addOnDescription
//        self.mealDescription = mealDescription
        
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
