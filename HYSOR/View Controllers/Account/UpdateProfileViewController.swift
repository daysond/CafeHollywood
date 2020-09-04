//
//  UpdateProfileViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-03.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class UpdateProfileViewController: UIViewController {
    
    
    private let field: AccountField
    
    private let updateButton = BlackButton()
    
    private var tabBarHeight: CGFloat = 0
    
    private let profileTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.addPadding(.left(4))
        tf.backgroundColor = .whiteSmoke
        tf.clearButtonMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.addPadding(.left(4))
        tf.isSecureTextEntry = true
        tf.backgroundColor = .whiteSmoke
        tf.clearButtonMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let profileFieldTitle: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .left
        l.textColor = .black
        l.text = "Name"
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return l
    }()
    
    private let errorMessageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .left
        l.textColor = .systemRed
        l.numberOfLines = 5
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return l
    }()
    
    var updateButtonBottomAnchorConstraint: NSLayoutConstraint?
    
    init(field: AccountField) {
        
        self.field = field
        
        super.init(nibName: nil, bundle: nil)
        updateButton.configureTitle(title: "Update \(field.rawValue)")
        

    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateProfileViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateProfileViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupView()
        setupDisplay()
        setupNavigationBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profileTextField.becomeFirstResponder()
    }
    
    
    private func setupDisplay() {
        
        profileFieldTitle.text = field.rawValue
        
        switch field {
        case .name:
            
            profileFieldTitle.text = "First & Last Name"
            profileTextField.text = APPSetting.customerName
            
        case .email:
            
            profileTextField.text = APPSetting.customerEmail
            profileTextField.keyboardType = .emailAddress
            
        case .phone:
            
            profileTextField.text = APPSetting.customerPhoneNumber
            profileTextField.keyboardType = .phonePad
            
        case .password:
            
            profileTextField.isSecureTextEntry = true
            profileTextField.placeholder = "Enter New Password"
            passwordTextField.placeholder = "Re-Enter New Password"
            
        default:
            return
        }

    }
    
    private func setupView() {
        
        view.backgroundColor = .white
        
        updateButton.addTarget(self, action: #selector(UpdateProfileViewController.updateProfile), for: .touchUpInside)
        
        view.addSubview(profileFieldTitle)
        view.addSubview(profileTextField)
        view.addSubview(updateButton)
        view.addSubview(errorMessageLabel)
        
        updateButtonBottomAnchorConstraint = updateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            
            profileFieldTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileFieldTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileFieldTitle.heightAnchor.constraint(equalToConstant: profileFieldTitle.intrinsicContentSize.height),
            
            profileTextField.leadingAnchor.constraint(equalTo: profileFieldTitle.leadingAnchor),
            profileTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            profileTextField.heightAnchor.constraint(equalToConstant: 40),
            profileTextField.topAnchor.constraint(equalTo: profileFieldTitle.bottomAnchor, constant: 8),
            
            updateButton.leadingAnchor.constraint(equalTo: profileTextField.leadingAnchor),
            updateButton.trailingAnchor.constraint(equalTo: profileTextField.trailingAnchor),
            updateButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            updateButtonBottomAnchorConstraint!,
            
            errorMessageLabel.leadingAnchor.constraint(equalTo: profileFieldTitle.leadingAnchor),
            errorMessageLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        
        
        ])
        
        if field == .password {
            
            view.addSubview(passwordTextField)
            
            NSLayoutConstraint.activate([
            
                passwordTextField.leadingAnchor.constraint(equalTo: profileFieldTitle.leadingAnchor),
                passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                passwordTextField.heightAnchor.constraint(equalToConstant: 40),
                passwordTextField.topAnchor.constraint(equalTo: profileTextField.bottomAnchor, constant: 8),

                errorMessageLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            
            ])
            
        } else {
            errorMessageLabel.topAnchor.constraint(equalTo: profileTextField.bottomAnchor, constant: 8).isActive = true
        }
        
        
    }
    
    private func setupNavigationBar() {

        let backButton = UIBarButtonItem(image: UIImage(named: "back84x84"), style: .plain, target: self, action:  #selector(backButtonTapped))
        navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        
        
    }
    
    
    //MARK: - HELPERS
    
    private func displayMessage(_ text: String) {
        
        self.errorMessageLabel.text = text
        
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidName(_ name: String) -> Bool {
        guard name.count > 1, name.count < 18 else { return false }
        let namePred = NSPredicate(format: "SELF MATCHES %@", "^(([^ ]?)(^[a-zA-Z].*[a-zA-Z]$)([^ ]?))$")
        return namePred.evaluate(with: name)
        
    }
    
    private func isPasswordSame(_ t1: String, _ t2: String) -> Bool {
        return t1 == t2
    }
    
    //MARK: -ACTIONS
    
    @objc private func updateProfile() {
        
        guard let text = profileTextField.text, text != "" else {
            displayMessage("\(field.rawValue) cannot be empty.")
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {
            displayMessage("Please re-enter your password.")
            return
        }
        
        switch field {
        
        case .name:
            if !isValidName(text) {
                displayMessage("Please enter a valid name.")
                return
            }
            
            if text == APPSetting.customerName {
                return
            }
            
        case .email:
            if !isValidEmail(text) {
                displayMessage("Please enter a valid E-mail address.")
                return
            }
            if text == APPSetting.customerEmail {
                return
            }
            
        case .password:
            if !isPasswordSame(text, password) {
                displayMessage("Passwords do not match. Please try again.")
                return
            }
            
        default:
            break
        }
        
        NetworkManager.shared.updateProfileField(field, to: text) { (error) in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    
                    print(error)
                    self.displayMessage(error!.localizedDescription)
                    return
                }
                
                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
    @objc private func backButtonTapped() {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
               // if keyboard size is not available for some reason, dont do anything
               return
            }
          
          // move the root view up by the distance of keyboard height
        UIView.animate(withDuration: 0.1) {
            self.updateButtonBottomAnchorConstraint?.constant = -keyboardSize.height - 16 + self.tabBarHeight
            self.view.layoutIfNeeded()
        }
        
        
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.1) {
            self.updateButtonBottomAnchorConstraint?.constant = -16
            self.view.layoutIfNeeded()
        }
    }
    

}
