//
//  PreferenceTableViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-20.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class PreferenceTableViewCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "title"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    
    let detailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = ""
        l.textAlignment = .left
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return l
    }()
    
    let priceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "price"
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    
    let indicatorView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "check")
        v.translatesAutoresizingMaskIntoConstraints = false
//        v.backgroundColor = .green
        v.layer.masksToBounds = true
        return v
    }()
    
    var isCellSelected: Bool {
        didSet {
            indicatorView.isHidden = !isCellSelected
            
        }
    }
    
    //    var itemPrice: Money?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        isCellSelected = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
//        contentView.addSubview(detailLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(indicatorView)
//
//        indicatorView.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            
            indicatorView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 22),
            indicatorView.widthAnchor.constraint(equalToConstant: 22),
            indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            titleLabel.leadingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: 8),
//            titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 3.0/5.0),
//            titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
//            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
//            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
//            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            
            
        ])
        
    }
    
    func configureCellWithPreference(_ preference: PreferenceItem) {
        
        titleLabel.text = preference.name
        //        detailLabel.text = preference.detail
        priceLabel.text = (preference.price != nil) ? "$\(String(describing: preference.price!.amount.stringRepresentation))" : ""
        isCellSelected  = preference.isSelected
        //        itemPrice = preference.price
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
