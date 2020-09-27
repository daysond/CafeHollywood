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
        
        let businessHours = APPSetting.businessHours
        var tempStartTimes = [Weekdays : String]()
        var tempEndTimes = [Weekdays: String]()
        
        businessHours.forEach { (day, hours) in
            
            let weekday = Weekdays(rawValue: Int(day)!)!
            let splitedHours = hours.split(separator: "-")
            
            tempStartTimes[weekday] = "\(splitedHours[0])"
            tempEndTimes[weekday] = "\(splitedHours[1])"

        }
        
        self.startTimes = tempStartTimes
        self.endTimes = tempEndTimes

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
            time = currentTime > "21:30" ? timeOfAll : timeOfToday
        } else {
            let selectedRowInFirstComponent = pickerView.selectedRow(inComponent: 0)
            if selectedRowInFirstComponent != 0 {
                time = timeOfAll
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
        
        let now = Calendar.current.dateComponents(in: .current, from: Date())
        var j = 13
        
        if currentTime > "21:30" {
            dates.removeFirst()
            j = 14
        }
        
        for i in 1...j {
            let comingDay = DateComponents(year: now.year, month: now.month, day: now.day! + i )
            let dateOfComingDay = Calendar.current.date(from: comingDay)!
            print( " day is \(dateOfComingDay.getDayOfWeek())")
            dates.append(dateFormatter.string(from: dateOfComingDay))
        }
        
        for i in 11...21 {
            
            let minutes = ["00", "15", "30", "45"]
            minutes.forEach { (minute) in
                timeOfAll.append("\(i):\(minute)")
            }
        }
        timeOfAll.removeLast()
        
        
        
        timeOfToday = timeOfAll.filter { (time) -> Bool in
            time > currentTime
        }
        
        if currentTime >= "11:00" {
            timeOfToday.insert("Now", at: 0)
        }
        
        time = currentTime > "21:30" ? timeOfAll : timeOfToday
    }
    
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
