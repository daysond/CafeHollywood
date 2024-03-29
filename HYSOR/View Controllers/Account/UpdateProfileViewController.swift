//
//  UpdateProfileViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-03.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

protocol UpdateProfileDisplayDelegate {
    func didFinishUpdatingProfile()
}

class UpdateProfileViewController: UIViewController {
    
    
    internal var field: AccountField
    
    internal let updateButton = BlackButton()
    
    internal var shouldAnimateKeyboard: Bool = true
    
    internal var phoneNumber: String?
    
    private var tabBarHeight: CGFloat = 0
    
    private var timerCount = 60  // 60sec
    private var resendTimer = Timer()
    
    private var spinner = SpinnerViewController()
    
    var updateDisplayDelegate: UpdateProfileDisplayDelegate?
    
    internal let profileTextField: UITextField = {
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
    
    internal let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.addPadding(.left(4))
        tf.isSecureTextEntry = true
        tf.keyboardType = .default
        tf.backgroundColor = .whiteSmoke
        tf.clearButtonMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    internal let profileFieldTitle: UILabel = {
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
    
    internal let resendButton: UIButton = {
        let b = UIButton()
        b.setTitle("Re-send verification code.", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        b.setTitleColor(.systemBlue, for: .normal)
        b.setTitleColor(.gray, for: .disabled)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private var updateButtonBottomAnchorConstraint: NSLayoutConstraint?
    
    var passwordTFHeightConstraint: NSLayoutConstraint?
    
    init(field: AccountField) {
        
        self.field = field
        
        super.init(nibName: nil, bundle: nil)
        switch field {
        case .phone:
            updateButton.configureTitle(title: "Send Verification Code")
        case .verification:
            updateButton.configureTitle(title: "Change Phone Number")
        default:
            updateButton.configureTitle(title: "Update \(field.rawValue)")
        }
        
        
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTextField.delegate = self
        
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
    
    
    internal func setupDisplay() {
        
        profileFieldTitle.text = field.rawValue
        
        switch field {
        case .name:
            
            profileFieldTitle.text = "First & Last Name"
            profileTextField.keyboardType = .default
            profileTextField.text = APPSetting.customerName
            
        case .email:
            
            profileTextField.text = APPSetting.customerEmail
            profileTextField.keyboardType = .emailAddress
            
        case .phone:
            profileTextField.placeholder = "PHONE NUMBER"
            profileTextField.text = APPSetting.customerPhoneNumber == "" ?  "+1" : "\(APPSetting.customerPhoneNumber)"
            //            profileTextField.text = APPSetting.customerPhoneNumber
            profileTextField.keyboardType = .phonePad
            
        case .password:
            
            profileTextField.isSecureTextEntry = true
            profileTextField.keyboardType = .default
            profileTextField.placeholder = "Enter New Password"
            passwordTextField.placeholder = "Re-Enter New Password"
            passwordTFHeightConstraint?.constant = 40
            
        case .verification:
            profileTextField.placeholder = "6-digit verification code"
            profileTextField.keyboardType = .numberPad
        default:
            return
        }
        
    }
    
    private func setupView() {
        
        view.backgroundColor = .white
        
        updateButton.addTarget(self, action: #selector(UpdateProfileViewController.handleButtonTapped), for: .touchUpInside)
        updateButton.layer.cornerRadius = 4
        
        view.addSubview(profileFieldTitle)
        view.addSubview(profileTextField)
        view.addSubview(updateButton)
        view.addSubview(errorMessageLabel)
        view.addSubview(passwordTextField)
        view.addSubview(resendButton)
        resendButton.isHidden = (field != .verification)
        updateButtonBottomAnchorConstraint = updateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        passwordTFHeightConstraint = passwordTextField.heightAnchor.constraint(equalToConstant: 0)
        
        resendButton.addTarget(self, action: #selector(resendCode), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            profileFieldTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileFieldTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
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
            
            passwordTextField.leadingAnchor.constraint(equalTo: profileFieldTitle.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            passwordTFHeightConstraint!,
            passwordTextField.topAnchor.constraint(equalTo: profileTextField.bottomAnchor, constant: 8),
            
            errorMessageLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            
            resendButton.leadingAnchor.constraint(equalTo: profileTextField.leadingAnchor),
            resendButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 8),
            
        ])
        
        
    }
    
    private func setupNavigationBar() {
        
        let backButton = UIBarButtonItem(image: UIImage(named: "back84x84"), style: .plain, target: self, action:  #selector(handleBackButton))
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        
        
    }
    
    
 
    //MARK: - VALIDATION
    
    private func isCodeValid(_ code: String) -> Bool {
        let codeRegEx = "^[0-9]{6}$"
        let codePred = NSPredicate(format:"SELF MATCHES %@", codeRegEx)
        return codePred.evaluate(with: code)
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
    
    internal func isPasswordSame(_ text: String) -> Bool {
        if field == .phone {
            return true
        }
        guard let password = passwordTextField.text, password != "" else {
            displayMessage("Please re-enter your password.")
            return false
        }
        
        return text == password
    }
    
    internal func shouldProceed() -> Bool {
        
        guard let text = profileTextField.text, text != "" else {
            displayMessage("\(field.rawValue) cannot be empty.")
            return false
        }
        
        switch field {
        
        case .name:
            if !isValidName(text) {
                displayMessage("Please enter a valid name.")
                return false
            }
            
            if text == APPSetting.customerName {
                return false
            }
            
        case .email:
            if !isValidEmail(text) {
                displayMessage("Please enter a valid E-mail address.")
                return false
            }
            if text == APPSetting.customerEmail {
                return false
            }
            
        case .password:
            if !isPasswordSame(text) {
                displayMessage("Passwords do not match. Please try again.")
                return false
            }
        case .verification:
            if !isCodeValid(text) {
                displayMessage("Invalid Code.")
                return false
            }
            
        default:
            break
        }
        
        return true
        
    }
    
    
    //MARK: - HELPERS
    
    internal func displayMessage(_ text: String) {
        
        self.errorMessageLabel.text = text
        
    }
    
    internal func startTimerForVerificationCode() {
        
        resendButton.isEnabled = false
        resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
    }
    
    @objc private func updateTimer() {
        if timerCount > 0 {
            timerCount = timerCount - 1
            resendButton.setTitle("Re-send verification code. (\(timerCount)s)", for: .disabled)
        }
        else {
            resendTimer.invalidate()
            resendButton.isEnabled = true
            timerCount = 60
            // if you want to reset the time make count = 60 and resendTime.fire()
        }
    }
    
    private func showReLogInAlert() {
        
        let alert = UIAlertController(title: "Please enter your password", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }

        let doneAction = UIAlertAction(title: "Done", style: .default) { [unowned alert] _ in
            let passwordTF = alert.textFields![0]
            guard let password = passwordTF.text else { return }
            NetworkManager.shared.reAuthenticateUser(password: password)
            // do something interesting with "answer" here
        }

        alert.addAction(doneAction)

        present(alert, animated: true)
        
        
    }
    
    //MARK: -ACTIONS
    
    @objc internal func handleButtonTapped() {
        
        if shouldProceed() {
            
            errorMessageLabel.text = ""
            
            switch field {
            
            case .phone:
                
                self.phoneNumber = profileTextField.text
                
                self.verifyPhoneNumber {
                    
                    let verificationVC = UpdateProfileViewController(field: .verification)
                    verificationVC.phoneNumber = self.phoneNumber
                    verificationVC.startTimerForVerificationCode()
                    self.navigationController?.pushViewController(verificationVC, animated: true)
                    
                }
                
            case .verification:
                
                showSpinner()
                
                NetworkManager.shared.setAuthPhoneNumber(verificationCode: profileTextField.text!) { (error) in
                    
                    DispatchQueue.main.async {
                        
                        self.removeSpinner()
                        
                        guard error == nil else {
                            self.displayMessage(error!.localizedDescription)
                            return
                        }
                        
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
            default:
                
                showSpinner()
                
                NetworkManager.shared.updateProfileField(field, to: profileTextField.text!) { (error) in
                    
                    DispatchQueue.main.async {
                        
                        self.removeSpinner()
                        
                        guard error == nil else {
                            
                            if let err = error as? NetworkError, err == .recentLoginRequired {
                                self.showReLogInAlert()
                                return
                            }
                            
                            self.displayMessage(error!.localizedDescription)
                            return
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func resendCode() {
        
        self.verifyPhoneNumber {
            
            self.startTimerForVerificationCode()
            
        }
    }
    
    
    @objc internal func handleBackButton() {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    //MARK: - NETWORKING
    
    internal func verifyPhoneNumber(complete: @escaping () -> Void) {
        
        guard let number = phoneNumber else {
            displayMessage("Please enter a valid phone number.")
            return
        }
        
        // Creat spinner view
        self.showSpinner()

        NetworkManager.shared.verifyPhoneNumber(number) { (verificationID, error) in
            
            DispatchQueue.main.async {
                
                self.removeSpinner()
                
                guard error == nil else {
                    self.displayMessage(error!.localizedDescription)
                    return
                }
                
                guard let id = verificationID else {
                    self.displayMessage("Unknow Error.")
                    return
                }
                
                APPSetting.storePhoneVerificationID(id)
                complete()
                
            }
        }
        
    }
    
    //MARK: - SPINNER
    internal func showSpinner() {
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    
    internal func removeSpinner() {
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
    }
    
    //MARK: KEYBOARD
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        if shouldAnimateKeyboard {
            
            UIView.animate(withDuration: 0.1) {
                self.updateButtonBottomAnchorConstraint?.constant = -keyboardSize.height - 16 + self.tabBarHeight
                self.view.layoutIfNeeded()
            }
            
        } else {
            self.updateButtonBottomAnchorConstraint?.constant = -keyboardSize.height - 16 + self.tabBarHeight
        }

        
    }
    @objc private func keyboardWillHide(notification: NSNotification) {
        
        if shouldAnimateKeyboard {
            UIView.animate(withDuration: 0.1) {
                self.updateButtonBottomAnchorConstraint?.constant = -16
                self.view.layoutIfNeeded()
            }
            
        } else {
            self.updateButtonBottomAnchorConstraint?.constant = -16
        }
        
    }
    
}

extension UpdateProfileViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if field == .phone {
            
            let currentText = textField.text ?? "+1"
            
            if currentText == "+1" && string == "" {
                print(string)
                return false
            }
            
            guard let range = Range(range, in: currentText) else { return false }
            
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            
            return updatedText.count < 13
            
        }
        
        if field == .verification {
            let currentText = textField.text ?? ""
            guard let range = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            return updatedText.count < 7
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if field == .phone && textField.text == "" {
            textField.text = "+1"
        }
    }
    
    
}
