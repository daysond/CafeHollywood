//
//  ReceiptTableViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-16.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class OrderHistoryTableViewCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "title"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        l.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return l
    }()
    
//    let detailLabel: UILabel = {
//        let l = UILabel()
//        l.translatesAutoresizingMaskIntoConstraints = false
//        l.text = ""
//        l.numberOfLines = 0
//        l.textAlignment = .left
//        l.textColor = .black
//        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        return l
//    }()
    
    
    let quantityLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "99"
        l.numberOfLines = 1
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return l
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        addSubview(quantityLabel)
//        addSubview(detailLabel)
    
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            
            quantityLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            quantityLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: quantityLabel.topAnchor),
            
//            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant:  8),
//            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
        ])

        
    }
    
        func configureCellWithMealInfo(_ info: MealInfo) {
        
        titleLabel.text = info.name
        
        quantityLabel.text = "\(info.quantity)"
        
//        priceLabel.text = "$" + Money(amt: info.totalPrice).amount.stringRepresentation
        
//        var details = ""
//
//        if info.instruction != "" {
//
//            details = info.addOnInfo == "" ? "Note: \(info.instruction)" : info.addOnInfo + "\n\nNote: \(info.instruction)"
//
//        } else {
//            details = info.addOnInfo
//        }
//
//        detailLabel.text = details
//
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    

}
