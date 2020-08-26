//
//  PreferenceManaged+CoreDataClass.swift
//  
//
//  Created by Dayson Dong on 2020-08-18.
//
//

import Foundation
import CoreData

@objc(PreferenceManaged)
public class PreferenceManaged: NSManagedObject {
    
    func convertFrom(_ preference: Preference) {
        
        self.isRequired = preference.isRequired
        self.maxItemQuantity = Int64(preference.maxItemQuantity)
        self.maxPick = Int64(preference.maxPick)
        self.name = preference.name
        self.uid = preference.uid
        
        for item in preference.preferenceItems {
            
            if let itemManaged = DBManager.shared.readItem(uid: item.uid) {
                
                
            }
        
        }
        
    }
    
    

}
