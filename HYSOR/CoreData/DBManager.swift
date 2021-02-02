//
//  DBManager.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-17.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DBManager {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static let shared = DBManager()
    
/*
    1. try to fetch it from DB
     
    2. if nil, then create data and return it
    
 
 */
    
    func deleteAllData() {
        
        let entities = ["MealManaged", "MenuManaged", "PreferenceItemManaged","PreferenceManaged" ]
        
        entities.forEach { (entity) in
            let mealRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                  let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: mealRequest)
                  
            do {
                
                try context.executeAndMergeChanges(using: batchDeleteRequest)
                
            } catch (let err) {
                print(err)
            }
                  
        }
        

        
    }
    
    func readMenu(type: MenuType) -> [Menu] {
        
        do {
            
            let request = MenuManaged.fetchRequest() as NSFetchRequest<MenuManaged>
            
            let pred = NSPredicate(format: "%K == %@", "menuType", type.rawValue as CVarArg)
            request.predicate = pred
            
            let items = try context.fetch(request)
            
//            print("got \(type.rawValue) count \(items.count)")
            
            return items.filter {Menu(menuManaged: $0) != nil }.map{Menu(menuManaged: $0)!}
            
        } catch  {
            print("cant read menu")
            return [Menu]()
        }

    }
    
    func writeMenu(_ menu: Menu, to type: MenuType) {
        
        let menuManaged = MenuManaged(context: context)
        
        menuManaged.uid = menu.uid
        menuManaged.menuTitle = menu.menuTitle
        menuManaged.menuDetail = menu.menuDetail
        menuManaged.imageURL = menu.imageURL
        menuManaged.menuType = type.rawValue
        menuManaged.mealsInUID = menu.mealsInUID.joined(separator: ",")
        menuManaged.isTakeOutOnly = menu.isTakeOutOnly
        
        print("did saved menu")
        
        saveContext(menu.menuTitle)
        
    }
    
