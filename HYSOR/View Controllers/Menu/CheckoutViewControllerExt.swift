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
            
        case .note:
            
            let instructionVC = InstructionsInputViewController(title: "Note")
            instructionVC.delegate = self
            instructionVC.textView.text = option.subTitle == Constants.checkoutNoteHolder ? "" : option.subTitle
            
            let nav = UINavigationController(rootViewController: instructionVC)
            present(nav, animated: true, completion: nil)
            
        case .gift:
            
            navigationController?.pushViewController(GiftOptionViewController(handler: didFinishChoosingGiftOption), animated: true)
            
            return
            
        default:
            return
        }
        
        optionsTableView.reloadData()
    }
    

    
    private func handleScheduler() {
        guard let openHours = APPSetting.shared.openHours, let closeHours = APPSetting.shared.closedHours else {
            showError(message: "Network Error. Can not fetch business hour information.")
            return
        }
        let schedulerView = SchedulerView(openHours: openHours, closeHours: closeHours)
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
    

    
    //MARK: - HELPERS
    
    private func didFinishChoosingGiftOption() {
        let text = Cart.shared.selectedGiftOption == nil ? "None" : Cart.shared.selectedGiftOption!.name
        updateOptionOfType(.gift, with: text)
        
    }
    
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
