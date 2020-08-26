//
//  RoundCartButton.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-10.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class RoundCartButton: UIView {
    
    let containerView = UIView()
    let cornerRadius: CGFloat = 32
    private var shadowLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false

        layoutView()
        
        let imageView = UIImageView(image: UIImage(named: "blackCart"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.75),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75),
            
        ])
        
        
    }
    
    
    private func layoutView() {
         
         // set the shadow of the view's layer
//         layer.backgroundColor = UIColor.clear.cgColor
//         layer.shadowColor = UIColor.black.cgColor
//         layer.shadowOffset = CGSize(width: 5, height: 5)
//         layer.shadowOpacity = 0.5
//         layer.shadowRadius = 1.0
           
         // set the cornerRadius of the containerView's layer
         containerView.layer.cornerRadius = cornerRadius
         containerView.layer.masksToBounds = true
         
         addSubview(containerView)
         
         //
         // add additional views to the containerView here
         //
         
         // add constraints
         containerView.translatesAutoresizingMaskIntoConstraints = false
         
         // pin the containerView to the edges to the view
         containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
         containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
         containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
         containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
       }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()

            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 4, height: 4)
            shadowLayer.shadowOpacity = 0.3
            shadowLayer.shadowRadius = 3

            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
