//
//  PreferenceItemManaged+CoreDataClass.swift
//  
//
//  Created by Dayson Dong on 2020-09-06.
//
//

import Foundation
import CoreData

@objc(PreferenceItemManaged)
public class PreferenceItemManaged: NSManagedObject {
    
    func convertFrom(_ item: PreferenceItem) {
        
        self.name = item.name
        
        self.uid = item.uid
        
        self.itemDescription = item.itemDescription
        
        if let itemPrice = item.price?.amount {
            self.price = NSDecimalNumber(decimal: itemPrice)
        }
        
        if let itemComboTag = item.comboTag {
            self.comboTag = NSNumber(value: itemComboTag)
        }
        
    }
    
    func convertToItem() -> PreferenceItem? {
        
        guard let name = self.name, let uid = self.uid, let itemDescription = self.itemDescription else { return nil}
        
        if let price = self.price {
            
            let priceInDecimal = Money(amt: price as Decimal)
            var item = PreferenceItem(name: name, price: priceInDecimal , uid: uid, description: itemDescription)
            item.comboTag = self.comboTag?.intValue
            return item
            
        } else {
            
            var item = PreferenceItem(name: name, price: nil, uid: uid, description: itemDescription)
            item.comboTag = self.comboTag?.intValue
            return item
            
        }

    }
    

}
