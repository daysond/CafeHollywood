//
//  Order.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-17.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation

protocol CartDelegate {
    func didFinishUpdateCart()
}

protocol UpdateDisplayDelegate {
    func updateDisplay()
}

class Cart {
        
    static let shared = Cart()
    
    var delegate: CartDelegate?
    var uiDelegate: UpdateDisplayDelegate?
    
    var meals: [Meal] = [] {
        didSet{
            self.delegate?.didFinishUpdateCart()
            self.uiDelegate?.updateDisplay()
        }
    }
    
    var promotion: Money?
//    var discountPercentage: Double?
    var discountAmount: Money? {
        
        var discountAmount = Decimal(0)
        
        var drinkCombos: [ComboType] = []
        var wingCombos: [ComboType] = []
        
        var drinkTags: [Int] = []
        var wingTags: [Int] = []
//        var comboWings: [ComboType] = []
        meals.forEach { (meal) in
            
            for _ in 1...meal.quantity {
                
                if let type = meal.comboType {
                    switch type {
                    case .drink:
                        drinkCombos.append(type)
                    default:
                        wingCombos.append(type)
                    }
                }
                
                if let tag = meal.comboTag {
                    tag == 0 ? drinkTags.append(tag) : wingTags.append(tag)
                }
                
            }
        }
        

        discountAmount +=  drinkCombos.count < drinkTags.count ?
                ComboType.drink.deductionAmount * Decimal(drinkCombos.count) :
                ComboType.drink.deductionAmount * Decimal(drinkTags.count)
        
        discountAmount +=  wingCombos.count < wingTags.count ?
                ComboType.wing.deductionAmount * Decimal(wingCombos.count) :
                ComboType.wing.deductionAmount * Decimal(wingTags.count)

        
        

        
        return Money(amt: discountAmount)

        
    }
    
    var cartSubtotal: Money {
        let total = meals.reduce(Money(amt: 0.0)) { (runningTotal, meal) in
             runningTotal + meal.totalPrice
        }
        
        return total - (discountAmount ?? Money(amt: 0.0))
    }
    
    var cartTaxes: Money {
        return cartSubtotal * APPSetting.shared.taxRate
    }
    
    var cartTotal: Money {
        return cartTaxes + cartSubtotal
    }
    var orderID: String?
    
    var orderTimestamp: String {
        return "\(Date.timestampInInt())"
    }
    
    var paymentMethod: String?
    
    var restaurantID: String?
    
    var isEmpty: Bool {
        return meals.isEmpty
    }
    init() {
        

        self.orderID = UUID().uuidString
    }
    
}

extension Cart: JSONRepresentation {
    
    
    
    var representation: [String : Any] {
        
        var mealsInfo: [[String: Any]] = []
        
        meals.forEach { (meal) in
            mealsInfo.append(meal.representation)
        }
        
        let rep: [String: Any] = [
            //MARK: - NEED TO FIX THIS *****************************************************************************
            "customerID": APPSetting.customerUID,
            "customerName": APPSetting.customerName ,
            "subtotal": cartSubtotal.amount,
            "total": cartTotal.amount,
            "taxes": cartTaxes.amount,
            "discount": discountAmount?.amount ?? 0,
            "promotion": promotion?.amount ?? 0,
            "paymentMethod": paymentMethod ?? "test visa",
            "orderTimestamp": orderTimestamp,
            "restaurantID" : "YQk95Gnq5nQWWGqg7PIH",
            "restaurantName" :  "Cafe Hollywood",
            "orderStatus": OrderStatus.unconfirmed.rawValue,
            "mealsInfo": mealsInfo,
            
            /*
             
            case cancelled = 0
             case unconfirmed = 1
             case confirmed = 2
             case ready = 3
             case completed = 4
             case sent = 5
             
             */
            
        ]
            

        return rep
    }
    
    
    
    
    
    
}
