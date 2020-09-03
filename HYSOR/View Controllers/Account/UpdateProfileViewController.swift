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
    
    private let profileFieldTitle: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .left
        l.textColor = .black
        l.text = "Name"
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
        
        updateButtonBottomAnchorConstraint = updateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            
            profileFieldTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileFieldTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            profileTextField.leadingAnchor.constraint(equalTo: profileFieldTitle.leadingAnchor),
            profileTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            profileTextField.heightAnchor.constraint(equalToConstant: 40),
            profileTextField.topAnchor.constraint(equalTo: profileFieldTitle.bottomAnchor, constant: 8),
            
            updateButton.leadingAnchor.constraint(equalTo: profileTextField.leadingAnchor),
            updateButton.trailingAnchor.constraint(equalTo: profileTextField.trailingAnchor),
            updateButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            updateButtonBottomAnchorConstraint!
        
        
        ])
        
        
    }
    
    private func setupNavigationBar() {

        let backButton = UIBarButtonItem(image: UIImage(named: "back84x84"), style: .plain, target: self, action:  #selector(backButtonTapped))
        navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        
        
    }
    
    //MARK: -ACTIONS
    
    @objc private func updateProfile() {
        
        //MARK: TODO
        
        switch field {
        
        case .name:
            print("update name")
            
        case .email:
            print("update email")
            
        case .phone:
            print("update phone")
            
        default:
            return
        }
        
        self.navigationController?.popViewController(animated: true)
        
        
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
