//
//  LoginViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
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
        l.text = "Login to your Account"
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

    private let hintLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .left
        l.textColor = .black
        l.numberOfLines = 0
        l.text = "Create your Account ans this is your hint"
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    
    private let optionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        l.textColor = .black
        l.numberOfLines = 0
        l.text = "\n\n- Or sign in with -"
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return l
    }()
    
    private let signUpButton: UIButton = {
        let b = UIButton()
        b.setTitle("Don't have an account? Sign up", for: .normal)
        b.setTitleColor(.systemBlue, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18)
     b.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        return b
    }()
        private let retrieveButton: UIButton = {
            let b = UIButton()
            b.setTitle("Forgot your password? Retrieve", for: .normal)
            b.setTitleColor(.systemBlue, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 18)
           b.addTarget(self, action: #selector(retrievePassword), for: .touchUpInside)
            return b
        }()
    
    private var signUpStackView: UIStackView!
    
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
    
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupRX()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - SETUP
    
    private func setupView() {
        
        view.backgroundColor = .white
        setupSignUpStackView()
        
        authButton.configureButton(headTitleText: "Sign In", titleColor: .white, backgroud: .gray)
        authButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        authButton.isEnabled = false
        
        
        let signUpOptionStackView = UIStackView(arrangedSubviews: [googleButton, facebookButton, appleButton])
        signUpOptionStackView.axis = .horizontal
        signUpOptionStackView.distribution = .fillEqually
        signUpOptionStackView.spacing = 16
        
        let mainStackview = UIStackView(arrangedSubviews: [titleLabel, emailTextField, passwordTextfield, hintLabel, authButton, optionLabel, signUpOptionStackView, signUpStackView])
        mainStackview.translatesAutoresizingMaskIntoConstraints = false
        mainStackview.axis = .vertical
        mainStackview.distribution = .fillEqually
        mainStackview.spacing = 16
        emailTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        view.addSubview(mainStackview)
        //        view.addSubview(authButton)
        
        NSLayoutConstraint.activate([
            
            mainStackview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            mainStackview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            
        ])

        
    }
    
    private func setupSignUpStackView() {
        
        
        let stackview = UIStackView(arrangedSubviews: [signUpButton, retrieveButton])
        stackview.axis = .vertical
        stackview.distribution = .fillEqually
        stackview.alignment = .center
        stackview.spacing = 8
        
        signUpStackView = stackview
        
    }
    
    
    private func setupRX() {
    
        //Hints
        emailTextField.rx.controlEvent(.editingDidBegin).withLatestFrom(emailTextField.rx.text.orEmpty)
            .subscribe(onNext: { (text) in
                self.hintLabel.text = "Please enter your Email address."
            }).disposed(by: bag)
        
        passwordTextfield.rx.controlEvent(.editingDidBegin).withLatestFrom(passwordTextfield.rx.text.orEmpty)
            .subscribe(onNext: { (password) in
                
                if !self.isEmailValid {
                    self.hintLabel.text = "Please double-check your Email address."
                } else {
                    self.hintLabel.text = "Please enter your password."
                }
            }).disposed(by: bag)
        
                //Validation
        emailTextField.rx.controlEvent(.editingChanged).withLatestFrom(emailTextField.rx.text.orEmpty)
            .subscribe(onNext: { (text) in
                self.isEmailValid = self.isValidEmail(text)
            }).disposed(by: bag)
        
        passwordTextfield.rx.controlEvent(.editingChanged).withLatestFrom(passwordTextfield.rx.text.orEmpty)
            .subscribe(onNext: { (password) in
                
                self.isPasswordValid = password.count > 5
            }).disposed(by: bag)
        
    }
    
    //MARK: - HELPERS
    
    private func signInWith(_ email: String, _ password: String, group: DispatchGroup) {
        
        group.enter()
        NetworkManager.shared.signInWith(email, password) { (authResult, error) in
            guard error ==  nil else {
                DispatchQueue.main.async {
                    self.hintLabel.text = error!.localizedDescription
                }
                return
            }
            
            guard authResult != nil else {
                DispatchQueue.main.async {
                     self.hintLabel.text = "Unknow error."
                }
                return
            }
            
            group.leave()
        }
        
    }
    
    private func setupUser() {
        
        NetworkManager.shared.fetchUserInfoFromDataBase { (result) in
            
            switch result {
                
            case .success(let data):
                guard let name =  data["name"], let email = data["email"], let uid = data["uid"] else { return }
                
                APPSetting.shared.storeUserInfo(email, name, uid,data["stripeID"] ?? nil )
                
                self.presentMainViewController()
                
            case .failure(let error):
                // prompt error
                print(error.localizedDescription)
            }
        }
    }
    
    private func presentMainViewController() {
        
        let mainVC = MainTabBarViewController()
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true) {
            print("completed")
        }

    }
    
    //MARK: - ACTION
    
    @objc private func loginButtonTapped() {
        
        guard let email = emailTextField.text, let password = passwordTextfield.text else {
            hintLabel.text = "Please enter email and password."
            return
        }
        
        hintLabel.text = "Logging in ..."
        
        let group = DispatchGroup()
        
        let radQueue = OperationQueue()
        
        let signInOperation = BlockOperation {
            self.signInWith(email, password, group: group)
            group.wait()
        }
        
        let setupUserOperation = BlockOperation {
            self.setupUser()
        }
        
        setupUserOperation.addDependency(signInOperation)
        
        radQueue.addOperation(setupUserOperation)
        radQueue.addOperation(signInOperation)
        
        
        
    }
    
    @objc func retrievePassword() {
        
        print("forget in logic")

    }
    
    @objc func signUp() {
        
        self.navigationController?.pushViewController(SignUpViewController(), animated: true)


    }
    //MARK: -HELPERS
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    private func isFormValid() {
        
        authButton.isEnabled = isEmailValid && isPasswordValid 
        authButton.backgroundColor = authButton.isEnabled ? .black : .gray
        
    }
    
    

}
