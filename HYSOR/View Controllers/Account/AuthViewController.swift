//
//  AuthViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-01.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import FirebaseUI


class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        let loginButton = BlackButton()
        loginButton.configureTitle(title: "log in")
        loginButton.translatesAutoresizingMaskIntoConstraints = true
        loginButton.frame = CGRect(x: 16, y: 100, width: view.frame.width - 32, height: 48)
        
        view.addSubview(loginButton)
        
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    @objc private func handleLogin() {
        
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else {
            
            //log error
            
            return
        }
        
        authUI?.delegate = self

        let providers: [FUIAuthProvider] = [FUIEmailAuth(), FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!)]
        authUI?.providers = providers
//
        let authVC = authUI!.authViewController()
   
        present(authVC, animated: true, completion: nil)
        
        
        
        
    }
    
    private func presentMainViewController() {
        
        let mainVC = MainTabBarViewController()
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true) {
            print("completed")
        }

    }
    
    



}

extension AuthViewController: FUIAuthDelegate {
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        guard error == nil else {
            print(error)
            return
        }
        
        guard let uid = authDataResult?.user.uid,
        let name = authDataResult?.user.displayName,
        let email = authDataResult?.user.email else { return }
        
        let phnenumber = authDataResult?.user.phoneNumber
        
        print("\(uid) singed in \(name) \(phnenumber) \(email)" )
        
//        APPSetting.storeUserInfo(email, name, uid, phnenumber)
        
        presentMainViewController()
        
        
    }
    
    
    
    
}
