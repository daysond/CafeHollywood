//
//  SchedulerView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-10.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class SchedulerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let datePicker = UIPickerView()
    let donebutton = BlackButton()
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        l.text = "Date and Time"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    private var dates: [String] = []
    private var times: [String] = []

    
    private let timeFormatter = DateFormatter()
    
    private let dayOfTheWeek = Date().getDayOfWeek()
    
    private let openTimes: [Weekdays : String]
    private let closeTimes: [Weekdays: String]
    
    
    
    private var currentTime:String {
        get {
            let hourMinuteFormatter = DateFormatter()
            hourMinuteFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
            return hourMinuteFormatter.string(from: Date())
        }
    }
    
    var selectedDate: String {
        get {
            let dateIndex = datePicker.selectedRow(inComponent: 0)
           return dates[dateIndex]
        }
    }
    
    var selectedTime: String {
        get {
            let timeIndex = datePicker.selectedRow(inComponent: 1)
            return times[timeIndex]
        }
    }
    
//    var shouldOnlyShowToday: Bool = false
    
    init(openHours: [Weekdays : String], closeHours: [Weekdays : String]) {
        
        self.openTimes = openHours
        self.closeTimes = closeHours
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        timeFormatter.setLocalizedDateFormatFromTemplate("HH mm")
        generateDates()
        let day = Date().getDayOfWeek()
        generateTime(of: Weekdays(rawValue: day)!)
        setupView()
        
    }
    
//    override init(frame: CGRect) {
//        
//        self.openTimes = APPSetting.shared.openHours
//        self.closeTimes = APPSetting.shared.closedHours
//        
//        super.init(frame: frame)
//        //        dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMM dd yyyy")
//        timeFormatter.setLocalizedDateFormatFromTemplate("HH mm")
//        generateDates()
//        let day = Date().getDayOfWeek()
//        generateTime(of: Weekdays(rawValue: day)!)
//        setupView()
//        
//    }
    
    
    private func setupView() {
        
        //        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 8
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.dataSource = self
        datePicker.delegate = self
        
        donebutton.configureTitle(title: "Done")
        donebutton.layer.cornerRadius = 8
        
        addSubview(titleLabel)
        addSubview(donebutton)
        addSubview(datePicker)
        datePicker.backgroundColor = .whiteSmoke
        datePicker.layer.cornerRadius = 8
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            
            datePicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            datePicker.bottomAnchor.constraint(equalTo: donebutton.topAnchor, constant: -8),
            datePicker.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            donebutton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            donebutton.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor),
            donebutton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            donebutton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            
        ])
        
    }
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
        case 0:
            return dates.count
        case 1:
            return times.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component != 0 { return }
        
        let date =  Date.dateOfStringEEEMMddyyyy(dates[row])
        
        guard let day = date?.getDayOfWeek(), let weekday = Weekdays(rawValue: day) else {
            return
        }
        
        generateTime(of: weekday)
        
        if  row == 0 { filterTimesOfToday() }
        
        pickerView.reloadComponent(1)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
        case 0:
            if row == 0 {
                if dates[row] == Date.dateOfDayEEEMMddyyyy() {
                    filterTimesOfToday()
                    return "Today"
                }
            }
            
            
            return String(dates[row].dropLast(6))
            
        case 1:
            guard row < times.count else { return nil }
            return times[row]
            
        default:
            return nil
        }
    }
    
    
    private func generateDates() {
        
        // generate dates for 14 days
        var j = 13
        
        // Check if today is already closed
        if let closedHourOfToday = closeTimes[Weekdays(rawValue: dayOfTheWeek)!] {
            //If today is closed, remove today from dates,
            let time = closedHourOfToday.split(separator: ":")
            let lastCallHour = Int(time[0])! - 1
            if currentTime > "\(lastCallHour):30" {
                j = 14
            }
        }
        
        for i in 0...j {
            dates.append(Date.dateOfDayEEEMMddyyyy(after: i))
        }
        if j == 14 {
            dates.removeFirst()
        }
    }
    
    private func generateTime(of weekday: Weekdays) {
        
        
        guard let open = openTimes[weekday], let close = closeTimes[weekday] else { return }
        
        var tempTimes: [String] = []
        
        var starHour = Int(open.split(separator: ":")[0])!
        let closeHour = Int(close.split(separator: ":")[0])!
        
        if starHour == 24 {
            starHour = 0
        }
        
        for i in starHour...closeHour - 1 {
            //Generates time for each 15 mins from open - close (last call)
            let minutes = ["00", "15", "30", "45"]
            let hour = i < 10 ? "0\(i)" : "\(i)"
            minutes.forEach { (minute) in
                tempTimes.append("\(hour):\(minute)")
            }
        }
        tempTimes.removeLast()
        
        times = tempTimes

    }
    
    private func filterTimesOfToday() {
        
        times = times.filter { (time) -> Bool in
            time > currentTime
        }
        
    }
    
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
