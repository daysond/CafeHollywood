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
//    case sent = 5
    case scheduled = 6
    case scheduledConfirmed = 7
    
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
//        case .sent:
//            return "Sent"
        case .scheduled:
            return "Scheduled"
        
        case .scheduledConfirmed:
            return "Scheduled Confirmed"
        
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
//        case .sent:
//            return UIImage(named: "comfirmed")!
        case .scheduled:
            return UIImage(named: "unconfirmed")!
        case .scheduledConfirmed:
            return UIImage(named: "confirmed")!
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
    var status: OrderStatus
    let customerName: String
    var pickupTime: String?
    var pickupDate: String?
    var giftOptionContent: [String: String]?
    
    init?(id: String, data: [String: Any]) {

        guard let customerID = data["customerID"] as? String,
        
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
        
        if let giftOption = data["giftOptionContent"] as? [String: String] {
            self.giftOptionContent = giftOption
        }
        
        if let pickupTime = data["pickupTime"] as? String {
            self.pickupTime = pickupTime
        }
        
        if let pickupDate = data["pickupDate"] as? String {
            self.pickupDate = pickupDate
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

