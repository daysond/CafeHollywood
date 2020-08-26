//
//  MyTableViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-25.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
   private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "title"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
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
        contentView.addSubview(indicatorLabel)
        
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
        
            indicatorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            indicatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            indicatorLabel.widthAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: indicatorLabel.leadingAnchor, constant: -8),
            
        
        
        ])
        
    }
    
    func configureCellForField(_ field: AccountField) {
        
        titleLabel.text = field.rawValue
        
        if field == .about {
            indicatorLabel.isHidden = true
        }

    }
    
    override func prepareForReuse() {
        indicatorLabel.isHidden = false
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
