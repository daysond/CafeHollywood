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
    
    private var dates: [String] = ["Today"]
    private var time: [String] = []
    private var timeOfToday: [String] = []
    private var timeOfAll: [String] = []
    
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    
    private let startTimes: [Weekdays : String]
    private let endTimes: [Weekdays: String]
    
    private let weekendOpenHour: String
    private let weekendClosedHour: String
    private let weekdayOpenHour: String
    private let weekdayClosedHour: String

    
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
            var selectedDate = dates[dateIndex]
            if selectedDate == "Today" {
                selectedDate = dateFormatter.string(from: Date())
            }
            return selectedDate

        }
    }
    
    var selectedTime: String {
        get {
            let timeIndex = datePicker.selectedRow(inComponent: 1)
            var selectedTime = time[timeIndex]
            if selectedTime == "Now" && shouldOnlyShowToday == false {
                selectedTime = timeFormatter.string(from: Date())
            }
            return selectedTime
        }
    }
    
    var shouldOnlyShowToday: Bool = false
    
    override init(frame: CGRect) {
        
        self.startTimes = APPSetting.shared.openHours
        self.endTimes = APPSetting.shared.closedHours
        self.weekendOpenHour = startTimes[.friday]!
        self.weekendClosedHour = endTimes[.friday]!
        self.weekdayOpenHour = startTimes[.monday]!
        self.weekdayClosedHour = endTimes[.monday]!

        super.init(frame: frame)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMM dd yyyy")
        timeFormatter.setLocalizedDateFormatFromTemplate("HH mm")
        generateDates()
        setupView()

    }
    
    
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
            return shouldOnlyShowToday ? 1 : dates.count
        case 1:
            return time.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 && row == 0 {
//            time = currentTime > "\(weekendClosedHour):30" ? timeOfAll : timeOfToday
            let closedTimeToday = Date.isWeekDay() ? weekdayClosedHour : weekendClosedHour
            time = currentTime > closedTimeToday ? timeOfAll : timeOfToday
            
        } else {
            
            let selectedRowInFirstComponent = pickerView.selectedRow(inComponent: 0)
            
            if selectedRowInFirstComponent != 0 {
                
                let date = dateFormatter.date(from: dates[selectedRowInFirstComponent])
                
                if let weekday = date?.getDayOfWeek() {
                    // is weekday or weekend ?
                    time = weekday > 5 ? timeOfAll : timeOfAll.filter { $0 < weekdayClosedHour }.dropLast()
                } else {
                    time = timeOfAll
                }
                
            } else {
                time = Date.isWeekDay() ? timeOfAll.filter { $0 < weekdayClosedHour }.dropLast() : timeOfAll
            }
        }
        
        pickerView.reloadComponent(1)

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
        case 0:
            let date = dates[row]
            return date == "Today" ? date : String(date.dropLast(6))
        case 1:
            return time[row]
        default:
            return nil
        }
    }
    
    
    private func generateDates() {
        // generate dates for 14 days
        
        //date of today
        let now = Calendar.current.dateComponents(in: .current, from: Date())
        var j = 13
        
        // see if today is closed/done ...
        let dayOfWeek = Date().getDayOfWeek()
        if let closedHourOfToday = endTimes[Weekdays(rawValue: dayOfWeek)!] {
            let time = closedHourOfToday.split(separator: ":")
            let lastCallHour = time[0]
            if currentTime > "\(lastCallHour):30" {
                dates.removeFirst()
                j = 14
            }
        }
        
        for i in 1...j {
            let comingDay = DateComponents(year: now.year, month: now.month, day: now.day! + i )
            let dateOfComingDay = Calendar.current.date(from: comingDay)!
            dates.append(dateFormatter.string(from: dateOfComingDay))
        }
        
        //8:00 - 23:45
        let starHour = Int(weekendOpenHour.split(separator: ":")[0])!
        let closeHour = Int(weekendClosedHour.split(separator: ":")[0])!
        
        for i in starHour...closeHour-1 {
            
            let minutes = ["00", "15", "30", "45"]
            minutes.forEach { (minute) in
                timeOfAll.append("\(i):\(minute)")
            }
        }
        timeOfAll.removeLast()
        
        let closedTimeToday = Date.isWeekDay() ? weekdayClosedHour : weekendClosedHour
        
        timeOfToday = timeOfAll.filter { (time) -> Bool in
            time > currentTime
        }
        
        timeOfToday = timeOfToday.filter { $0 < closedTimeToday }.dropLast()
        
        if currentTime >= weekendOpenHour {
            timeOfToday.insert("Now", at: 0)
        }
        //model time
       
        time = currentTime > closedTimeToday ? timeOfAll : timeOfToday

    }
    
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
