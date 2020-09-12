//
//  SetProfileViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-05.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

protocol AuthStatusUpdateDelegate {
    
    func didLogIn()
    func didSignUp()
    
}

class AuthViewController: UpdateProfileViewController {
    
    let isLogin: Bool
    
    private var email: String?
    private var name: String?
    private var phoneNumber: String?
    private var password: String?
    
    var delegate: AuthStatusUpdateDelegate?
    
    init(field: AccountField, isLogin: Bool) {
        self.isLogin = isLogin
        super.init(field: field)
        shouldAnimateKeyboard = false
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setButtonTitle()
    }
    
    
    private func setButtonTitle() {
        
        switch field {
        case .password:
            
            let title = isLogin ? "LOG IN" : "SIGN UP"
            updateButton.configureSubtitle(title: title)
            
        default:
            updateButton.configureTitle(title: "NEXT")
        }
        
        
    }
    
    override func setupDisplay() {
        
        displayMessage("")
        profileFieldTitle.text = "ENTER YOUR \(field.rawValue.uppercased())"
        profileTextField.isSecureTextEntry = false
        self.passwordTFHeightConstraint?.constant = 0
        
        
        switch field {
        
        case .name:
            
            profileFieldTitle.text = "TELL US YOUR NAME"
            profileTextField.placeholder = "NAME"
            profileTextField.keyboardType = .default
            if name != nil {
                profileTextField.text = name!
            }
            
        case .email:
            
            profileTextField.placeholder = "EMAIL ADDRESS"
            profileTextField.keyboardType = .emailAddress
            if email != nil {
                profileTextField.text = email!
            }
            
        case .phone:
            
            profileTextField.placeholder = "PHONE NUMBER"
            profileTextField.keyboardType = .phonePad
            if phoneNumber != nil {
                profileTextField.text = phoneNumber!
            }
            
        case .password:
            
            if isLogin == false {
                
                passwordTFHeightConstraint?.constant = 40
                
            }
          
            profileTextField.isSecureTextEntry = true
            profileTextField.keyboardType = .alphabet
            profileTextField.placeholder =  isLogin ? "PASSWORD" : "Enter New Password"
            passwordTextField.placeholder = "Re-Enter New Password"
            
        default:
            return
        }
    }
    
    override func isPasswordSame(_ text: String) -> Bool {
        if isLogin { return true }
        return super.isPasswordSame(text)
    }
    
    
    
    override func handleButtonTapped() {
        
        if !shouldProceed() {
            return
        }
        
        setText()
        
        switch field {
        
        case .email:
         
            switchField(isLogin ? .password : .name)

        case .name:
           
            switchField(.phone)
            
        case .phone:
            guard let phoneNumber = phoneNumber else { return }
            NetworkManager.shared.verifyPhoneNumber(phoneNumber) { (verificationID) in
                
                print(verificationID)
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                DispatchQueue.main.async {
                    self.switchField(.password)
                }
                
            }
            
            
        case .password:
            
            isLogin ? signIn() : signUp()
            
        default:
            return
        }
        
    }
    
    
    override func handleBackButton() {
        
        switch field {
        case .email:
            self.navigationController?.popViewController(animated: true)
            
        case .name:
            switchField(.email)
            
        case .phone:
            switchField(.name)
            
        case .password:
            switchField(isLogin ? .email : .phone)
        default:
            return
        }
        
    }
    
    //MARK: - HELPERS
    
    private func switchField(_ field: AccountField) {
        
        self.field = field
        setupDisplay()
        profileTextField.resignFirstResponder()
        profileTextField.becomeFirstResponder()
    }
    
    private func setText() {
        
        switch field {
        case .email:
            email = profileTextField.text
        case .name:
            name = profileTextField.text
        case .password:
            password = profileTextField.text
        case .phone:
            phoneNumber = profileTextField.text
        default:
            break
        }
        
        if field != .password {
            profileTextField.text = nil
        }
        
        
    }
    
    private func signIn() {

        
        guard let email = email, let password = password else { return }
        
        NetworkManager.shared.signInWith(email, password) { (authResult, error) in
            guard error ==  nil else {
                DispatchQueue.main.async {
                    self.displayMessage(error!.localizedDescription)
                }
                return
            }
            
            guard authResult != nil else {
                DispatchQueue.main.async {
                    self.displayMessage("Unknow error.")
                }
                return
            }
            
            self.navigationController?.dismiss(animated: true, completion: {
            
                self.delegate?.didLogIn()
            
            })
           
            
        }
    }
    
    @objc private func signUp() {
        
        guard let email = email, let password = password, let name = name, let phoneNumber = phoneNumber else { return }
        
        DispatchQueue.global(qos: .background).async {
            
            
            let res = NetworkManager.shared.signUpWith(email, password, name, phoneNumber)
            
            switch res {
            
            case .success:
                
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true, completion: {
                    
                        self.delegate?.didSignUp()
                    })
                    
                    
                    
                }
                
            case .failure(let err):
                DispatchQueue.main.async {
                    self.displayMessage(err.localizedDescription)
                }
            }
        }
        
        
        
    }
    
    
}
