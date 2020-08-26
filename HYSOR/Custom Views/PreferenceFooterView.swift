//
//  PreferenceFooterView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-06-30.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

protocol PreferenceFooterViewDelegate {
    func updateMealQuantityTo(_ quantity: Int)
    func removeItemFromCart()
}

class PreferenceFooterView: UIView {
    
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
    
    
    private let quantityLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        return l
    }()
    
    private let specialInstructionTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Special Instructions:"
        l.textAlignment = .left
        l.textColor = .black
        l.backgroundColor = .white
        l.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return l
    }()
    
    let instructionTextLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Any special instructions?"
        l.numberOfLines = 0
        l.textAlignment = .left
        l.textColor = .gray
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        l.isUserInteractionEnabled = true
        return l
    }()
    
    private let removeItemButton: UIButton = {
        let b = UIButton()
        b.setTitle("Remove Item", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        b.setTitleColor(.red, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    var delegate: PreferenceFooterViewDelegate?
    
    var shouldDisplayRemoveButton: Bool = false {
        didSet {
            displayRemoveButton()
        }
    }
    
    var isNewMeal: Bool = true {
        didSet {
            shouldDisplayRemoveButton = !isNewMeal
        }
    }
    
    var quantity: Int = 1 {
        didSet {
            minusButton.isEnabled = isNewMeal ? quantity > 1 : quantity > 0
            quantityLabel.text = "\(quantity)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        isUserInteractionEnabled = true
//        backgroundColor = .yellow
        addSubview(specialInstructionTitleLabel)
        addSubview(instructionTextLabel)
        addSubview(quantityLabel)
        addSubview(addButton)
        addSubview(minusButton)
       
        
        addButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
//        minusButton.isEnabled = false
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(instructionLabelTapped))
//        instructionTextLabel.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            
            specialInstructionTitleLabel.topAnchor.constraint(equalTo: topAnchor),
            specialInstructionTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            specialInstructionTitleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.97),
            specialInstructionTitleLabel.heightAnchor.constraint(equalToConstant: 48),
            
            instructionTextLabel.topAnchor.constraint(equalTo: specialInstructionTitleLabel.bottomAnchor, constant: 0),
            instructionTextLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            instructionTextLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            instructionTextLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            quantityLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            quantityLabel.heightAnchor.constraint(equalToConstant: 56),
            quantityLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 56),
            quantityLabel.topAnchor.constraint(equalTo: instructionTextLabel.bottomAnchor, constant: 16),
            
            minusButton.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor),
            minusButton.trailingAnchor.constraint(equalTo: quantityLabel.leadingAnchor, constant: -16),
            minusButton.widthAnchor.constraint(equalToConstant: 40),
            minusButton.heightAnchor.constraint(equalToConstant: 40),
            
            addButton.centerYAnchor.constraint(equalTo: quantityLabel.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 16),
            addButton.widthAnchor.constraint(equalToConstant: 40),
            addButton.heightAnchor.constraint(equalToConstant: 40),
            
        ])
        
        displayRemoveButton()

        
        
        
    }
    
    private func displayRemoveButton() {
        
        if shouldDisplayRemoveButton {
            addSubview(removeItemButton)
            removeItemButton.addTarget(self, action: #selector(removedButtonTapped), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                
                removeItemButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                removeItemButton.widthAnchor.constraint(equalTo: widthAnchor),
                removeItemButton.heightAnchor.constraint(equalToConstant: 32),
                removeItemButton.topAnchor.constraint(equalTo: quantityLabel.bottomAnchor, constant: 8),
            
            ])
            
        }
        

        
    }
    
    //-MARK: ACTIONS
    

    
    @objc func buttonTapped(sender: UIButton) {
        
        quantity = sender === addButton ? quantity + 1 : quantity - 1
        quantityLabel.text = "\(quantity)"
        self.delegate?.updateMealQuantityTo(quantity)
    }
    
    @objc func removedButtonTapped() {
        
        self.delegate?.removeItemFromCart()
    }
    
}
