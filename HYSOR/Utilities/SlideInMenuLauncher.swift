//
//  SlideInMenuLauncher.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import UIKit

class SlideInMenuLauncher: NSObject {
    
    let blackView: UIView
    
    let menuView: UIView
    
    let menuHeight: CGFloat
    
    var cornerRadius: CGFloat = 0
    
    
    init(blackView: UIView, menuView: UIView, menuHeight height: CGFloat) {
        self.menuView = menuView
        self.menuHeight = height
        self.blackView = blackView
        super.init()

    }
    
    init(blackView: UIView, menuView: UIView, menuHeight height: CGFloat, menuViewCornerRadius: CGFloat) {
        self.menuView = menuView
        self.menuHeight = height
        self.blackView = blackView
        super.init()
        cornerRadius = menuViewCornerRadius
    }
    
    func showMenu() {
        
        if let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.frame = keyWindow.frame
            blackView.alpha = 0

            keyWindow.addSubview(blackView)
            keyWindow.addSubview(menuView)
               
            
            let y = keyWindow.frame.height - menuHeight - 16
            
            menuView.frame = CGRect(x: 0, y: keyWindow.frame.height, width: keyWindow.frame.width, height: menuHeight)
            menuView.clipsToBounds = true
            menuView.layer.cornerRadius = cornerRadius
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.menuView.frame = CGRect(x: 0, y: y, width: self.menuView.frame.width, height: self.menuView.frame.height)
                
            })
            
            
        }
        
    }
    
    
    @objc func dismissMenu() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            if let keyWindow = UIApplication.shared.connectedScenes
                 .filter({$0.activationState == .foregroundActive})
                 .map({$0 as? UIWindowScene})
                 .compactMap({$0})
                 .first?.windows
                 .filter({$0.isKeyWindow}).first {
            
            self.blackView.alpha = 0
            
                self.menuView.frame = CGRect(x: 0, y: keyWindow.frame.height, width: self.menuView.frame.width, height: self.menuView.frame.height)
            
            }
        }, completion: nil)
        
        
    }
    
    
    
    
}
