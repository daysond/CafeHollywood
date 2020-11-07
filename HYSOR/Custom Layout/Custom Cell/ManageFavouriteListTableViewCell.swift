//
//  ManageFavouriteListTableViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-26.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class ManageFavouriteListTableViewCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        l.text = "Name"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 17)
        l.text = "Name"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    private let detailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 17)
        l.text = "Name"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    private let foodImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(foodImageView)
        contentView.addSubview(detailLabel)
        contentView.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            
            
            foodImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            foodImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -16),
            foodImageView.widthAnchor.constraint(equalTo: foodImageView.heightAnchor),
            foodImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: foodImageView.leadingAnchor, constant: 0),
            
            detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailLabel.trailingAnchor.constraint(equalTo: foodImageView.leadingAnchor, constant: 0),
            
            priceLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 16),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priceLabel.trailingAnchor.constraint(equalTo: foodImageView.leadingAnchor, constant: 0),
            

        ])
        
        
    }
    
    func configureCellWith(meal: Meal) {
        
        nameLabel.text = meal.name
        detailLabel.text = meal.details
        
        if meal.price == 0 {
            
            if let price = meal.preferences?[0].preferenceItems[0].price {
                priceLabel.text = "$\(price.amount)"
            } else {
                priceLabel.text = ""
            }
            
        } else {
            //MARK: - TODO
            priceLabel.text = "$\(meal.price)"
        }
        
        if let imageURL = meal.imageURL {
            foodImageView.image = UIImage(named: imageURL)
        }
        
    }
    
    override func prepareForReuse() {
        foodImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
