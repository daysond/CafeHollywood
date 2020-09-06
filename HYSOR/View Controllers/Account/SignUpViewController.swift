//
//  GoogleAuthViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-12.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {
    
    private let bag = DisposeBag()
    
    private let logoImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .left
        l.textColor = .black
        l.text = "Create your Account"
        l.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return l
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 20)
        tf.addPadding(.left(16))
        tf.placeholder = "Email"
        //        tf.layer.cornerRadius = 16
        //        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let nameTextfield: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 20)
        tf.textColor = .black
        tf.borderStyle = .roundedRect
        tf.placeholder = "Name"
        tf.addPadding(.left(16))
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let passwordTextfield: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 20)
        tf.textColor = .black
        tf.borderStyle = .roundedRect
        //        tf.layer.cornerRadius = 16
        tf.placeholder = "Password"
        tf.addPadding(.left(16))
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let confirmPasswordTextfield: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 20)
        tf.placeholder = "Confirm Password"
        tf.addPadding(.left(16))
        tf.textColor = .black
        //        tf.layer.cornerRadius = 16
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let hintLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .left
        l.textColor = .black
        l.numberOfLines = 0
        l.text = "Create your Account ans this is your hint"
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return l
    }()
    
    private let optionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        l.textColor = .black
        l.numberOfLines = 0
        l.text = "\n\n- Or sign up with -"
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return l
    }()
    
    private let googleButton: BlackButton = {
       let b = BlackButton()
        b.configureButton(headTitleText: "G", subtitleText: "")
        return b
    }()
    
    private let facebookButton: BlackButton = {
       let b = BlackButton()
         b.configureButton(headTitleText: "F", subtitleText: "")
        return b
    }()
    
    private let appleButton: BlackButton = {
       let b = BlackButton()
         b.configureButton(headTitleText: "A", subtitleText: "")
        return b
    }()
    
    private let authButton = BlackButton()
    
    private var isEmailValid = false {
        didSet{
            isFormValid()
        }
    }
    private var isPasswordValid = false {
        didSet{
            isFormValid()
        }
    }
    private var isPasswordConfirmed = false {
        didSet{
            isFormValid()
        }
    }
    
    private var isNameValid = false {
        didSet{
            isFormValid()
        }
    }
    
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupRX()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false 
    }
    
    
    //MARK: - SET UP VIEW
    
    private func setupView() {
        
        view.backgroundColor = .white
        authButton.configureButton(headTitleText: "Sign Up", titleColor: .white, backgroud: .gray)
        authButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        authButton.isEnabled = false
        
        let signUpOptionStackView = UIStackView(arrangedSubviews: [googleButton, facebookButton, appleButton])
        signUpOptionStackView.axis = .horizontal
        signUpOptionStackView.distribution = .fillEqually
        signUpOptionStackView.spacing = 16
        
        let mainStackview = UIStackView(arrangedSubviews: [titleLabel, emailTextField, nameTextfield, passwordTextfield, confirmPasswordTextfield, hintLabel, authButton, optionLabel, signUpOptionStackView])
        mainStackview.translatesAutoresizingMaskIntoConstraints = false
        mainStackview.axis = .vertical
        mainStackview.distribution = .fillEqually
        mainStackview.spacing = 16
        emailTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        view.addSubview(mainStackview)
        
        NSLayoutConstraint.activate([
            
            mainStackview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            mainStackview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            

        ])
        
        
        
    }
    
    private func setupRX() {
        
        emailTextField.rx.controlEvent(.editingDidBegin).withLatestFrom(emailTextField.rx.text.orEmpty)
            .subscribe(onNext: { (text) in
                self.hintLabel.text = "Please enter your Email address."
            }).disposed(by: bag)
        
        emailTextField.rx.controlEvent(.editingDidEnd).withLatestFrom(emailTextField.rx.text.orEmpty)
            .subscribe(onNext: { (text) in
                if !self.isEmailValid {
                    self.hintLabel.text = "Invalid Email Address."
                }
                
            }).disposed(by: bag)
        
        passwordTextfield.rx.controlEvent(.editingDidBegin).withLatestFrom(passwordTextfield.rx.text.orEmpty)
            .subscribe(onNext: { (password) in
               
                    self.hintLabel.text = "Your password should be at least one letter, one digit and minimum 6 characters."
                
            }).disposed(by: bag)
        
        passwordTextfield.rx.controlEvent(.editingDidEnd).withLatestFrom(passwordTextfield.rx.text.orEmpty)
            .subscribe(onNext: { (password) in
                if !self.isPasswordValid {
                    self.hintLabel.text = "Invalid password! Password should be 6 or more characters and include at least 1 digit and 1 letter."
                }
            }).disposed(by: bag)
        
        nameTextfield.rx.controlEvent(.editingDidBegin).withLatestFrom(nameTextfield.rx.text.orEmpty)
            .subscribe(onNext: { (password) in
               
                    self.hintLabel.text = "Please tell us your name."
                
            }).disposed(by: bag)
        
        nameTextfield.rx.controlEvent(.editingDidEnd).withLatestFrom(nameTextfield.rx.text.orEmpty)
            .subscribe(onNext: { (password) in
                if !self.isNameValid {
                    self.hintLabel.text = "Invalid characters in name. Please try again."
                }
            }).disposed(by: bag)
        
        
        confirmPasswordTextfield.rx.controlEvent(.editingDidBegin).withLatestFrom(confirmPasswordTextfield.rx.text.orEmpty)
             .subscribe(onNext: { (password) in
                
                     self.hintLabel.text = "Please re-enter your password."
                 
             }).disposed(by: bag)
        
        confirmPasswordTextfield.rx.controlEvent(.editingDidEnd).withLatestFrom(confirmPasswordTextfield.rx.text.orEmpty)
             .subscribe(onNext: { (password) in
                if !self.isPasswordConfirmed {
                    self.hintLabel.text = "Password does not match."
                }
             }).disposed(by: bag)
        
        //Validation
        
        emailTextField.rx.controlEvent(.editingChanged).withLatestFrom(emailTextField.rx.text.orEmpty)
            .subscribe(onNext: { (text) in
                self.isEmailValid = self.isValidEmail(text)
            }).disposed(by: bag)
        
        nameTextfield.rx.controlEvent(.editingChanged).withLatestFrom(nameTextfield.rx.text.orEmpty)
            .subscribe(onNext: { (name) in
                self.isNameValid = self.isValidName(name.trimmingCharacters(in: CharacterSet(charactersIn: " ")))
            }).disposed(by: bag)
        
        
        passwordTextfield.rx.controlEvent(.editingChanged).withLatestFrom(passwordTextfield.rx.text.orEmpty)
            .subscribe(onNext: { (password) in
                self.isPasswordValid = self.isValidPassword(password)
            }).disposed(by: bag)
        
        
        confirmPasswordTextfield.rx.controlEvent(.editingChanged).withLatestFrom(confirmPasswordTextfield.rx.text.orEmpty)
            .subscribe(onNext: { (confirmPassword) in
                self.isPasswordConfirmed = confirmPassword == self.passwordTextfield.text
            }).disposed(by: bag)
    }
    
    //MARK: - ACTIONS
    
    @objc private func signUp() {
        
        guard let email = emailTextField.text, let password = passwordTextfield.text, let name = nameTextfield.text else { return }
        
        APPSetting.customerName = nameTextfield.text!
        
        self.hintLabel.text = "Signing up ..."
        
        DispatchQueue.global(qos: .background).async {
            
            // 1. Sign up at google if succeed, use userResult to create a Stripe account, if fail, prompt error
            // 2. Stripe account created: set data on dataBase , if fail present view controller anyways
            // 3. after setting data, push view controller.
            
            let res = NetworkManager.shared.signUpWith(email, password, name, "")
            
            switch res {
                
            case .success:
                
                DispatchQueue.main.async {
                    
                    self.presentMainViewController()

                }
                
            case .failure(let err):
                DispatchQueue.main.async {
                    
                    switch NetworkManager.shared.isAuth{
                    
                    case true:

                       self.presentMainViewController()
                        
                    case false:
                    
                        self.hintLabel.text = err.localizedDescription
                    }
                }
            }
        }
        
        
        
    }
    
    //MARK: -HELPERS
    
    private func presentMainViewController() {
        
        let mainVC = MainTabBarViewController()
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true) {
            print("completed")
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordPred = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9]).{6,}$")
        return passwordPred.evaluate(with: password.lowercased())
    }
    
    private func isValidName(_ name: String) -> Bool {
        guard name.count > 1, name.count < 18 else { return false }
        let namePred = NSPredicate(format: "SELF MATCHES %@", "^(([^ ]?)(^[a-zA-Z].*[a-zA-Z]$)([^ ]?))$")
        return namePred.evaluate(with: name)
        
    }
    
    private func isFormValid() {
        
        authButton.isEnabled = isEmailValid && isPasswordValid && isPasswordConfirmed && isNameValid
        authButton.backgroundColor = authButton.isEnabled ? .black : .gray
        
    }
    
}
