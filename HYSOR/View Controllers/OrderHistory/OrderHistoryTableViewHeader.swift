//
//  ReceiptTableViewHeader.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-16.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class OrderHistoryTableViewHeader: UIView {
    
    private let headerImageView = DimmedImageView()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.text = "BIG TITLE BIG TITLE BIG TITLE TITLETITLE TITLETITLE TITLETITLE"
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
        l.textColor = .black
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
    
    private let orderIDLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.text = "AS23AS"
        l.numberOfLines = 1
        l.textColor = .white
        l.textAlignment = .left
        return l
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(headerImageView)
        addSubview(titleLabel)
        addSubview(statusImageView)
        addSubview(statusLabel)
        addSubview(dateLabel)
        addSubview(orderIDLabel)
        
        NSLayoutConstraint.activate([
            
            headerImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),  // 8
            headerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerImageView.widthAnchor.constraint(equalTo: widthAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 100),  //100
            
            titleLabel.centerXAnchor.constraint(equalTo: headerImageView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: headerImageView.widthAnchor, multiplier: 0.8),
            titleLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -8),
  
            dateLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: headerImageView.centerYAnchor),
            
            orderIDLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            orderIDLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            
            statusImageView.leadingAnchor.constraint(equalTo: headerImageView.leadingAnchor),
            statusImageView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 16), //16
            statusImageView.heightAnchor.constraint(equalToConstant: 18),
            statusImageView.widthAnchor.constraint(equalToConstant: 18),
            
            statusLabel.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 8),
            statusLabel.centerYAnchor.constraint(equalTo: statusImageView.centerYAnchor),


            
            //total height = 140
        
        
        ])
        
    }
    
    func configureHeader(orderStatus: OrderStatus, timestamp: String, orderID: String, restaurantName: String) {
        let ts = Double(timestamp)
        let date = Date.dateFromTimestamp(ts!)
        let dateInStr = Date.dateInYYYYMMddFromDate(date)
        
        statusImageView.image = orderStatus.image
        
        statusLabel.text = orderStatus.status
        titleLabel.text = restaurantName
        dateLabel.text = dateInStr
        orderIDLabel.text = "Order# \(orderID)"
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
