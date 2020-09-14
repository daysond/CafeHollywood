//
//  MenuButton.swift
//  ProjectGym
//
//  Created by Dayson Dong on 2019-07-07.
//  Copyright © 2019 Dayson Dong. All rights reserved.
//

import UIKit

class ActionButton: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label: UILabel = {
       let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "button"
        l.textColor = .white
        l.backgroundColor = .black85
        l.font = UIFont.systemFont(ofSize: 12)
        l.textAlignment = .center
        return l
    }()
    
    let button: RoundedButton = {
        let b = RoundedButton()
        b.backgroundColor = .starYellow
        return b
    }()
    
    func setupView() {
        
        translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.layer.cornerRadius = 4

        addSubview(button)
        addSubview(label)
        
//        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        NSLayoutConstraint.activate([
            
            button.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            button.widthAnchor.constraint(equalTo: widthAnchor, constant: -32),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
//            label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width + 8),
            
            ])
        
        
        
    }

}


class RoundedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height / 2.0
        clipsToBounds = true
    }

}
