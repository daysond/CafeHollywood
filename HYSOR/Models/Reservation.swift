//
//  User.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

enum ReservationStatus: Int {
    
    case confirmed = 1
    case cancelled = 0
    
}

class Reservation {
    
    let uid: String
    let customerID: String
    let customerName: String
    let customerPhoneNumber: String
    var pax: Int
    var date: String
    var note: String?
    var status: ReservationStatus
    
    init(pax: Int, date: String) {
        
        self.uid = String.randomString(length: 5)
        self.pax = pax
        self.date = date
        self.status = .confirmed
        self.customerID = APPSetting.customerUID
        self.customerName = APPSetting.customerName
        self.customerPhoneNumber = APPSetting.customerPhoneNumber
    }
    
    var representation: [String : Any] {
        
        
        let rep: [String: Any] = [
            
            "pax": pax,
            "date": date,
            "customerID": customerID,
            "customerName": customerName,
            "customerPhoneNumber": customerPhoneNumber,
            "status": status.rawValue
        ]
            
        return rep
    }
    
    
    
}
