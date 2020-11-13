//
//  Table.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-11-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation

class Table {
    
    static let shared = Table()
    
    var tableNumber: String? {
        didSet {
            NotificationCenter.default.post(name: .didScanTableQRCode, object: nil)
        }
    }
//    var tableID: String?
    var orderIDs: [String] {
        tableOrders.compactMap { $0.orderID }
    }
    var tableOrders: [TableOrder] = []
    
    var unconfirmedOrders: [TableOrder] {
        tableOrders.filter{ $0.status == .unconfirmed }
    }
    
    var confirmedOrders: [TableOrder] {
        tableOrders.filter{ $0.status == .confirmed }
    }
    
    var cancelledOrders: [TableOrder] {
        tableOrders.filter{ $0.status == .cancelled }
    }
    
    
    var shouldShowAllOrders: Bool = true
    var timestamp: String?
    
    var unconfirmedMeals: [MealInfo] {
        shouldShowAllOrders ? unconfirmedOrders.sorted{ $0.orderTimestamp < $1.orderTimestamp }.flatMap { $0.meals } : unconfirmedOrders.filter { $0.customerID == APPSetting.customerUID }.sorted{ $0.orderTimestamp < $1.orderTimestamp }.flatMap{ $0.meals }
    }
    
    var confirmedMeals: [MealInfo] {
        shouldShowAllOrders ? confirmedOrders.sorted{ $0.orderTimestamp < $1.orderTimestamp }.flatMap { $0.meals } : confirmedOrders.filter { $0.customerID == APPSetting.customerUID }.sorted{ $0.orderTimestamp < $1.orderTimestamp }.flatMap{ $0.meals }
    }
    
    var cancelledMeals: [MealInfo] {
        shouldShowAllOrders ? cancelledOrders.sorted{ $0.orderTimestamp < $1.orderTimestamp }.flatMap { $0.meals } : cancelledOrders.filter { $0.customerID == APPSetting.customerUID }.sorted{ $0.orderTimestamp < $1.orderTimestamp }.flatMap{ $0.meals }
    }
    
    var subTotal: Money {
    
        let subtotal = confirmedMeals.reduce(Money(amt: 0.0)) { (runningTotal, meal)  in
            runningTotal + Money(amt: meal.totalPrice)
        }
        
        return subtotal - drinkCredit
    }
    
    var taxes: Money {
        return subTotal > Money(amt: APPSetting.shared.miniPurchase) ? subTotal * Money(amt: APPSetting.shared.hstRate) : subTotal * Money(amt: APPSetting.shared.federalTaxRate)
    }
    
    var total: Money {
        return taxes + subTotal
    }
    
    
    var drinkCredit: Money {
        
        var discountAmount = Decimal(0)
        var drinkComboCount = 0
        var wingComboCount = 0
        var drinkTagCount = 0
        var wingTagCount = 0

        confirmedMeals.forEach { (meal) in
            
            for _ in 1...meal.quantity {
                
                if let type = meal.comboType {
                    if type == .drink {
                        drinkComboCount += 1
                    } else {
                        wingComboCount += 1
                    }
                }
                
                if let tag = meal.comboTag {
                    if tag == 0 {
                        drinkTagCount += 1
                    } else {
                        wingTagCount += 1
                    }
                }
            }
        }
        
        discountAmount +=  drinkComboCount < drinkTagCount ?
                ComboType.drink.deductionAmount * Decimal(drinkComboCount) :
                ComboType.drink.deductionAmount * Decimal(drinkTagCount)
        
        discountAmount +=  wingComboCount < wingTagCount ?
                ComboType.wing.deductionAmount * Decimal(wingComboCount) :
                ComboType.wing.deductionAmount * Decimal(wingTagCount)
        
        return Money(amt: discountAmount)
    }
    
    static func reset() {
        NotificationCenter.default.post(name: .didCloseTable, object: nil)
        Table.shared.tableNumber = nil
        Table.shared.timestamp = nil
        Table.shared.tableOrders = []
//        Table.shared.orderIDs = []
        Table.shared.shouldShowAllOrders = true

        
    }
    
    var representation: [String : Any] {
        
        let rep: [String: Any] = [
            "tableNumber": tableNumber ?? "Error Table",
            "timestamp": "\(Date.timestampInInt())",
        ]
        
        return rep
    }
    
}
