//
//  ViewOrderButtonView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-17.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class BlackButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet{
            
            let isWhite = self.backgroundColor!.isEqualToColor(.white)
            let isLightGray = self.backgroundColor!.isEqualToColor(.starYellow)
            
            if isWhite || isLightGray {
                 backgroundColor = isHighlighted ? .starYellow : .white
            } else {
                backgroundColor = isHighlighted ? .darkGray : .black
            }
        }
    }
    
    private let headTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18)
        l.text = "View Order"
        l.numberOfLines = 1
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18)
        l.text = ""
        l.numberOfLines = 1
        l.textColor = .white
        l.textAlignment = .right
        return l
    }()
    
    var intrinsicWidth: CGFloat {
        return headTitleLabel.intrinsicContentSize.width
    }
    
//    var titleText: String = "" {
//        didSet{
//             headTitleLabel.text = titleText
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .black
        addSubview(headTitleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            
            headTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            headTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            headTitleLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9),
//            headTitleLabel.widthAnchor.constraint(equalToConstant: 150),
            
            subtitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            subtitleLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9),
//            subtitleLabel.leadingAnchor.constraint(equalTo: headTitleLabel.trailingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
    
    func configureButton(headTitleText: String, titleColor: UIColor, backgroud: UIColor?) {
        
        headTitleLabel.text = headTitleText
        headTitleLabel.textColor = titleColor
        backgroundColor = backgroud ?? .black
    }
    
    func configureButton(headTitleText: String, titleColor: UIColor, subtitleText: String, subtitleColor: UIColor, backgroud: UIColor?) {
        
        headTitleLabel.text = headTitleText
        headTitleLabel.textColor = titleColor
        backgroundColor = backgroud ?? .black
        subtitleLabel.text = subtitleText
        subtitleLabel.textColor = subtitleColor
    }
    
    func configureButton(headTitleText: String, subtitleText: String) {
        
        headTitleLabel.text = headTitleText
        subtitleLabel.text = subtitleText

    }
    
    func configureTitle(title: String) {
        
        headTitleLabel.text = title
    }
    
    func configureSubtitle(title: String) {
        
        subtitleLabel.text = title
    }
}
