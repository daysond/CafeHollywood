//
//  MenuCollectionHeaderView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-06.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class SubMenuHeaderView: UICollectionReusableView {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    private let headerImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFill
        return imageview
        
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        l.text = "BIG TITLE"
        l.numberOfLines = 1
        l.textColor = .white
        l.textAlignment = .left
        return l
    }()
    
    let detailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18)
        l.text = "some details. tdks sdjs sdaskkv wueif wiu csa sdakjs asjkdh asalksjas skdal whhcbv sascmn wv danmv,"
        l.numberOfLines = 0
        l.textColor = .white
        l.textAlignment = .left
        return l
    }()
    
    var lableStackView: UIStackView?
    var gradientView: UIView?
    
    var image: UIImage? {
        didSet {
            headerImageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(headerImageView)
        NSLayoutConstraint.activate([
            
            headerImageView.topAnchor.constraint(equalTo: topAnchor),
            headerImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
        ])
        
        setupVisualEffectBlur()
        setupGradientLayer()
        
    }
    
    var animator: UIViewPropertyAnimator!
    
     func setupVisualEffectBlur() {
        
        for subview in subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        
        self.addSubview(visualEffectView)
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            visualEffectView.topAnchor.constraint(equalTo: self.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
        ])
        visualEffectView.alpha = 0
        
        animator = UIViewPropertyAnimator(duration: 2.0, curve: .linear, animations: {
   
            visualEffectView.alpha = 1
            
        })
        
        if lableStackView != nil && gradientView != nil {
            bringSubviewToFront(gradientView!)
            bringSubviewToFront(lableStackView!)
        }

        
    }
    
    fileprivate func setupGradientLayer() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black85.cgColor]
        gradientLayer.locations = [0.2,1]
        
        let gradientContainerView = UIView()
        gradientContainerView.translatesAutoresizingMaskIntoConstraints = false 
        gradientContainerView.backgroundColor = .blue
        
        gradientView = gradientContainerView
        
        addSubview(gradientContainerView)
        gradientContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        gradientContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        gradientContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        gradientContainerView.layer.addSublayer(gradientLayer)
        gradientLayer.frame = self.bounds
        gradientLayer.frame.origin.y -= bounds.height
        print("frame \(gradientLayer.frame) y \(gradientLayer.frame.origin.y)")
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        lableStackView = stackView
        addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
