//
//  RecepitTableViewHeader.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-03.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class RecepitTableViewHeader: UIView {

    private let orderIDLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        l.text = "Order#"
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
    
    private let customerNameLabel: UILabel = {
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
    
    private let phoneNumberLabel: UILabel = {
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
        
        addSubview(orderIDLabel)
        addSubview(customerNameLabel)
        addSubview(noteTitleLabel)
        addSubview(noteDetailLabel)
        addSubview(phoneNumberLabel)
        addSubview(dateLabel)
        
        
        NSLayoutConstraint.activate([
            
            orderIDLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32), //32 + 22 = 54
            orderIDLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            dateLabel.centerYAnchor.constraint(equalTo: orderIDLabel.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: orderIDLabel.trailingAnchor, constant: 16),
            
            customerNameLabel.topAnchor.constraint(equalTo: orderIDLabel.bottomAnchor, constant: 8), //54 + 16 + 22 = 92
            customerNameLabel.leadingAnchor.constraint(equalTo: orderIDLabel.leadingAnchor),
            
            noteTitleLabel.leadingAnchor.constraint(equalTo: orderIDLabel.leadingAnchor), // 92 + 22 + 16 = 130
            noteTitleLabel.topAnchor.constraint(equalTo: customerNameLabel.bottomAnchor, constant: 8),
            
            noteDetailLabel.leadingAnchor.constraint(equalTo: noteTitleLabel.trailingAnchor, constant: 4),
            noteDetailLabel.centerYAnchor.constraint(equalTo: noteTitleLabel.centerYAnchor),
            
            phoneNumberLabel.leadingAnchor.constraint(equalTo: customerNameLabel.trailingAnchor, constant: 16),
            phoneNumberLabel.centerYAnchor.constraint(equalTo: customerNameLabel.centerYAnchor), // 130 + 8
        
        
        ])

    }
    
    func configureHeader(orderID: String, name: String, payment: String, timestamp: String) {
        
        orderIDLabel.text = orderID
        customerNameLabel.text = name
        noteDetailLabel.text = payment
        dateLabel.text = Date.dateInYYYYMMddFromDate(Date.dateFromTimestamp(Double(timestamp)!))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}

