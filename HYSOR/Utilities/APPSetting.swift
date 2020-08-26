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

enum Constants {
    static let baseURL = URL(string: "https://hysor-stripe-api.herokuapp.com")!
    static let publishableKey = "pk_test_KMCerPRQaKzAv45qvFR58Vnl00Ccaf8NiN"
    static let secrectKey = "sk_test_Gaah29dliX1UUMIe3a6OAqqO00OQIP9EWO"
    static let localhostURLString = URL(string: "http://localhost:5001/hysor-5e8ed/us-central1/app")!
    static let defaultCurrency = "usd"
    static let defaultDescription = "Purchase from RWPuppies iOS"
    static let customerID = "cus_HdCPqItG5nPXJl"
    static let kOrderButtonHeightConstant: CGFloat = 50.0
    static let kReceiptHeaderHeight: CGFloat = 200
    static let kReceiptFooterHeight: CGFloat = 115
    static let kReceiptCellHeight: CGFloat = 35
    static let favouriteListKey: String = "favouriteList"
    static let drinkMenuTypeRawValue = "drinkMenu"
    static let foodMenuTypeRawValue = "foodMenu"
}


class APPSetting {
    // should be fetched from server
    static let shared = APPSetting()

    var taxRate: Float = 0.13
    var isDineIn = false
    var tableNumber: String?
    var customerName: String? // store name in sign up.
//    var user: User {
//        get {
////            print("TAG GEtting user")
//            let name = UserDefaults.standard.string(forKey: "name") ?? "temp"
//            let email = UserDefaults.standard.string(forKey: "email") ?? "temp@temp.com"
//            let uid = UserDefaults.standard.string(forKey: "uid") ?? "tempid"
//            let stripeID = UserDefaults.standard.string(forKey: "stripeID")
//            let user = User(name: name, email: email, uid: uid, stripeID: stripeID ?? nil)
//            return user
//        }
//    }
    var currentCartRestaurantID: String?
    
    var currentCartRestaurantName: String?
    
    var favouriteMeals: [Meal] = []
    
    
    func storeUserInfo(_ email: String, _ name: String, _ uid: String, _ stripeID: String? ) {
        
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(email, forKey: "email")
        userDefaults.set(uid, forKey: "uid")
        userDefaults.set(name, forKey: "name")
        userDefaults.set(stripeID, forKey: "stripeID")
        
        print("didset info for \(UserDefaults.standard.string(forKey: "name"))")
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
