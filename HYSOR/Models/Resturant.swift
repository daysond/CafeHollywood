//
//  Resturant.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-12.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import CoreData


struct Resturant {
    
    let name: String
    let uid: String
    let imageURL: String
    let menu: [Meal]
    
}

struct Table {
    
    let uid: String
    let id: String
    var meals: [Meal]?
    
}

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
    
    //GETTER
    var isSingleMealMenu: Bool {
        return mealsInUID.count == 1
    }
    
    var headerImageURL: String {
        return "\(uid)Header"
    }
    
    init(uid: String, menuTitle: String, menuDetail: String?, mealUIDs: [String], imageURL: String) {
        
        self.uid = uid
        self.menuTitle = menuTitle
        self.menuDetail = menuDetail
        self.mealsInUID = mealUIDs
        self.imageURL = imageURL

    }
    
    init?(menuManaged: MenuManaged){
        
        guard let uid = menuManaged.uid, let title = menuManaged.menuTitle, let detail = menuManaged.menuDetail, let imageURL = menuManaged.imageURL, let meals = menuManaged.mealsInUID else {
            print("init menu failed")
            return nil
            
        }
        
        self.uid = uid
        self.menuDetail = detail
        self.menuTitle = title
        self.imageURL = imageURL
        self.mealsInUID = meals.split(separator: ",").map({ String($0) })
    }
    /*
     let date = Date()
     let calendar = Calendar.current
     let hour = calendar.component(.hour, from: date)
     let minutes = calendar.component(.minute, from: date)
     */
    
    var representation: [String : Any] {
        
        
        let rep: [String: Any] = [
            //MARK: - NEED TO FIX THIS *****************************************************************************
            "uid": uid,
            "menuTitle": menuTitle,
            "menuDetail": menuDetail,
            "imageURL": imageURL,
            "isSingleMealMenu": isSingleMealMenu,
            "mealsInUID": mealsInUID,
        ]
            

        return rep
    }
     
    
}

class Reservation {
    
    var pax: Int
    var date: String
    var note: String?
    var isConfirmed: Bool
    
    init(pax: Int, date: String) {
        
        self.pax = pax
        self.date = date
        self.isConfirmed = true
        
    }
    
    
    
}
