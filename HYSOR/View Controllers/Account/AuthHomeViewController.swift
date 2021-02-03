//
//  AuthViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-01.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
//import FirebaseUI


class AuthHomeViewController: UIViewController {
//
//    private let backgroundView: UIImageView = {
//        let iv = UIImageView()
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        iv.image = UIImage(named: "authBackground")
//        iv.contentMode = .scaleAspectFill
//        return iv
//    }()
//
    private let backgroundView = DimmedImageView()
    
    private let loginButton = BlackButton()
    
    private let signupButton = BlackButton()
    
    private var loginMethod: AccountField?
    
    private let titleLable: UILabel = {
       let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = .whiteSmoke
        l.font = .systemFont(ofSize: 48, weight: .bold)
        l.text = "CAFE\nHOLLYWOOD"
        return l
    }()
    
    private let since1994Label: UILabel = {
        let l = UILabel()
         l.translatesAutoresizingMaskIntoConstraints = false
         l.numberOfLines = 0
         l.textAlignment = .center
         l.textColor = .whiteSmoke
         l.font = .systemFont(ofSize: 40, weight: .medium)
         l.text = "SINCE 1994"
         return l
     }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
       
        

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setupView() {
        
        
        view.backgroundColor = .smokyBlack
        backgroundView.setImage(UIImage(named: "authBackground")!, alpha: 0.5)
        view.addSubview(backgroundView)
        view.addSubview(loginButton)
        view.addSubview(signupButton)
        view.addSubview(titleLable)
        view.addSubview(since1994Label)
        
        loginButton.configureButton(headTitleText: "LOG IN", titleColor: .black, backgroud: .white)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        signupButton.configureButton(headTitleText: "SIGN UP", titleColor: .black, backgroud: .white)
        signupButton.layer.cornerRadius = 4
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
        
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLable.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -view.frame.height * 0.2),
            titleLable.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            
            since1994Label.widthAnchor.constraint(equalTo: titleLable.widthAnchor),
            since1994Label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            since1994Label.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: 48),
            
            
            loginButton.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 32),
            loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3),
            loginButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            signupButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3),
            signupButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        

        ])
        
        
        
    }
    
    @objc private func handleLogin() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.view.tintColor = .black
        
        alert.addAction(UIAlertAction(title: "Log In with Email", style: .default, handler: { [self] (_) in
            self.loginMethod = .email
            self.presentAuthVC(isLogin: true)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Log In with Phone", style: .default, handler: { (_) in
            self.loginMethod = .phone
            self.presentAuthVC(isLogin: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alert, animated: true)

        
    }
    
    @objc private func handleSignup() {
        
        presentAuthVC(isLogin: false)

    }
    
    private func presentAuthVC(isLogin: Bool) {
        
        var field: AccountField = .email
        
        if isLogin {
            
            guard let method = loginMethod else { return }
            field = method
        }
        
        let authVC = AuthViewController(field: field, isLogin: isLogin)
        authVC.delegate = self
        
        let navc = UINavigationController(rootViewController: authVC)
        navc.modalPresentationStyle = .popover
        present(navc, animated: true, completion: nil)

        
    }
    

    
    private func presentMainViewController() {
        
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: .didAuthUser, object: nil)
        }
        
//        let mainVC = MainTabBarViewController()
//        mainVC.modalPresentationStyle = .fullScreen
//        self.present(mainVC, animated: true) {
//            NotificationCenter.default.post(name: .authStateDidChange, object: nil, userInfo: ["isAuth": true])
//        }

    }
    

}

extension AuthHomeViewController: AuthStatusUpdateDelegate {
    
    func didLogIn() {
//        print(NetworkManager.shared.currentUser?.email)
        presentMainViewController()
    }
    
    func didSignUp() {
//        print(NetworkManager.shared.currentUser?.email)
        presentMainViewController()
    }
    
}


