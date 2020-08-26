//
//  DimmedImageView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-16.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class DimmedImageView: UIView {

    private let headerImageView: UIImageView = {
         let imageview = UIImageView()
         imageview.translatesAutoresizingMaskIntoConstraints = false
         imageview.clipsToBounds = true
         imageview.contentMode = .scaleAspectFill
         return imageview
         
     }()
    
    private let blackView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        headerImageView.image = UIImage(named: "pikachu")
        
        addSubview(headerImageView)
        addSubview(blackView)
        
        NSLayoutConstraint.activate([
            
            headerImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            headerImageView.widthAnchor.constraint(equalTo: widthAnchor),
            headerImageView.heightAnchor.constraint(equalTo: heightAnchor),
            
            blackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            blackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            blackView.widthAnchor.constraint(equalTo: widthAnchor),
            blackView.heightAnchor.constraint(equalTo: heightAnchor),
            
        ])
        
    }
    
    func setImage(_ image: UIImage) {
        
        self.headerImageView.image = image
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
