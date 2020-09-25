//
//  CheckoutViewControllerExt.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import UIKit

extension CheckoutViewController: CheckoutOptionCellDelegate, InstructionInputDelegate {
        
    func didTapChangeButton(at indexPath: IndexPath) {
        
        let option = options[indexPath.row]
        
        switch option.optionType {
            
        case .utensil:
            option.subTitle =  option.subTitle == "Yes please!" ? "No thanks!" : "Yes please!"

        case .scheduler:
            handleScheduler()
            
//        case .payment:
//            handlePayment()
            
        case .note:
            
            let instructionVC = InstructionsInputViewController(title: "Note")
            instructionVC.delegate = self
            instructionVC.textView.text = option.subTitle == Constants.checkoutNoteHolder ? "" : option.subTitle
            
            let nav = UINavigationController(rootViewController: instructionVC)
            present(nav, animated: true, completion: nil)
        default:
            return
        }
        
        optionsTableView.reloadData()
    }
    
//    private func handlePayment() {
//
//        let creditCardButton = BlackButton()
//        creditCardButton.configureButton(headTitleText: "Credit/Debit Card", titleColor: .black, backgroud: UIColor.white)
//        creditCardButton.addTarget(self, action: #selector(didTapCreditCardButton), for: .touchUpInside)
//
//        let payAtStoreButton = BlackButton()
//        payAtStoreButton.configureButton(headTitleText: "Pay At Restaurant", titleColor: .black, backgroud: UIColor.white)
//        payAtStoreButton.addTarget(self, action: #selector(didTapPayAtStoreButton), for: .touchUpInside)
//
//        let cancelButton = BlackButton()
//        cancelButton.configureTitle(title: "Cancel")
//        cancelButton.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
//
//        let menuStackView = UIStackView(arrangedSubviews: [creditCardButton, payAtStoreButton, cancelButton])
//        menuStackView.axis = .vertical
//        menuStackView.distribution = .fillEqually
//        menuStackView.spacing = 0
//
//        let height = Constants.kOrderButtonHeightConstant * 3 + 40
//        launchMenu(view: menuStackView, height: height)
//
//    }
    
    private func handleScheduler() {
        let schedulerView = SchedulerView()
        self.scheduelerView = schedulerView
        scheduelerView?.shouldOnlyShowToday = true
        schedulerView.donebutton.addTarget(self, action: #selector(schedulerViewDismiss), for: .touchUpInside)
        launchMenu(view: schedulerView, height: 300)
        
    }
    
    private func launchMenu(view: UIView, height: CGFloat) {
    
        let blackView = UIView()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tapGes)
        blackView.isUserInteractionEnabled = true
        
        let menuLauncher = SlideInMenuLauncher(blackView: blackView, menuView: view, menuHeight: height)
        self.menuLauncher = menuLauncher
        menuLauncher.showMenu()
        
        
        
    }
    
    //MARK: - ACTIONS
    
    @objc func schedulerViewDismiss() {
        let time = self.scheduelerView?.selectedTime ?? "Now"
        
        Cart.shared.pickupTime = time == "Now" ? nil : time
        
        updateOptionOfType(.scheduler, with: time)
        menuLauncher?.dismissMenu()
    }

    @objc func dismissMenu() {
        menuLauncher?.dismissMenu()
    }
    
//    @objc func didTapCreditCardButton() {
//        
//        menuLauncher?.dismissMenu()
//        paymentMethod = .online
//        paymentContext?.pushPaymentOptionsViewController()
//    }
//    
//    @objc func didTapPayAtStoreButton() {
//        
//        paymentMethod = .inStore
//        updateOptionOfType(.payment, with: "Pay at the restaurant")
//        menuLauncher?.dismissMenu()
//    }
    
    //MARK: - HELPERS
    
    private func updateOptionOfType(_ type: CustomOptionType, with text: String) {
        
        for (index,option) in options.enumerated() {
            if option.optionType == type {
                option.subTitle = text
                optionsTableView.beginUpdates()
                optionsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                optionsTableView.endUpdates()
                break
            }
        }
    }
    
    //MARK: - INPUT DELEGATE
    
    func didInputInstructions(_ instructions: String) {
        
        Cart.shared.orderNote = instructions
        updateOptionOfType(.note, with: instructions == "" ? Constants.checkoutNoteHolder : instructions)

    }
    
    
    
    
}
