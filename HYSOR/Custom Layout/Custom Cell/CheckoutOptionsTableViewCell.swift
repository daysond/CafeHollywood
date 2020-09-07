//
//  CheckoutOptionsTableViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

protocol CheckoutOptionCellDelegate {
    func didTapChangeButton(at indexPath: IndexPath)
}

class CheckoutOptionsTableViewCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    private let rowImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    private let rowSubImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    private let rowTitleLabel: UILabel = {
         let l = UILabel()
         l.translatesAutoresizingMaskIntoConstraints = false
         l.font = UIFont.systemFont(ofSize: 16)
         l.text = "Name"
         l.numberOfLines = 0
         l.textColor = .gray
         l.textAlignment = .left
         return l
     }()
    
     let rowSubLabel: UILabel = {
         let l = UILabel()
         l.translatesAutoresizingMaskIntoConstraints = false
         l.font = UIFont.systemFont(ofSize: 14)
         l.text = "Name"
         l.numberOfLines = 0
         l.textColor = .black
         l.textAlignment = .left
         return l
     }()
    
     private let changeButton: UIButton = {
        let b = UIButton()
        b.setTitle("CHANGE", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14)
        b.setTitleColor(.systemBlue, for: .normal)
        b.setTitleColor(.gray, for: .highlighted)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    var delegate: CheckoutOptionCellDelegate?
    var indexPath: IndexPath?

      override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(rowImageView)
        contentView.addSubview(rowTitleLabel)
        contentView.addSubview(rowSubLabel)
        contentView.addSubview(changeButton)
     
        changeButton.addTarget(self, action: #selector(didTapChangeButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
        
            changeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            changeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            changeButton.heightAnchor.constraint(equalToConstant: 32),
            changeButton.widthAnchor.constraint(equalToConstant: 64),
            
            rowImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            rowImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            rowImageView.heightAnchor.constraint(equalToConstant: 18),
            rowImageView.widthAnchor.constraint(equalToConstant: 18),
            
            rowTitleLabel.centerYAnchor.constraint(equalTo: rowImageView.centerYAnchor),
            rowTitleLabel.leadingAnchor.constraint(equalTo: rowImageView.trailingAnchor, constant: 16),
            rowTitleLabel.heightAnchor.constraint(equalToConstant: 22),
            rowTitleLabel.trailingAnchor.constraint(equalTo: changeButton.leadingAnchor, constant: -8),
            
            rowSubLabel.leadingAnchor.constraint(equalTo: rowTitleLabel.leadingAnchor),
            rowSubLabel.trailingAnchor.constraint(equalTo: rowTitleLabel.trailingAnchor),
            rowSubLabel.topAnchor.constraint(equalTo: rowTitleLabel.bottomAnchor, constant: 8),
            rowSubLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        

        ])
        
        
    }
    
    func configureCell(with option: CustomOption) {
        
        rowImageView.image = UIImage(named: option.mainImageNmae)
        rowTitleLabel.text = option.mainTitle
        rowSubLabel.text = option.subTitle
        
    }
    
    @objc private func didTapChangeButton() {
        
        guard let indexPath = self.indexPath else { return }
        self.delegate?.didTapChangeButton(at: indexPath)
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    

}



