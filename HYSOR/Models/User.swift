//
//  User.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation

let userDefaults = UserDefaults.standard

struct User {
    
    
    
    static var shared: User = {
        
        //            print("TAG GEtting user")
        let name = UserDefaults.standard.string(forKey: "name") ?? "temp"
        let email = UserDefaults.standard.string(forKey: "email") ?? "temp@temp.com"
        let uid = UserDefaults.standard.string(forKey: "uid") ?? "tempid"
        let stripeID = UserDefaults.standard.string(forKey: "stripeID")
        let user = User(name: name, email: email, uid: uid, stripeID: stripeID ?? nil)
        return user
        }()
        
    let name: String
    let email: String
    let uid: String
    var stripeID: String?
    var favouriteList: [String] {
        
        let list = userDefaults.array(forKey: Constants.favouriteListKey) as? [String]
        return list ?? [String]()
    
    }
    
    init(name: String, email: String, uid: String, stripeID: String?) {
        self.name = name
        self.email = email
        self.uid = uid
        self.stripeID = stripeID
    }
    
    static func unfavouriteMeal(uid: String) {
        
        let newlist = User.shared.favouriteList.filter { $0 != uid}
        APPSetting.shared.favouriteMeals = APPSetting.shared.favouriteMeals.filter{ $0.uid != uid}
        userDefaults.set(newlist, forKey: Constants.favouriteListKey)
        userDefaults.removeObject(forKey: uid)
        
    }
    
    static func favouriteMeal(uid: String) {
        
        var newlist = User.shared.favouriteList
        newlist.append(uid)
        userDefaults.set(newlist, forKey: Constants.favouriteListKey)
        
        
        
    }
    
    
    
}
