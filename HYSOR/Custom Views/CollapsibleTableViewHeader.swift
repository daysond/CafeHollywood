//
//  CollapsibleTableViewHeader.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-21.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import UIKit

protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(header: CollapsibleTableViewHeader, section: Int)
}

class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        l.text = "title"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    let arrowIndicator: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "plus")
        return iv
    }()
    
    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    var isCollapsed = false
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .whiteSmoke
        contentView.addSubview(arrowIndicator)
        contentView.addSubview(titleLabel)
        

        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            arrowIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant:  -16),
            arrowIndicator.widthAnchor.constraint(equalToConstant: 20),
            arrowIndicator.heightAnchor.constraint(equalToConstant: 20),
            
        
        ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader(gestureRecognizer:))))

    }
    
    @objc func tapHeader(gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
            return
        }
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    func toggled(isCollapsed: Bool) {
        UIView.animate(withDuration: 0.2) {
            
            self.arrowIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(isCollapsed ? 0.0 : Double.pi / 4.0))

        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
