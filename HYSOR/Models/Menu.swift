//
//  Menu.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-11-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import CoreData

enum MenuType: String {
    case drinkMenu = "drinkMenu"
    case foodMenu = "foodMenu"
}

struct Menu {
    
    let uid: String
    let menuTitle: String
    let mealsInUID: [String]
    var imageURL: String
    let menuDetail: String?
    var isTakeOutOnly: Bool
    
    //GETTER
    var isSingleMealMenu: Bool {
        return mealsInUID.count == 1
    }
    
    var headerImageURL: String {
        return "\(uid)Header"
    }
    
    init(uid: String, menuTitle: String, menuDetail: String?, mealUIDs: [String], imageURL: String, isTakeOutOnly: Bool = false ) {
        
        self.uid = uid
        self.menuTitle = menuTitle
        self.menuDetail = menuDetail
        self.mealsInUID = mealUIDs
        self.imageURL = imageURL
        self.isTakeOutOnly = isTakeOutOnly
        
    }
    
    init?(menuManaged: MenuManaged){
        
        guard let uid = menuManaged.uid, let title = menuManaged.menuTitle, let detail = menuManaged.menuDetail, let imageURL = menuManaged.imageURL, let meals = menuManaged.mealsInUID else {
            print("init menu failed")
            return nil
            
        }
        
        let isTakeOutOnly = menuManaged.isTakeOutOnly
        
        self.uid = uid
        self.menuDetail = detail
        self.menuTitle = title
        self.imageURL = imageURL
        self.mealsInUID = meals.split(separator: ",").map({ String($0) })
        self.isTakeOutOnly = isTakeOutOnly
    }

    
    
    var representation: [String : Any] {
        
        let rep: [String: Any] = [
  
            "uid": uid,
            "menuTitle": menuTitle,
            "menuDetail": menuDetail ?? "",
            "imageURL": imageURL,
            "isSingleMealMenu": isSingleMealMenu,
            "mealsInUID": mealsInUID,
        ]
        
        
        return rep
    }
    
    
}
