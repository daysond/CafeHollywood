//
//  CartTableViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-04.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {
    
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
        l.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return l
    }()
    
    let detailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = ""
        l.numberOfLines = 0
        l.textAlignment = .left
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return l
    }()
    
    let priceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "price"
        l.numberOfLines = 1
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return l
    }()
    
    let quantityLabel: UILabel = {
        let l = UILabel()
        l.backgroundColor = UIColor(white: 0.8, alpha: 0.4)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "99"
        l.numberOfLines = 1
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return l
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel)
        addSubview(quantityLabel)
        addSubview(priceLabel)
        addSubview(detailLabel)
    
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            
            quantityLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            quantityLabel.heightAnchor.constraint(equalToConstant: 32),
            quantityLabel.widthAnchor.constraint(equalToConstant: 32),
            quantityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            
            titleLabel.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo:priceLabel.leadingAnchor),
//            titleLabel.heightAnchor.constraint(equalToConstant: 48),
            titleLabel.topAnchor.constraint(equalTo: quantityLabel.topAnchor),
            
            priceLabel.widthAnchor.constraint(equalToConstant: 64),
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            priceLabel.topAnchor.constraint(equalTo: quantityLabel.topAnchor),
            priceLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant:  8),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -8),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
        ])
        
    }
    
    
    func configureCartCellWithMeal(_ meal: Meal) {
  
        titleLabel.text = meal.name
        quantityLabel.text = "\(meal.quantity)"
        priceLabel.text = "$" + meal.totalPrice.amount.stringRepresentation
        var details = ""
        if let instruction = meal.instruction {
            
            details = meal.addOnInfo == "" ? "Note: \(instruction)" : meal.addOnInfo + "\n\nNote: \(instruction)"
            
        } else {
            details = meal.addOnInfo
        }
        
        detailLabel.text = details
        
    }
    
    func configureCellWithMealInfo(_ info: MealInfo) {
        
        titleLabel.text = info.name
        
        quantityLabel.text = "\(info.quantity)"
        
        priceLabel.text = "$" + Money(amt: info.totalPrice).amount.stringRepresentation
        
        var details = ""
        
        if info.instruction != "" {
            
            details = info.addOnInfo == "" ? "Note: \(info.instruction)" : info.addOnInfo + "\n\nNote: \(info.instruction)"
            
        } else {
            details = info.addOnInfo
        }
        
        detailLabel.text = details
        
        
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
