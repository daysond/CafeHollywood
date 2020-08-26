//
//  MultiQuantityPreferenceTableViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-06-29.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

protocol MultiQuantityCellDelegate {
    func didTapMinusButton(at indexPath: IndexPath)
    func didTapAddButton(at indexPath: IndexPath)
}

class MultiQuantityPreferenceTableViewCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var delegate: MultiQuantityCellDelegate?
    
    let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "title"
        l.textColor = .black
        l.textAlignment = .left
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    
    let priceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "price"
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    
    let totalPriceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "price"
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    
     private let addButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "add"), for: .normal)
        b.setImage(UIImage(named: "addDisable"), for: .disabled)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let minusButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "minus"), for: .normal)
        b.setImage(UIImage(named: "minusDisable"), for: .disabled)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let quantityLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "99"
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return l
    }()
    
    var isCellSelected: Bool {
        didSet {
            shouldShowQuantity(isCellSelected)
        }
    }
    
    var shouldDisableAddButton: Bool = false {
        didSet {
            addButton.isEnabled = !shouldDisableAddButton
        }
    }
    
    var indexPath: IndexPath?
    
    
    var minusButtonLeadingAnchor: NSLayoutConstraint?
    var minusButtonWidthAnchor: NSLayoutConstraint?
    var quantityLabelLeadingAnchor: NSLayoutConstraint?
    var quantityLabelWithAnchor: NSLayoutConstraint?
    
    //    var itemPrice: Money?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        isCellSelected = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        contentView.addSubview(titleLabel)
        //             contentView.addSubview(detailLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(addButton)
        contentView.addSubview(minusButton)
        contentView.addSubview(quantityLabel)
        
        addButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
         minusButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        //        contentView.addSubview(indicatorView)
        
        //        indicatorView.layer.cornerRadius = 16
        
        minusButtonLeadingAnchor = minusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0)
        minusButtonWidthAnchor = minusButton.widthAnchor.constraint(equalToConstant: 0)
        quantityLabelLeadingAnchor =   quantityLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 0)
        quantityLabelWithAnchor = quantityLabel.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            
            minusButtonLeadingAnchor!,
            minusButton.heightAnchor.constraint(equalToConstant: 24),
            minusButtonWidthAnchor!,
            minusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            quantityLabelLeadingAnchor!,
            quantityLabel.heightAnchor.constraint(equalToConstant: 28),
            quantityLabelWithAnchor!,
            quantityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 8),
            addButton.heightAnchor.constraint(equalToConstant: 24),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            priceLabel.widthAnchor.constraint(equalToConstant: 60),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
        ])
        
    }
    
    @objc func buttonTapped(sender: UIButton) {
        
        guard let indexPath = self.indexPath else { return }
        
        switch sender {
        case addButton:
            delegate?.didTapAddButton(at: indexPath)
        case minusButton:
             delegate?.didTapMinusButton(at: indexPath)
        default:
            break
        }
        
        
    }
    
    func shouldShowQuantity(_ shouldShow: Bool) {
        
        UIView.animate(withDuration: 0.25) {
            shouldShow ? self.openButtons() : self.closeButtons()
            self.layoutIfNeeded()
        }
        
    }
    
    func configureCellWithPreference(_ preferenceItem: PreferenceItem, shouldDisableAddButton: Bool) {
        
        titleLabel.text = preferenceItem.name
        //        detailLabel.text = preference.detail
        priceLabel.text = (preferenceItem.price != nil) ? "$\(String(describing: preferenceItem.price!.amount.stringRepresentation))" : ""
        quantityLabel.text = "\(preferenceItem.quantity)"
        isCellSelected  = preferenceItem.isSelected
        isCellSelected ? openButtons() : closeButtons()
        self.shouldDisableAddButton = shouldDisableAddButton
        //        itemPrice = preference.price
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        isCellSelected ? openButtons() : closeButtons()
        addButton.isEnabled = !shouldDisableAddButton
        
    }
    
    // -MARK: Helpers
    
    private func openButtons() {
        self.minusButtonLeadingAnchor!.constant = 8
        self.minusButtonWidthAnchor!.constant = 24
        self.quantityLabelLeadingAnchor!.constant = 8
        self.quantityLabelWithAnchor!.constant = 28
    }
    
    private func closeButtons() {
        self.minusButtonLeadingAnchor!.constant = 0
        self.minusButtonWidthAnchor!.constant = 0
        self.quantityLabelLeadingAnchor!.constant = 0
        self.quantityLabelWithAnchor!.constant = 0
    }
    
    
    
    
}
