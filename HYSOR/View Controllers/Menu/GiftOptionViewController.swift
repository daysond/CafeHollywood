//
//  GiftOptionViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-11-05.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class GiftOptionViewController: UIViewController {
    
    private let giftOptionTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.register(PreferenceTableViewCell.self, forCellReuseIdentifier: PreferenceTableViewCell.identifier)
        return tb
    }()

    private let fromTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = UITextField.BorderStyle.roundedRect
        tf.textColor = .black
        tf.keyboardType = .default
        tf.autocorrectionType = .yes
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.addPadding(.left(4))
        tf.placeholder = "FROM:"
        tf.returnKeyType = .next
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let toTextfield: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.textColor = .black
        tf.borderStyle = .roundedRect
        tf.placeholder = "TO:"
        tf.keyboardType = .default
        tf.autocorrectionType = .yes
        tf.returnKeyType = .next
        tf.addPadding(.left(4))
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let messageTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 4
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.backgroundColor = .clear
        tv.textAlignment = .left
        tv.returnKeyType = .done
        tv.autocorrectionType = .yes
        return tv
    }()
    
    
    private let wordCountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textAlignment = .right
        l.textColor = .gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let errorLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textAlignment = .left
        l.text = ""
        l.textColor = .systemRed
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let removeItemButton: UIButton = {
        let b = UIButton()
        b.setTitle("- Remove Gift Option -", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        b.setTitleColor(.red, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private var charCount: Int = 0 {
        didSet{
            wordCountLabel.text = "\(charCount)/150"
            wordCountLabel.textColor = charCount == 150 ? .red : .gray
        }
    }
    
    private let messagePlaceholder = "Enter your message here."

    private let doneButton = BlackButton()
    
    private var giftOptions: [Meal] = [] {
        didSet{
            giftOptionTableView.reloadData()
        }
    }
    
    private var selectedIndex: Int?
    
    private let handleDone: (() -> Void)
    
    init(handler: @escaping ()->Void) {
        self.handleDone = handler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        getOptionFromDB()
    }

    
    
    //MARK: - SET UP
    
    fileprivate func setupView() {
        
        view.backgroundColor = .offWhite
        charCount = messageTextView.text.utf8.count
        navigationItem.title = "Gift Option"
        messageTextView.text = messagePlaceholder
        messageTextView.textColor = .lightGray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        doneButton.configureTitle(title: "Done")
        doneButton.layer.cornerRadius = 4
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        giftOptionTableView.layer.cornerRadius = 4
        giftOptionTableView.delegate = self
        giftOptionTableView.dataSource = self
        
        messageTextView.delegate = self
        fromTextField.delegate = self
        toTextfield.delegate = self
        
        [giftOptionTableView, fromTextField, toTextfield, messageTextView, doneButton, wordCountLabel, errorLabel].forEach { (subView) in
            view.addSubview(subView)
            subView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
            subView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        }
        
        NSLayoutConstraint.activate([
            
            fromTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            toTextfield.topAnchor.constraint(equalTo: fromTextField.bottomAnchor, constant: 8),
            
            messageTextView.topAnchor.constraint(equalTo: toTextfield.bottomAnchor, constant: 8),
            messageTextView.heightAnchor.constraint(equalToConstant: 150),
            
            wordCountLabel.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 8),
            
            giftOptionTableView.topAnchor.constraint(equalTo: wordCountLabel.bottomAnchor, constant: 16),
            giftOptionTableView.heightAnchor.constraint(equalToConstant: 200),
            
            errorLabel.topAnchor.constraint(equalTo: giftOptionTableView.bottomAnchor, constant: 8),
            
            doneButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
        
        if Cart.shared.selectedGiftOption != nil {
            errorLabel.removeFromSuperview()
            setupWithOption()
        }
    }
    
    fileprivate func setupWithOption() {
        
        view.addSubview(removeItemButton)
        
        removeItemButton.addTarget(self, action: #selector(removedButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            removeItemButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeItemButton.widthAnchor.constraint(equalTo: doneButton.widthAnchor),
            removeItemButton.heightAnchor.constraint(equalToConstant: 32),
            removeItemButton.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
        
        ])
        
        if let optionData =  Cart.shared.giftOptionContent, let from =  optionData["from"], let to = optionData["to"], let message =  optionData["message"] {
            fromTextField.text = from
            toTextfield.text = to
            if message == "" {
                messageTextView.text = messagePlaceholder
            } else {
                messageTextView.text = message
                messageTextView.textColor = .black
                
            }
        }

    }
    
    fileprivate func getOptionFromDB() {
        NetworkManager.shared.getGiftOptions { (options) in
            
            if let id = Cart.shared.selectedGiftOption?.uid, let index = options.firstIndex(where: { $0.uid == id }) {
                var modified = options
                modified[index].isSelected = true
                self.selectedIndex = index
                self.giftOptions = modified
                
            } else {
                self.giftOptions = options
            }
        }
    }
    
    // MARK: - SELECTORS
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc private func removedButtonTapped() {
        
        Cart.shared.removeGiftOption()
        handleDone()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneTapped() {
        
        guard let index = selectedIndex else {
            errorLabel.text = "Please select a gift option."
            return
        }
        
        guard fromTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            errorLabel.text = "Please enter the name of the sender."
            return
        }
        
        guard toTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            errorLabel.text = "Please enter the name of the recipient."
            return
        }
        
        guard messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "", messageTextView.text != messagePlaceholder else {
            errorLabel.text = "Please enter your message."
            return
        }
        
        let selectedOption = giftOptions[index]
        
        //1.check if there's already a selected gift if yes, remove from cart.meals
        if let existedOptionID = Cart.shared.selectedGiftOption?.uid {
            
            if existedOptionID == selectedOption.uid {
                handleDone()
                navigationController?.popViewController(animated: true)
                 return
            }
            
            Cart.shared.meals.removeAll { $0.uid == existedOptionID }
        }
        
        // 2. set seleted gift id and add option to cart.meals
        Cart.shared.selectedGiftOption = selectedOption
        Cart.shared.meals.append(selectedOption)
        
        let from = fromTextField.text ?? ""
        let to = toTextfield.text ?? ""
        let message = messageTextView.text! == messagePlaceholder ? "" :  messageTextView.text!
        let option = selectedOption.mealDescription
        
        Cart.shared.giftOptionContent = ["from": from, "to": to, "message": message, "option": option]
        handleDone()
        navigationController?.popViewController(animated: true)
        
    }
    



}

//MARK: - TEXTFIELD / TEXTVIEW DELEGATE

extension GiftOptionViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return textView.text.utf8.count + text.utf8.count <= 150
    }
    
    func textViewDidChange(_ textView: UITextView) {
        charCount = textView.text.utf8.count
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        errorLabel.text = ""
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = messagePlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "\n" {
            if textField == fromTextField {
                textField.resignFirstResponder()
                toTextfield.becomeFirstResponder()
            }
            if textField == toTextfield {
                textField.resignFirstResponder()
                messageTextView.becomeFirstResponder()
            }
        }
        
        return true
    }
    
    
}

//MARK: - TABLEVIEW DELEGATE

extension GiftOptionViewController: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  giftOptions.count  }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: PreferenceTableViewCell.identifier, for: indexPath) as? PreferenceTableViewCell {
            
            cell.configureCellWithGiftOption(giftOptions[indexPath.row])
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        58
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Please select your gift option:"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        giftOptions = giftOptions.map({ option -> Meal in
            var new = option
            new.isSelected = false
            return new
        })
        giftOptions[indexPath.row].isSelected = !giftOptions[indexPath.row].isSelected
        selectedIndex = indexPath.row
        errorLabel.text = ""
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
}
