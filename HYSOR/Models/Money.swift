//
//  Money.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-14.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation

struct Money: Comparable, Hashable {
    
    static let decimalHandlerRounded = NSDecimalNumberHandler.init(roundingMode:.up, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    static let decimalHandler = NSDecimalNumberHandler.init(roundingMode:.down, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
    
    let money: NSDecimalNumber

    var amount: Decimal {
        get {
            return money.rounding(accordingToBehavior: Money.decimalHandler).decimalValue
        }
    }
    
//    var roundedAmount: Decimal {
//        get {
//            let amountInCents = NSDecimalNumber(decimal: amount*100).intValue
//            let remainder = amountInCents % 5
//            if remainder < 3 {
//                let newAmount = amountInCents - remainder
//                return NSDecimalNumber(value: newAmount).dividing(by: NSDecimalNumber(value: 100)).decimalValue
//            } else {
//                let newAmount = amountInCents - remainder + 5
//                return NSDecimalNumber(value: newAmount).dividing(by: NSDecimalNumber(value: 100)).decimalValue
//            }
//        }
//    }
//
//    var roundedAmountInCents: Int {
//        get {
//            return NSDecimalNumber(decimal: roundedAmount * 100).intValue
//        }
//    }
    
    
    var amountInCents: Int {
        get {
            return NSDecimalNumber(decimal: amount * 100).intValue
        }
    }
    
    
    init(amt: Float) {
        money = NSDecimalNumber(value: amt)
    }
    
    init(amt: Double) {
        money = NSDecimalNumber(value: amt)
    }
    
    init(amt: Decimal) {
        money = NSDecimalNumber(decimal: amt)
    }
    

    
}


extension Money {
    
    static func < (lhs: Money, rhs: Money) -> Bool {
        if lhs.amount < rhs.amount {
            return true
        }
        return false
    }
    
    
    static func +(lhs: Money, rhs: Money) -> Money{
        let money = lhs.money.adding(rhs.money)
        return Money(amt: money.decimalValue)
    }
    
    static func +(lhs: Money, rhs: Float) -> Money{
        let money = lhs.money.adding(NSDecimalNumber(value: rhs))
        return Money(amt: money.decimalValue)
    }
    
    static func +(lhs: Float, rhs: Money) -> Money{
        let money = NSDecimalNumber(value:lhs).adding(rhs.money)
        return Money(amt: money.decimalValue)
    }
    
    
    
    static func -(lhs: Money, rhs: Money) -> Money{
        let money = lhs.money.subtracting(rhs.money)
        return Money(amt: money.decimalValue)
    }
    
    static func -(lhs: Money, rhs: Float) -> Money{
        let money = lhs.money.subtracting(NSDecimalNumber(value: rhs))
        return Money(amt: money.decimalValue)
    }
    
    static func -(lhs: Float, rhs: Money) -> Money{
        let money = NSDecimalNumber(value:lhs).subtracting(rhs.money)
        return Money(amt: money.decimalValue)
    }
    
    
    
    static func *(lhs: Money, rhs: Money) -> Money{
        let money = lhs.money.multiplying(by: rhs.money)
        return Money(amt: money.decimalValue)
    }
    
    static func *(lhs: Money, rhs: Float) -> Money{
        let money = lhs.money.multiplying(by: NSDecimalNumber(value: rhs))
        return Money(amt: money.decimalValue)
    }
    
    static func *(lhs: Float, rhs: Money) -> Money{
        let money = rhs.money.multiplying(by: NSDecimalNumber(value: lhs))
        return Money(amt: money.decimalValue)
    }
    
    
    
    static func /(lhs: Money, rhs: Money) -> Money{
        let money = lhs.money.dividing(by:rhs.money)
        return Money(amt: money.decimalValue)
    }
    
    static func /(lhs: Money, rhs: Float) -> Money{
        let money = lhs.money.dividing(by: NSDecimalNumber(value: rhs))
        return Money(amt: money.decimalValue)
    }
    
    static func /(lhs: Float, rhs: Money) -> Money{
        let money = NSDecimalNumber(value: lhs).dividing(by: rhs.money)
        return Money(amt: money.decimalValue)
    }
    
    static func ==(lhs: Money, rhs: Money) -> Bool {
        if lhs.money.compare(rhs.money) == .orderedSame {
            return true
        }
        return false
    }
}
