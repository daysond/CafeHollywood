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
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.text = "Cafe Hollywood"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    
    private let orderIDLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        l.text = "ID "
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()

    
    private let noteDetailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        l.numberOfLines = 0
        l.textColor = .red
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

        addSubview(noteDetailLabel)
        addSubview(dateLabel)
        
        
        NSLayoutConstraint.activate([
            
            restaurantNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16), //32 + 22 = 54
            restaurantNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            orderIDLabel.topAnchor.constraint(equalTo: restaurantNameLabel.bottomAnchor, constant: 8), //54 + 16 + 22 = 92
            orderIDLabel.leadingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor),
            
            noteDetailLabel.leadingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor),
            noteDetailLabel.topAnchor.constraint(equalTo: orderIDLabel.bottomAnchor, constant: 8),
            noteDetailLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            
            dateLabel.leadingAnchor.constraint(equalTo: orderIDLabel.trailingAnchor, constant: 16),
            dateLabel.centerYAnchor.constraint(equalTo: orderIDLabel.centerYAnchor), // 130 + 8
        
        
        ])

    }
    
    func configureHeader(orderID: String, note: String, timestamp: String) {
        
        orderIDLabel.text = orderID
        noteDetailLabel.text = note
        dateLabel.text = Date.dateInYYYYMMddFromDate(Date.dateFromTimestamp(Double(timestamp)!))
        
    }
    
    func configureHeaderForCurrentTable() {
        
        restaurantNameLabel.text = "Cafe Hollywood"
        orderIDLabel.text = "Table: \(Table.shared.tableNumber ?? "")"
        if let timestamp = Table.shared.timestamp {
            dateLabel.text = Date.dateInYYYYMMddFromDate(Date.dateFromTimestamp(Double(timestamp)!))
        } else {
            dateLabel.text = ""
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}

