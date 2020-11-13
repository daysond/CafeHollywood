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
    let logInMethod: AccountField
    private var email: String?
    private var name: String?
    private var password: String?
    private var code: String?
    

    
    var delegate: AuthStatusUpdateDelegate?
    
    init(field: AccountField, isLogin: Bool) {
        self.isLogin = isLogin
        self.logInMethod = field
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
    
    //MARK: SET UP
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
        self.resendButton.isHidden = (field != .verification)
        
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
    

    //MARK: BUTTON TAPPED
    
    override func handleButtonTapped() {
        
        if !shouldProceed() {
            return
        }
        
        view.endEditing(true)
        
        switch field {
        
        case .email:
            setText()
            switchField(isLogin ? .password : .name)

        case .name:
            setText()
            switchField(.password)
            
        case .password:
            
            if isLogin {
                setText()
                signIn()
            } else {
                setText()
                switchField(.phone)
            }
            
        case .phone:
            
            if phoneNumber != nil && phoneNumber == profileTextField.text {
                //which means phonenumber has set, code should have been sent
                profileTextField.text = nil
                switchField(.verification)
                return
            }
            // new phone number or first time
            setText()
            verify()
            
        case .verification:
            setText()
            isLogin ? signIn() : signUp()
            
        default:
            return
        }
        
       
        
    }
    
    
    override func handleBackButton() {
        
        switch field {
        case .email:
            self.navigationController?.dismiss(animated: true, completion: nil)
        case .name:
            switchField(.email)
            
        case .password:
            switchField(isLogin ? .email : .name)
            
        case .phone:
            if isLogin && logInMethod == .phone {
                self.navigationController?.dismiss(animated: true, completion: nil)
                return
            }
            switchField(.password)
        
        case .verification:
            switchField(.phone)
            
        default:
            return
        }
        
    }
    
    //MARK: - HELPERS
    
    override func isPasswordSame(_ text: String) -> Bool {
        if isLogin { return true }
        return super.isPasswordSame(text)
    }
    
    

    
    
    //MARK: - SWITCH FIELDS
    
    private func switchField(_ field: AccountField) {
        
        self.field = field
        setupDisplay()
        if field == .phone {
            profileTextField.clearButtonMode = .never
        } else {
            profileTextField.clearButtonMode = .always
        }
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
        
        let shouldEmptyField = isLogin ? AccountField.password : AccountField.verification
        
        if field != shouldEmptyField {
            //empty text field for next
            profileTextField.text = nil
        }
        
    }
    
    
    
    //MARK: - NETWORKING
    

    
    private func verify() {
        
        verifyPhoneNumber {
     
                self.switchField(.verification)
                self.startTimerForVerificationCode()
            }
        
    }
    
    private func signIn() {
        showSpinner()
        logInMethod == .email ? emailSignIn() : phoneSignIn()
    }
    
    private func emailSignIn() {
        
        guard let email = email, let password = password else { return }
        
        NetworkManager.shared.signInWith(email, password) { (authResult, error) in
            
            DispatchQueue.main.async {
                self.removeSpinner()
            }

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
    
    private func phoneSignIn() {
        
        guard let code = code else {
            return
        }
        
        NetworkManager.shared.signInWithPhoneNumber(verificationCode: code) { (authResult, error) in
            
            DispatchQueue.main.async {
                self.removeSpinner()
            }
            
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
        
        showSpinner()
        
        guard let email = email, let password = password, let name = name, let code = code else { return }
        
        DispatchQueue.global(qos: .background).async {

                let res = NetworkManager.shared.signUpWith(email, password, name ,code)
                
                switch res {
                
                case .success:
                    DispatchQueue.main.async {
                        self.removeSpinner()
                        self.navigationController?.dismiss(animated: true, completion: {
                            self.delegate?.didSignUp()
                        })
                    }

                case .failure(let err):
                    DispatchQueue.main.async {
          
                    self.removeSpinner()
                    self.displayMessage(err.localizedDescription)
                    }
                }
            
        }
    }
    
    
    
    
    
}
