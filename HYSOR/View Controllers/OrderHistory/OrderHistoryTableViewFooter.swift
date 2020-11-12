//
//  ReceiptTableViewFooter.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-16.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class OrderHistoryTableViewFooter: UIView {

    private let totalLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        l.text = "Total: $999.99"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
//
//    private let tipLabel: UILabel = {
//        let l = UILabel()
//        l.translatesAutoresizingMaskIntoConstraints = false
//        l.font = UIFont.systemFont(ofSize: 18)
//        l.text = ""
//        l.numberOfLines = 0
//        l.textColor = .darkGray
//        l.textAlignment = .left
//        return l
//    }()
//

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(totalLabel)
//        addSubview(tipLabel)
    
        
        
        
        NSLayoutConstraint.activate([
        
            totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            totalLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
//
//            tipLabel.leadingAnchor.constraint(equalTo: totalLabel.trailingAnchor, constant: 16),
//            tipLabel.topAnchor.constraint(equalTo: totalLabel.topAnchor),
            

            // height = 16 + 18 + 16 + 48 + 16 = 114
    
        ])

        
    }
    
    func configureFooter(total: String) {
        
        totalLabel.text = "Toal: $\(total)"
   
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
}
