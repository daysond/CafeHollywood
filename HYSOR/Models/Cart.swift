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
    
    var tempMeals: [Meal] = []
    
    var selectedGiftOption: Meal?
    
    var giftOptionContent: [String: String]?
    
    var promotion: Money?

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
        return cartSubtotal > Money(amt: APPSetting.shared.miniPurchase) ? cartSubtotal * Money(amt: APPSetting.shared.hstRate) : cartSubtotal * Money(amt: APPSetting.shared.federalTaxRate)
    }
    
    var cartTotal: Money {
        return cartTaxes + cartSubtotal
    }
//    var orderID: String?
    
    var orderTimestamp: String {
        return "\(Date.timestampInInt())"
    }
    
    var orderNote: String = ""
    
    var pickupTime: String?
    
    var pickupDate: String?
    
    
    var isEmpty: Bool {
        return meals.isEmpty
    }
    
    
    static func resetCart() {
        
        Cart.shared.meals.removeAll()
        Cart.shared.orderNote = ""
        Cart.shared.pickupTime = nil
        Cart.shared.selectedGiftOption = nil
        Cart.shared.giftOptionContent = nil
        Cart.shared.promotion = nil
    }
    
    func removeGiftOption() {
        
        guard let option = Cart.shared.selectedGiftOption else {
            return
        }
        Cart.shared.selectedGiftOption = nil
        giftOptionContent = nil
        Cart.shared.meals.removeAll { $0.uid == option.uid }
        
    }
    

    
}

extension Cart: JSONRepresentation {
    
    
    var representation: [String : Any] {
        
        var mealsInfo: [[String: Any]] = []
        
        meals.forEach { (meal) in
            mealsInfo.append(meal.representation)
        }
        
        
        var rep: [String: Any] = [

            "customerID": APPSetting.customerUID,
            "customerName": APPSetting.customerName,
            "customerPhoneNumber": APPSetting.customerPhoneNumber,
            "subtotal": cartSubtotal.amount,
            "total": cartTotal.amount,
            "taxes": cartTaxes.amount,
            "discount": discountAmount?.amount ?? 0,
            "promotion": promotion?.amount ?? 0,
            "orderNote": orderNote,
            "orderTimestamp": orderTimestamp,
            "status": pickupTime == nil ? OrderStatus.unconfirmed.rawValue : OrderStatus.scheduled.rawValue,
            "mealsInfo": mealsInfo,
            
        ]
        
        if self.pickupTime != nil {
            rep["pickupTime"] = pickupTime!
        }
        
        if self.pickupDate != nil {
            rep["pickupDate"] = pickupDate!
        }
        
        if self.giftOptionContent != nil {
            rep["giftOptionContent"] = giftOptionContent!
        }
            

        return rep
    }
    
    
    var dineInRepresentation: [String : Any] {
        
        
        var mealsInfo: [[String: Any]] = []
        
        meals.forEach { (meal) in
            mealsInfo.append(meal.representation)
        }
        
        let rep: [String: Any] = [
            "customerID": APPSetting.customerUID,
            "customerName": APPSetting.customerName,
            "customerPhoneNumber": APPSetting.customerPhoneNumber,
            "orderTimestamp": orderTimestamp,
            "status": OrderStatus.unconfirmed.rawValue,
            "mealsInfo": mealsInfo,
            "table": Table.shared.tableNumber ?? "Error Table"
        ]
        

            

        return rep
    }
    
    
    
    
    
}
