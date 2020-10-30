//
//  APPSetting.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-05.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import UIKit

protocol JSONRepresentation {
    var representation: [String: Any] { get }
}

let userDefaults = UserDefaults.standard

enum Constants {

  
    static let kOrderButtonHeightConstant: CGFloat = 50.0
    static let kReceiptHeaderHeight: CGFloat = 148
    static let kReceiptFooterHeight: CGFloat = 50
    static let kReceiptCellHeight: CGFloat = 35
    static let favouriteListKey: String = "favouriteList\(APPSetting.customerUID)"
    static let drinkMenuTypeRawValue = "drinkMenu"
    static let foodMenuTypeRawValue = "foodMenu"
    static let checkoutNoteHolder = "(ANY FOOD ALLERGY?)"

}

enum Weekdays: Int {
    
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
}


class APPSetting {
    // should be fetched from server
    static let shared = APPSetting()

    var versions = [String: String]()
    
    var hstRate: Decimal {
        return federalTaxRate + provincialTaxRate
    }
    
    var federalTaxRate: Decimal {
        if let fedTRInt = userDefaults.value(forKey: Key.federalTaxRate) as? Int {
            return Decimal(fedTRInt)/100
        }
        return Decimal(0.05)
    }
    
    var provincialTaxRate: Decimal {
        if let proTRInt = userDefaults.value(forKey: Key.provincialTaxRate) as? Int {
            return Decimal(proTRInt)/100
        }
        return Decimal(0.08)
    }
    
    var miniPurchase: Decimal {
        if let miniPurInt = userDefaults.value(forKey: Key.miniPurchase) as? Int {
            return Decimal(miniPurInt)/100
        }
        return Decimal(4.00)
    }
    
    
    var isDineIn: Bool {
        Table.shared.tableNumber != nil
    }
    
    
    
    static var customerName: String {
        return NetworkManager.shared.currentUser?.displayName ?? ""
    }
    
    static var customerEmail: String {
        return NetworkManager.shared.currentUser?.email ?? ""
    }
    
    
    static var customerUID: String {
        return NetworkManager.shared.currentUser?.uid ?? ""
    }
    
    
    static var customerPhoneNumber: String {
        return NetworkManager.shared.currentUser?.phoneNumber ?? ""
    }
    
    static var verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
    
    static var favouriteMeals: [Meal] = []
    
    static var favouriteList: [String] {
        
        let list = userDefaults.array(forKey: Constants.favouriteListKey) as? [String]
        return list ?? [String]()
    
    }
    
    static var businessHours: [String: String]? {
        return userDefaults.dictionary(forKey: Key.businessHours) as? [String: String]
    }
    
    var openHours: [Weekdays: String]? {
        
        guard let businessHours = APPSetting.businessHours else { return nil}

        var tempOpenHours = [Weekdays : String]()
        businessHours.forEach { (day, hours) in
            let weekday = Weekdays(rawValue: Int(day)!)!
            let splitedHours = hours.split(separator: "-")
            tempOpenHours[weekday] = "\(splitedHours[0])"
        }
        
     return tempOpenHours
    }
    
    var closedHours: [Weekdays: String]? {
        
        guard let businessHours = APPSetting.businessHours else { return nil}
        var tempClosedHours = [Weekdays : String]()
        businessHours.forEach { (day, hours) in
            let weekday = Weekdays(rawValue: Int(day)!)!
            let splitedHours = hours.split(separator: "-")
            tempClosedHours[weekday] = "\(splitedHours[1])"
        }
        
     return tempClosedHours
    }
    
    var isRestaurantOpen: Bool {
        
        guard openHours != nil , closedHours != nil else { return false }
        let dow = Date().getDayOfWeek()
        let open = openHours![Weekdays(rawValue: dow)!]!
        let close = closedHours![Weekdays(rawValue: dow)!]!.split(separator: ":")[0]
        let lastCallHour = Int("\(close)")! - 1
        return Date.currentTime() >= open && Date.currentTime() <= "\(lastCallHour):30"
    }
    
    

    
    static func unfavouriteMeal(uid: String) {
        
        let newlist = APPSetting.favouriteList.filter { $0 != uid}
        APPSetting.favouriteMeals = APPSetting.favouriteMeals.filter{ $0.uid != uid}
        userDefaults.set(newlist, forKey: Constants.favouriteListKey)
        userDefaults.removeObject(forKey: uid)
        
    }
    
    static func favouriteMeal(uid: String) {
        
        var newlist = APPSetting.favouriteList
        newlist.append(uid)
        userDefaults.set(newlist, forKey: Constants.favouriteListKey)
        
    
    }
    
    static func storeUserInfo(_ email: String, _ name: String, _ uid: String, _ phoneNumber: String? ) {
        
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(email, forKey: "email")
        userDefaults.set(uid, forKey: "uid")
        userDefaults.set(name, forKey: "name")
        userDefaults.set(phoneNumber == nil ? "123456" : phoneNumber, forKey: "phoneNumber")
        
    }
    
    static func storePhoneVerificationID(_ verificationID: String) {
        
        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        
    }
    
    
}


/*
 
 let imageCache = NSCache<NSString,UIImage>()

 class TNImageView: UIImageView {
     
     var imageUrlString: String?
     
     override func layoutSubviews() {
         super.layoutSubviews()
         translatesAutoresizingMaskIntoConstraints = false
         contentMode = .scaleAspectFill
         clipsToBounds = true
     }
     
     func loadThumbnailImage(withURL imageURL: String) {
         print("loading TN \(imageURL)")
         imageUrlString = imageURL
         guard let url = URL(string: imageURL) else { return }
         
         image = nil
         
         if let imageFromCache = imageCache.object(forKey: imageURL as NSString) {
             self.image = imageFromCache
             return
         }
         
         WebService().fetchThumbnailImage(with: url) { (url, error) in
             
             guard error == nil else { return }
             guard let url = url else { return }
             
             DispatchQueue.main.async {
                 do {
                     let image = try UIImage(data: Data(contentsOf: url))
                     guard let imageToCache = image else { return }
                     if self.imageUrlString == imageURL {
                         self.image = imageToCache
                     }
                     imageCache.setObject(imageToCache, forKey: imageURL as NSString)
                 }catch let error {
                     print(error)
                 }
                
             }
         }
     }
 }
 
 
 
 */
