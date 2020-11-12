//
//  ReceiptTableViewHeader.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-16.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class OrderHistoryTableViewHeader: UIView {
    
//    private let headerImageView = DimmedImageView()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.text = "Cafe Hollywood"
        l.numberOfLines = 1
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    
    private let statusImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFill
        return imageview
        
    }()
    
    private let statusLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        l.text = "Order Completed"
        l.numberOfLines = 1
        l.textColor = .white
        l.textAlignment = .left
        return l
    }()
    
    private let dateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.text = "Sun Jan 01 2019"
        l.numberOfLines = 1
        l.textColor = .white
        l.textAlignment = .left
        return l
    }()
    
//    private let orderIDLabel: UILabel = {
//        let l = UILabel()
//        l.translatesAutoresizingMaskIntoConstraints = false
//        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        l.text = "AS23AS"
//        l.numberOfLines = 1
//        l.textColor = .black
//        l.textAlignment = .left
//        return l
//    }()
//
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .smokyBlack
        layer.cornerRadius = 4
//        addSubview(headerImageView)
        addSubview(titleLabel)
        addSubview(statusImageView)
        addSubview(statusLabel)
        addSubview(dateLabel)
//        addSubview(orderIDLabel)
        
        NSLayoutConstraint.activate([
            
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            //36
            dateLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
//          //22
//            orderIDLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
//            orderIDLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            //18+8
            statusImageView.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            statusImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8), //16
            statusImageView.heightAnchor.constraint(equalToConstant: 18),
            statusImageView.widthAnchor.constraint(equalToConstant: 18),
            
            statusLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor, constant: 13),
            statusLabel.centerYAnchor.constraint(equalTo: statusImageView.centerYAnchor),

//            16
            
            //total height = 100
        
        
        ])
        
    }
    
    func configureHeader(orderStatus: OrderStatus, timestamp: String, orderID: String) {
        let ts = Double(timestamp)
        let date = Date.dateFromTimestamp(ts!)
        let dateInStr = Date.dateInYYYYMMddFromDate(date)
        
        statusImageView.image = orderStatus.image
        
        statusLabel.text = orderStatus.status
        dateLabel.text = "\(dateInStr)  Order# \(orderID)"
//        orderIDLabel.text = "Order# \(orderID)"
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
