//
//  CartFooterView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-08.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class CartFooterView: UIView {

   private let totalLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.text = "Total"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
   private let subTotalLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        l.text = "Subtotal"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
   private let promitionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        l.text = "Discount"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
   private let discountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        l.text = "Drinks Credit"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    
   private let taxesLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        l.text = "Taxes"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    
   private let totalAmountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.text = "$Total"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .right
        return l
    }()
    
   private let subTotalAmountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        l.text = "$Subtotal"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .right
        return l
    }()
    
   private let promitionAmountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        l.text = "$Promotion"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .right
        return l
    }()
    
   private let discountAmountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        l.text = "$Discount"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .right
        return l
    }()
    
   private let taxesAmountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        l.text = "$taxes"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .right
        return l
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let labelStackView = UIStackView(arrangedSubviews: [subTotalLabel, promitionLabel, discountLabel, taxesLabel, totalLabel])
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.axis = .vertical
        labelStackView.spacing = 16
        labelStackView.distribution = .fillEqually
        
        let amountStackView = UIStackView(arrangedSubviews: [subTotalAmountLabel, promitionAmountLabel, discountAmountLabel, taxesAmountLabel, totalAmountLabel])
        amountStackView.translatesAutoresizingMaskIntoConstraints = false
        amountStackView.axis = .vertical
        amountStackView.spacing = 16
        amountStackView.distribution = .fillEqually

//        let stackView = UIStackView(arrangedSubviews: [labelStackView, amountStackView])
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .horizontal
////        stackView.spacing = 8
//        stackView.distribution = .fillEqually
//
//        addSubview(stackView)
//        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
//        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        
        addSubview(amountStackView)
        amountStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        amountStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        amountStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true

        addSubview(labelStackView)
        labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        labelStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true

        
    }
    
    func updateFooterLabels() {
        
        subTotalAmountLabel.text = "$" + Cart.shared.cartSubtotal.amount.stringRepresentation
        taxesAmountLabel.text = "$" + Cart.shared.cartTaxes.amount.stringRepresentation
        totalAmountLabel.text = "$" + Cart.shared.cartTotal.amount.stringRepresentation
        promitionAmountLabel.text = Cart.shared.promotion == nil ? "$0.00" : "$" + (Cart.shared.promotion?.amount.stringRepresentation)!
        
        discountAmountLabel.text = Cart.shared.discountAmount == nil ? "-$0.00" : "-$" +  Cart.shared.discountAmount!.amount.stringRepresentation
    
    }
    
    func setupFooterViewWithReceipt(_ receipt: Receipt) {
        
        subTotalAmountLabel.text = "$" + Money(amt:receipt.subtotal).amount.stringRepresentation
        taxesAmountLabel.text = "$" + Money(amt:receipt.taxes).amount.stringRepresentation
        totalAmountLabel.text = "$" + Money(amt:receipt.total).amount.stringRepresentation
        promitionAmountLabel.text = Cart.shared.promotion == nil ? "$0.00" : "$" + Money(amt:receipt.promotion).amount.stringRepresentation
        
        discountAmountLabel.text = Cart.shared.discountAmount == nil ? "-$0.00" : "-$" +  Money(amt:receipt.discount).amount.stringRepresentation
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
