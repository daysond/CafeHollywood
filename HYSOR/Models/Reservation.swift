//
//  User.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.

import Foundation

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
    var time: String
    
    var note: String?
    var status: ReservationStatus
    let timestamp: String
    
    init(pax: Int, date: String, time: String) {
        
        self.uid = String.randomString(length: 5)
        self.pax = pax
        self.date = date
        self.time = time
        self.status = .confirmed
        self.customerID = APPSetting.customerUID
        self.customerName = APPSetting.customerName
        self.customerPhoneNumber = APPSetting.customerPhoneNumber
        self.timestamp = "\(Date.timestampInInt())"
    }
    
    init? (id: String, data: [String: Any]) {
        
        guard let customerID = data["customerID"] as? String,
              let customerName = data["customerName"] as? String,
              let customerPhoneNumber = data["customerPhoneNumber"] as? String,
              let date = data["date"] as? String,
              let pax = data["pax"] as? Int,
              let statusCode = data["status"] as? Int,
              let time = data["time"] as? String,
              let timestamp = data["timestamp"] as? String else {
            print("CAN NOT INTIILIZE RESERVATION \(id)")
            return nil
        }
        
        self.uid = id
        self.customerID = customerID
        self.customerName = customerName
        self.customerPhoneNumber = customerPhoneNumber
        self.pax = pax
        self.date = date
        self.time = time
        self.timestamp = timestamp
        self.status = ReservationStatus(rawValue: statusCode)!
        
        if let note = data["note"] as? String {
            self.note = note
        }
        
    }
    
    var representation: [String : Any] {
        
        
        let rep: [String: Any] = [
            
            "pax": pax,
            "date": date,
            "time": time,
            "timestamp": timestamp,
            "customerID": customerID,
            "customerName": customerName,
            "customerPhoneNumber": customerPhoneNumber,
            "status": status.rawValue
        ]
            
        return rep
    }
    
    
    
}
