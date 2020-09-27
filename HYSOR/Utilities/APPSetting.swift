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
    static let businessHoursKey: String = "businessHours"
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

    var taxRate: Float = 0.13
    
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
    
    static var businessHours: [String: String] {
        
        let hours = userDefaults.dictionary(forKey: Constants.businessHoursKey) as? [String: String]
        return hours ?? ["1": "11:00-22:00", "2": "11:00-22:00", "3": "11:00-22:00", "4": "11:00-22:00", "5": "11:00-22:00", "6": "11:00-24:00", "7": "11:00-24:00"]
    
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
        
        print("didset info for \(UserDefaults.standard.string(forKey: "name"))")
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
