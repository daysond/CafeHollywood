//
//  AccountTableViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-25.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
   private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "title"
        l.numberOfLines = 1
        l.textColor = .darkGray
        l.textAlignment = .left
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return l
    }()
    
    private let contentLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = ""
        l.numberOfLines = 0
        l.textAlignment = .left
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        return l
    }()
    
    private let indicatorLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = ">"
        l.numberOfLines = 1
        l.textAlignment = .center
        l.textColor = .darkGray
        l.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(indicatorLabel)
        
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
        
            indicatorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            indicatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            indicatorLabel.widthAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: indicatorLabel.leadingAnchor, constant: -8),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
        
        ])
        
    }
    
    func configureCellForField(_ field: AccountField) {
        
        titleLabel.text = field.rawValue.uppercased()
        
        switch field {
        
        case .email:
            contentLabel.text = APPSetting.customerEmail
            
        case .name:
            contentLabel.text = APPSetting.customerName
            
        case .phone:
            contentLabel.text = APPSetting.customerPhoneNumber
            
        case .password:
            contentLabel.text = "******"
            
        default:
            return
        }
        

    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
