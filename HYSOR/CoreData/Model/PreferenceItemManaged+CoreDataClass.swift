//
//  PreferenceItemManaged+CoreDataClass.swift
//  
//
//  Created by Dayson Dong on 2020-08-18.
//
//

import Foundation
import CoreData

@objc(PreferenceItemManaged)
public class PreferenceItemManaged: NSManagedObject {
    
    func convertFrom(_ item: PreferenceItem) {
        
        self.name = item.name
        
        self.uid = item.uid
        
        if let itemPrice = item.price?.amount {
            self.price = NSDecimalNumber(decimal: itemPrice)
        }
        
        if let itemComboTag = item.comboTag {
            self.comboTag = NSNumber(value: itemComboTag)
        }
        
    }
    
    func convertToItem() -> PreferenceItem? {
        
        guard let name = self.name, let uid = self.uid else { return nil}
        
        if let price = self.price {
            
            let priceInDecimal = Money(amt: price as Decimal)
            var item = PreferenceItem(name: name, price: priceInDecimal , uid: uid)
            item.comboTag = self.comboTag?.intValue
            return item
            
        } else {
            
            var item = PreferenceItem(name: name, price: nil, uid: uid)
            item.comboTag = self.comboTag?.intValue
            return item
            
        }

    }
    
    
    

}
