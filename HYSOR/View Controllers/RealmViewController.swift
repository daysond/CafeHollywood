//
//  RealmViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-15.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit


class RealmViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = BlackButton()
        button.configureTitle(title: "Read DATA")
        
        button.addTarget(self, action: #selector(readData), for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
        
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              button.widthAnchor.constraint(equalTo: view.widthAnchor),
               button.heightAnchor.constraint(equalToConstant: 50),
        
        ])
        
        view.backgroundColor = .whiteSmoke
        
        
    
        
        
    }
    
    
    @objc func readData() {
    
        
    }
    


    
    

}