//    func updateMenu(_ menu: Menu, of type: MenuType) {
//        
//        do {
//            
//            let request = MenuManaged.fetchRequest() as NSFetchRequest<MenuManaged>
//            
//            let pred = NSPredicate(format: "%K == %@", "uid", menu.uid as CVarArg)
//            request.predicate = pred
//            
//            let items = try context.fetch(request)
//            
//            if let item = items.first {
//                
//                item.imageURL = menu.imageURL
//                item.menuTitle = menu.menuTitle
//                item.menuDetail = menu.menuDetail
//                item.mealsInUID = menu.mealsInUID as NSArray
//                
//            } else {
//                
//                writeMenu(menu, to: type)
//                
//            }
//            
//        } catch  {
//            print("error")
//       
//        }
//        
//        
//    }

    
    func writeMeal(_ meal: Meal) {
        
        let mealManaged = MealManaged(context: context)
        
        mealManaged.uid = meal.uid
        mealManaged.name = meal.name
        mealManaged.detail = meal.details
        mealManaged.imageURL = meal.imageURL
        mealManaged.price = NSDecimalNumber(decimal: meal.price)
        mealManaged.mealDescription = meal.mealDescription
        mealManaged.isBOGO = meal.isBOGO
        if let tag = meal.comboTag {
            mealManaged.comboMealTag = NSNumber(value: tag)
//            print(" TAG \(mealManaged.comboMealTag)")
        }
        
        if let type = meal.comboType?.rawValue {
            mealManaged.comboType = NSNumber(value: type)
        }
        
        if let preferences = meal.preferences {
            
            preferences.forEach { (preference) in
    
                let preferenceManaged = convert(from: preference)
                
                preferenceManaged.addToMeal(mealManaged)
                
            }
        }
        
        saveContext(meal.name)
        
    }
    
    func readMeal(uid: String) -> Meal? {
        
        do {
            
            let request = MealManaged.fetchRequest() as NSFetchRequest<MealManaged>
            
            let pred = NSPredicate(format: "%K == %@", "uid", uid as CVarArg)
            request.predicate = pred
            
            let items = try context.fetch(request)
            
            if let managedItem = items.first {
                return Meal(managedObject: managedItem)
            } else {
                return nil
            }
            
        } catch  {
            print("error")
            return nil
        }
    }
    
    
    
    
    func convert(from preference: Preference) -> PreferenceManaged {
        
        if let preferenceManaged = readPreference(uid: preference.uid) {
            return preferenceManaged
        }
        
        let preferenceManaged = PreferenceManaged(context: context)
        
        preferenceManaged.isRequired = preference.isRequired
        preferenceManaged.maxItemQuantity = Int64(preference.maxItemQuantity)
        preferenceManaged.maxPick = Int64(preference.maxPick)
        preferenceManaged.name = preference.name
        preferenceManaged.uid = preference.uid
        
        for item in preference.preferenceItems {
            
            let itemManaged = convert(from: item)
            
            itemManaged.addToPreference(preferenceManaged)
        
        }
        
        saveContext(preference.name)
        
        return preferenceManaged
        
    }
    
    
    func readPreference(uid: String) -> PreferenceManaged? {
        
        do {
            
            let request = PreferenceManaged.fetchRequest() as NSFetchRequest<PreferenceManaged>
            
            let pred = NSPredicate(format: "%K == %@", "uid", uid as CVarArg)
            request.predicate = pred
            
            let items = try context.fetch(request)
            
            if let managedItem = items.first {
                return managedItem
            } else {
                return nil
            }
            
        } catch  {
            print("error")
            return nil
        }
        
        
    }

    
    func convert(from item: PreferenceItem) -> PreferenceItemManaged {
        
        if let itemManaged = readItem(uid: item.uid) {
            return itemManaged
        }
        
        let itemManaged = PreferenceItemManaged(context: context)
        
        itemManaged.name = item.name
        
        itemManaged.uid = item.uid
        
        itemManaged.itemDescription = item.itemDescription
        
        if let itemPrice = item.price?.amount {
            itemManaged.price = NSDecimalNumber(decimal: itemPrice)
        }
        
        if let itemComboTag = item.comboTag {
            itemManaged.comboTag = NSNumber(value: itemComboTag)
        }
        
        saveContext(item.name)
        
        return itemManaged
        
    }
    
    func readItem(uid: String) -> PreferenceItemManaged? {
        
        do {
            
            let request = PreferenceItemManaged.fetchRequest() as NSFetchRequest<PreferenceItemManaged>
            
            let pred = NSPredicate(format: "%K == %@", "uid", uid as CVarArg)
            request.predicate = pred
            
            //            let sort = NSSortDescriptor(key: "name", ascending: true)
            //            request.sortDescriptors = [sort]
            
            let items = try context.fetch(request)
            //            for item in items {
            //                print(item.uid)
            //            }
            
            if let managedItem = items.first {
                return managedItem
            } else {
                return nil
            }
            
        } catch  {
            print("error")
            return nil
        }
    }
    
    func saveContext(_ t: String) {
        
        do {
             try context.save()
            print("did save \(t)")
          } catch let error {
            print("cant save \(t) \(error)")
            
          }
        
    }
    

  
    
    
    
    
    
    
//
//        func writePreference(_ preference: Preference) {
//
//            let preferenceManaged = PreferenceManaged(context: context)
//
//            preferenceManaged.convertFrom(preference)
//
//            do {
//                 try context.save()
//              } catch {
//                  print("cant save")
//              }
//
//
//        }
        
//        func readPreference(uid: String) -> PreferenceItem? {
//
//            do {
//
//                let request = PreferenceItemManaged.fetchRequest() as NSFetchRequest<PreferenceItemManaged>
//
//                let pred = NSPredicate(format: "%K == %@", "uid", uid as CVarArg)
//                request.predicate = pred
//
//    //            let sort = NSSortDescriptor(key: "name", ascending: true)
//    //            request.sortDescriptors = [sort]
//
//                let items = try context.fetch(request)
//                for item in items {
//                    print(item.uid)
//                }
//
//                if let managedItem = items.first {
//                    print(managedItem.name)
//                    return managedItem.convertToItem()
//                } else {
//                    return nil
//                }
//
//            } catch  {
//                print("error")
//                return nil
//            }
//
//
//        }
    
    
    
    
//    func writeItem(_ item: PreferenceItem) {
//
//        let itemManaged = PreferenceItemManaged(context: context)
//
//        itemManaged.convertFrom(item)
//
//        do {
//             try context.save()
//          } catch {
//              print("cant save")
//          }
//
//
//    }
    

    
    
}
