//
//  ResturantCollectionViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-12.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class ResturantCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "resturantCollectionViewCell"
    
    let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 17)
        l.text = "Name"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    let resturantImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(nameLabel)
        contentView.addSubview(resturantImageView)
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            
            
            resturantImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            resturantImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            resturantImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            resturantImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: resturantImageView.bottomAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        
        ])
    }
    
    func configureCellWith(resturant: Resturant) {
        
        nameLabel.text = resturant.name
        resturantImageView.image = UIImage(named: resturant.imageURL)
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    

}
