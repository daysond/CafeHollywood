//
//  LoadingViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-15.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import Lottie

class LoadingViewController: UIViewController {
    
    let fileName: String
    
    
    
    init(animationFileName: String) {
        self.fileName = animationFileName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.33)
        
        let lottieView = AnimationView (name: fileName)
        view.addSubview(lottieView)
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.play()
        lottieView.loopMode = .loop
        
        NSLayoutConstraint.activate([
            lottieView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lottieView.centerYAnchor.constraint(equalTo: view.centerYAnchor,  constant: -66),
            lottieView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.66),
            lottieView.heightAnchor.constraint(equalToConstant: 200),
            
        ])

    }
    

    
    
}




/*
 
 
 func createLoadingView() {
     let child = LoadingViewController()

     // add the spinner view controller
     addChild(child)
     child.view.frame = view.frame
     view.addSubview(child.view)
     child.didMove(toParent: self)

     // wait two seconds to simulate some work happening
     DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
         // then remove the spinner view controller
         child.willMove(toParent: nil)
         child.view.removeFromSuperview()
         child.removeFromParent()
     }
 }
 
 */

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .large)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

//
//func createSpinnerView() {
//    let child = SpinnerViewController()
//
//    // add the spinner view controller
//    addChild(child)
//    child.view.frame = view.frame
//    view.addSubview(child.view)
//    child.didMove(toParent: self)
//
//    // wait two seconds to simulate some work happening
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//        // then remove the spinner view controller
//        child.willMove(toParent: nil)
//        child.view.removeFromSuperview()
//        child.removeFromParent()
//    }
//}
