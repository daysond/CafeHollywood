//
//  PreferenceHeaderView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-06.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class PreferenceHeaderView: UIView {
    
    private let headerImageView: UIImageView = {
        
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFill
        imageview.backgroundColor = .ghostWhite
        return imageview
        
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        l.text = "BIG TITLE"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    let detailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        l.text = ""
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    let favoriteButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(headerImageView)
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(favoriteButton)
        
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            favoriteButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            
            headerImageView.topAnchor.constraint(equalTo: topAnchor),
            headerImageView.heightAnchor.constraint(equalTo: heightAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleLabel.bottomAnchor.constraint(equalTo: detailLabel.topAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            
            detailLabel.bottomAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -16),
            detailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            detailLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            
        ])
    }
    
    
    
    func configureHeaderViewWith(_ meal: Meal) {
        
        titleLabel.text = meal.name
        detailLabel.text = meal.details
        
        if let imageURL = meal.imageURL {
            
            headerImageView.image = UIImage(named: imageURL)
            titleLabel.textColor = .white
            detailLabel.textColor = .white
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.bounds
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black85.cgColor]
            gradientLayer.locations = [0,1]
            headerImageView.layer.insertSublayer(gradientLayer, at: 0)
            
        }
        
        let heart = meal.isFavourite ? UIImage(named: "heartFilled") : UIImage(named: "heartEmpty")
        
        favoriteButton.setImage(heart, for: .normal)

        
        
    }
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
