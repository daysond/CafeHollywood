//
//  PaxSizeCollectionViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-11.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class PaxSizeCollectionViewCell: UICollectionViewCell {
    
    
    static var identifier: String {
        return String(describing: self)
    }
    
    private let sizeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        l.text = "1"
        l.numberOfLines = 0
        l.textColor = .white
        l.textAlignment = .left
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        contentView.addSubview(sizeLabel)
        contentView.backgroundColor = .black
        layer.masksToBounds = true
        layer.cornerRadius = 24
        
        
        NSLayoutConstraint.activate([
            
            sizeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            sizeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
               
        ])
        
    }
    
    func configureCellWith(size: Int) {
        
        sizeLabel.text = "\(size)"
        
    }
    
    override func prepareForReuse() {
        contentView.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
