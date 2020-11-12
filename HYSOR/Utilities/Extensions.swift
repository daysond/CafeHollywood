//
//  Extensions.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-17.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Decimal {
    
    var stringRepresentation: String {
        get {
            let str = "\(self)"
            let arr = str.split(separator: ".")
            if arr.count == 1 {
                return "\(arr[0]).00"
            } else {
                // has cents
                let dollars = arr[0]
                let cents = arr[1]
                if cents.count == 1 {
                    return "\(dollars).\(cents)0"
                }
                return "\(dollars).\(cents)"
            }
        }
    }
    
    
}

extension String {
    
    static func randomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func textHeightFor(font: UIFont, width: CGFloat) -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = self
        label.sizeToFit()
        
        return label.frame.height
        
    }
    
}


extension Date {
    
    static func dateOfDayEEEMMddyyyy(after day: Int = 0) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMM dd yyyy")
        let now = Calendar.current.dateComponents(in: .current, from: Date())
        let today = DateComponents(year: now.year, month: now.month, day: now.day! + day )
        let dateOfToday = Calendar.current.date(from: today)!
        let date = dateFormatter.string(from: dateOfToday)
        
        return date
    }
    
    static func dateOfStringEEEMMddyyyy(_ str: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMM dd yyyy")
        let date = dateFormatter.date(from: str)
        
        return date
    }
    
    static func dateFromTimestamp(_ timestamp: Double) -> Date  {
        let timeInterval = timestamp/1000
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    static func dateInYYYYMMddFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd hh:mm"
        return formatter.string(from: date)
    }
    
    static func timestampInInt() -> Int64 {
        
        let ts = NSDate().timeIntervalSince1970 * 1000
        
        let tsInInt = Int64(ts)
        
        return tsInInt
        
    }
    
    static func isWeekDay() -> Bool {
        
        let day = Date().getDayOfWeek()
        
        return day < 6
        
    }
    
    static func covertCurrentTimeToIntInhhmm() -> Int {
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return hour * 100 + minute
    }
    
    static func currentTime() -> String {
        
        let hourMinuteFormatter = DateFormatter()
        hourMinuteFormatter.setLocalizedDateFormatFromTemplate("HH mm")
        return hourMinuteFormatter.string(from: Date())
    }
    
    
    func getDayOfWeek() -> Int {
        
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: self)
        return weekDay
    }
    
    
    
}

extension UIColor {
    
    static let offWhite = UIColor(red: 248, green: 238, blue: 255, alpha: 1)
    static let whiteSmoke =  UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
    static let ghostWhite = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
    static let ghostWhite75 = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 0.75)
    static let black85 = UIColor(red: 0/255.0, green: 0/255.0, blue:  0/255.0, alpha: 0.75)
    static let smokyBlack = UIColor(red: 18/255.0, green: 18/255.0, blue:  18/255.0, alpha: 1.0)
    static let starYellow = UIColor(red: 255.0/255.0, green: 149.0/255.0, blue:  15.0/255.0, alpha: 1.0)
    func isEqualToColor(_ color: UIColor) -> Bool {
        
        var red:CGFloat = 0
        var green:CGFloat  = 0
        var blue:CGFloat = 0
        var alpha:CGFloat  = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        var red2:CGFloat = 0
        var green2:CGFloat  = 0
        var blue2:CGFloat = 0
        var alpha2:CGFloat  = 0
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return (Int(red*255) == Int(red*255) && Int(green*255) == Int(green2*255) && Int(blue*255) == Int(blue*255) )
        
        
    }
    
    
}

extension Notification.Name {
    
    static let didTapModifyButton = Notification.Name("didTapModifyButton")
    static let updateFavouriteListTableView = Notification.Name("updateFavouriteListTableView")
    static let didUpdateOrderStatus = Notification.Name("didUpdateOrderStatus")
    static let authStateDidChange = Notification.Name("authStateDidChange")
    static let didCloseTable = Notification.Name("didCloseTable")
    static let didUpdateDineInOrderStatus = Notification.Name("didUpdateDineInOrderStatus")
    
}


extension UITextField {
    
    enum PaddingSide {
        case left(CGFloat)
        case right(CGFloat)
        case both(CGFloat)
    }
    
    func addPadding(_ padding: PaddingSide) {
        
        self.leftViewMode = .always
        self.layer.masksToBounds = true
        
        
        switch padding {
        
        case .left(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.leftView = paddingView
            self.rightViewMode = .always
            
        case .right(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = paddingView
            self.rightViewMode = .always
            
        case .both(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            // left
            self.leftView = paddingView
            self.leftViewMode = .always
            // right
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
}

extension NSManagedObjectContext {
    
    /// Executes the given `NSBatchDeleteRequest` and directly merges the changes to bring the given managed object context up to date.
    ///
    /// - Parameter batchDeleteRequest: The `NSBatchDeleteRequest` to execute.
    /// - Throws: An error if anything went wrong executing the batch deletion.
    public func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}

extension UILabel {
    
    func intrinsicHeight(width: CGFloat) -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        
        return label.frame.height
    }
    
}

extension UIViewController {
    
    func showError(title: String = "Error", message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            return
        }))
        
        
        self.present(alert, animated: true)
        
    }
    
    
    
}
