//
//  MenuCollectionViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-07.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    let menuImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFit
        imageview.backgroundColor = .white
        return imageview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(menuImageView)
        
        NSLayoutConstraint.activate([
            
            menuImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            menuImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            menuImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            menuImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
        ])
    }
    
    func configureCellWith(imageURL: String) {
        
        menuImageView.image = UIImage(named: imageURL)

    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
