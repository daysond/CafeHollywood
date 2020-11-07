//
//  FavouriteTableViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-11.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class FavouriteTableViewCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "title"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    
    let detailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = ""
        l.textAlignment = .left
        l.textColor = .black
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return l
    }()
    
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "price"
        l.textAlignment = .left
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    //
    private let indicatorView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "check")
        v.translatesAutoresizingMaskIntoConstraints = false
        //        v.backgroundColor = .green
        v.layer.masksToBounds = true
        return v
    }()
    
//    private let customizeButton: UIButton = {
//        let b = UIButton()
//        b.setTitle("Mofidy", for: .normal)
//        b.titleLabel?.font = .systemFont(ofSize: 14)
//        b.setTitleColor(.starYellow, for: .normal)
//        b.setTitleColor(.gray, for: .highlighted)
//        b.translatesAutoresizingMaskIntoConstraints = false
//        return b
//    }()
    
    let customizeButton = UIButton(type: .custom)
    
    
    var isCellSelected: Bool {
        didSet {
            indicatorView.isHidden = !isCellSelected
            
        }
    }
    var indexPath: IndexPath?
    
    
    let modifyButtonWidth: CGFloat = 28
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        isCellSelected = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .whiteSmoke
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(indicatorView)
        contentView.addSubview(customizeButton)
        //
        //        indicatorView.layer.cornerRadius = 16
        
        customizeButton.setImage(UIImage(named: "pencil"), for: .normal)
        customizeButton.translatesAutoresizingMaskIntoConstraints = false
        customizeButton.addTarget(self, action: #selector(didTapModifyButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            indicatorView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 22),
            indicatorView.widthAnchor.constraint(equalToConstant: 22),
            indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            titleLabel.leadingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: customizeButton.leadingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            detailLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            customizeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customizeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customizeButton.widthAnchor.constraint(equalToConstant: modifyButtonWidth),
            customizeButton.heightAnchor.constraint(equalTo: customizeButton.widthAnchor),
            //             customizeButton.heightAnchor.constraint(equalToConstant: 24),
            
            
            
        ])
        
    }
    
    func configureCellWithMeal(_ meal: Meal) {
        
        titleLabel.text = meal.name
        priceLabel.text = "$\(meal.totalPrice.amount.stringRepresentation)"
        
        var details = ""
        
        if let instruction = meal.instruction {
            
            details = meal.addOnInfo == "" ? "Note: \(instruction)" : meal.addOnInfo + "\n\nNote: \(instruction)"
            
        } else {
            details = meal.addOnInfo
        }
        
        if meal.isModificationRequired {
            details = "Please select the required fileds from meal."
        }
        
        detailLabel.textColor = meal.isModificationRequired ? .red : .black
        
        detailLabel.text = details
        
        isCellSelected  =  meal.isSelected
        //        itemPrice = preference.price
    }
    
    override func prepareForReuse() {
        detailLabel.textColor = .black
    }
    
    @objc private func didTapModifyButton() {
        
        guard let indexPath = self.indexPath else { return }
        let data = ["index": indexPath.row] as [String: Int]
        NotificationCenter.default.post(name: .didTapModifyButton, object: self, userInfo: data)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
