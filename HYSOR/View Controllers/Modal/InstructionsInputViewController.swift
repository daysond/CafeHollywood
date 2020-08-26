//
//  InstructionsInputViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-05.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

protocol InstructionInputDelegate {
    func didInputInstructions(_ instructions: String)
}

class InstructionsInputViewController: UIViewController {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.textColor = .black
        tv.backgroundColor = .clear
        tv.textAlignment = .left
        tv.autocorrectionType = .yes
        
        return tv
    }()

    var delegate: InstructionInputDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        textView.becomeFirstResponder()
    }
    
    
    func setupView() {
        
        view.backgroundColor = .white
        
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 32, height: 32)
        backButton.setImage(UIImage(named:"backButtonWhite"), for: .normal)
        backButton.addTarget(self, action: #selector(cancelTapped), for:.touchUpInside)

        let backBarItem = UIBarButtonItem(customView: backButton)
        backBarItem.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backBarItem.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        self.navigationItem.leftBarButtonItem = backBarItem
        self.navigationItem.title = "Special Instructions"
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: 0.0, y: 0.0, width: 32, height: 32)
        doneButton.setImage(UIImage(named:"doneNoteWhite"), for: .normal)
        doneButton.addTarget(self, action: #selector(doneTapped), for:.touchUpInside)

        let doneBarItem = UIBarButtonItem(customView: doneButton)
        doneBarItem.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
        doneBarItem.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        self.navigationItem.rightBarButtonItem = doneBarItem
        self.navigationController?.navigationBar.barTintColor = .black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

            ])
        }
        
    
    
    @objc func cancelTapped() {
        textView.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @objc func doneTapped() {
        
        textView.endEditing(true)
        guard let instructions = textView.text else {
            print("no instruction")
            return
        }
        self.delegate?.didInputInstructions(instructions)
        self.dismiss(animated: true)
        
    }

}

