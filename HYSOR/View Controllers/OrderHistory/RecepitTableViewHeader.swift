//
//  RecepitTableViewHeader.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-03.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class RecepitTableViewHeader: UIView {

    private let restaurantNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        l.text = "Order#"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
//    private let dateLabel: UILabel = {
//        let l = UILabel()
//        l.translatesAutoresizingMaskIntoConstraints = false
//        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
//        l.text = "647-123-4678"
//        l.numberOfLines = 1
//        l.textColor = .darkGray
//        l.textAlignment = .left
//        return l
//    }()
    
    private let orderIDLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        l.text = "Name: John Apple "
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()

    private let noteTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        l.text = "Note:"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    private let noteDetailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        l.text = "this is note"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    private let dateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        l.text = "647-123-4678"
        l.numberOfLines = 1
        l.textColor = .darkGray
        l.textAlignment = .left
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(restaurantNameLabel)
        addSubview(orderIDLabel)
        addSubview(noteTitleLabel)
        addSubview(noteDetailLabel)
        addSubview(dateLabel)
        
        
        NSLayoutConstraint.activate([
            
            restaurantNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32), //32 + 22 = 54
            restaurantNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            orderIDLabel.topAnchor.constraint(equalTo: restaurantNameLabel.bottomAnchor, constant: 8), //54 + 16 + 22 = 92
            orderIDLabel.leadingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor),
            
            noteTitleLabel.leadingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor), // 92 + 22 + 16 = 130
            noteTitleLabel.topAnchor.constraint(equalTo: orderIDLabel.bottomAnchor, constant: 8),
            
            noteDetailLabel.leadingAnchor.constraint(equalTo: noteTitleLabel.trailingAnchor, constant: 4),
            noteDetailLabel.centerYAnchor.constraint(equalTo: noteTitleLabel.centerYAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: orderIDLabel.trailingAnchor, constant: 16),
            dateLabel.centerYAnchor.constraint(equalTo: orderIDLabel.centerYAnchor), // 130 + 8
        
        
        ])

    }
    
    func configureHeader(orderID: String, restaurantName: String, note: String, timestamp: String) {
        
        restaurantNameLabel.text = restaurantName
        orderIDLabel.text = orderID
        noteDetailLabel.text = note
        dateLabel.text = Date.dateInYYYYMMddFromDate(Date.dateFromTimestamp(Double(timestamp)!))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}

