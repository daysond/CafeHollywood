//
//  Resturant.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-12.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import CoreData




class Table {
    
    static let shared = Table()
    
    var tableNumber: String?
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

enum MenuType: String {
    case drinkMenu = "drinkMenu"
    case foodMenu = "foodMenu"
}

struct Menu {
    
    let uid: String
    let menuTitle: String
    let mealsInUID: [String]
    var imageURL: String
    let menuDetail: String?
    
    //GETTER
    var isSingleMealMenu: Bool {
        return mealsInUID.count == 1
    }
    
    var headerImageURL: String {
        return "\(uid)Header"
    }
    
    init(uid: String, menuTitle: String, menuDetail: String?, mealUIDs: [String], imageURL: String) {
        
        self.uid = uid
        self.menuTitle = menuTitle
        self.menuDetail = menuDetail
        self.mealsInUID = mealUIDs
        self.imageURL = imageURL
        
    }
    
    init?(menuManaged: MenuManaged){
        
        guard let uid = menuManaged.uid, let title = menuManaged.menuTitle, let detail = menuManaged.menuDetail, let imageURL = menuManaged.imageURL, let meals = menuManaged.mealsInUID else {
            print("init menu failed")
            return nil
            
        }
        
        self.uid = uid
        self.menuDetail = detail
        self.menuTitle = title
        self.imageURL = imageURL
        self.mealsInUID = meals.split(separator: ",").map({ String($0) })
    }

    
    
    var representation: [String : Any] {
        
        
        let rep: [String: Any] = [
            //MARK: - NEED TO FIX THIS *****************************************************************************
            "uid": uid,
            "menuTitle": menuTitle,
            "menuDetail": menuDetail,
            "imageURL": imageURL,
            "isSingleMealMenu": isSingleMealMenu,
            "mealsInUID": mealsInUID,
        ]
        
        
        return rep
    }
    
    
}


