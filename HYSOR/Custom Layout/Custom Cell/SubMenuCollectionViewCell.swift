//
//  MenuCollectionViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-12.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class SubMenuCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }   
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l.text = "Name"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16)
        l.text = "Name"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    private let detailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16)
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
    
    private let seperator: UIView = {
        let v = UIView()
        v.backgroundColor = .whiteSmoke
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    //    private let favoriteButton = UIButton(type: .custom)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(nameLabel)
        contentView.addSubview(foodImageView)
        contentView.addSubview(detailLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview((seperator))
        backgroundColor = .white
 
        NSLayoutConstraint.activate([
            
            
            foodImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            foodImageView.heightAnchor.constraint(equalToConstant: 96),
            foodImageView.widthAnchor.constraint(equalTo: foodImageView.heightAnchor),
            foodImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            nameLabel.trailingAnchor.constraint(equalTo: foodImageView.leadingAnchor, constant: 8),
            
            detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            //            detailLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.25),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            detailLabel.trailingAnchor.constraint(equalTo: foodImageView.leadingAnchor, constant: 8),
            
            priceLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 16),
            //            priceLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.25),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
//            priceLabel.trailingAnchor.constraint(equalTo: foodImageView.leadingAnchor, constant: 8),
            
            seperator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            seperator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            seperator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            seperator.heightAnchor.constraint(equalToConstant: 2),
            
            
            
        ])
    }
    
    func configureCellWith(meal: Meal) {
        
        nameLabel.text = meal.name
        detailLabel.text = meal.details
        
        if meal.price == 0 {
            
            if let price = meal.preferences?[0].preferenceItems[0].price {
                priceLabel.text = "$\(price.amount.stringRepresentation)"
            } else {
                if let preferences = meal.preferences {
                    for p in preferences {
                        if let price = p.preferenceItems[0].price {
                            
                            priceLabel.text = "$\(price.amount.stringRepresentation)"
                            break
                        }
                    }
                }
            }
            
        } else {
            //MARK: - TODO
       
            print("p \(meal.price)  \(Money(amt: meal.price).amount)")

            priceLabel.text = "$\(Money(amt: meal.price).amount.stringRepresentation)"
        }
        
        if let imageURL = meal.imageURL {
//            foodImageView.image = UIImage(named: imageURL)
            LocalFileManager.shared.fetchImage(imageURL: imageURL) { (image) in
                
                guard let image = image else {
                    print("can not fetch \(imageURL) for meal \(meal.uid)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.foodImageView.image = image
                }
                
            }
        }
        
        
        
       
        
    }
    

    
    override func prepareForReuse() {
        foodImageView.image = nil
    }
    
    //    @objc private func favoriteButtonTapped() {
    //
    //        favoriteButton.setImage(UIImage(named: "heartFilled"), for: .normal)
    //
    //    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
