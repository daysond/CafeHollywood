//
//  ReceiptTableViewFooter.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-16.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class ReceiptTableViewFooter: UIView {

    private let totalLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        l.text = "Total: $999.99"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    private let tipLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18)
        l.text = ""
        l.numberOfLines = 0
        l.textColor = .darkGray
        l.textAlignment = .left
        return l
    }()
    
    private let viewReceiptButton = BlackButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(totalLabel)
        addSubview(tipLabel)
        addSubview(viewReceiptButton)
        
        viewReceiptButton.configureTitle(title: "View Receipt")
        
        NSLayoutConstraint.activate([
        
            totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            totalLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            tipLabel.leadingAnchor.constraint(equalTo: totalLabel.trailingAnchor, constant: 16),
            tipLabel.topAnchor.constraint(equalTo: totalLabel.topAnchor),
            
            viewReceiptButton.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 16),
            viewReceiptButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            viewReceiptButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            viewReceiptButton.heightAnchor.constraint(equalToConstant: 48),
        
            // height = 16 + 18 + 16 + 48 + 16 = 114
    
        ])

        
    }
    
    func configureFooter(total: String, tip: String?) {
        
        totalLabel.text = "Toal: $\(total)"
        
        tipLabel.text = tip ?? ""
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
}
