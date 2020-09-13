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
    private var code: String?
    
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
            profileTextField.text = "+1"
            profileTextField.keyboardType = .numberPad
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
            
            if password != nil {
                profileTextField.text = password!
                passwordTextField.text = password!
            }
            
            
        case .verification:
            
            profileTextField.placeholder = "6-DIGIT VERIFICATION CODE"
            profileTextField.keyboardType = .numberPad
            if code != nil {
                profileTextField.text = code!
            }
            
            
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
           
            switchField(.password)
            
        case .password:
            
//            isLogin ? signIn() : signUp()
            isLogin ? signIn() : switchField(.phone)
            
        case .phone:
            print(profileTextField.text)
            verifyPhoneNumber()
            
        case .verification:
            
            signUp()
            
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
            
        case .password:
            switchField(isLogin ? .email : .name)
            
        case .phone:
            switchField(.password)
        
        case .verification:
            switchField(.phone)
            
        default:
            return
        }
        
    }
    
    //MARK: - HELPERS
    
    private func verifyPhoneNumber() {
        
        guard let number = phoneNumber else {
            displayMessage("Please enter a valid phone number.")
            return
            
        }
        
        NetworkManager.shared.verifyPhoneNumber(number) { (verificationID, error) in
            
            
            DispatchQueue.main.async {
                
                guard error == nil else {
                    self.displayMessage(error!.localizedDescription)
                    return
                }
                
                guard let id = verificationID else {
                    self.displayMessage("Unknow Error.")
                    return
                }
                
                APPSetting.storePhoneVerificationID(id)
                
                
                self.switchField(.verification)
            }
        }
    }
    
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
        case .verification:
            code = profileTextField.text
        default:
            break
        }
        
        
        profileTextField.text = nil
//        if field != .password {
//            profileTextField.text = nil
//        }
        
        
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
        
        guard let email = email, let password = password, let name = name, let phoneNumber = phoneNumber, let code = code else { return }
        
        DispatchQueue.global(qos: .background).async {
            
            
            let res = NetworkManager.shared.signUpWith(email, password, name ,code)
            
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
