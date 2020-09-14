//
//  MainTabBarViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-14.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    private let mainButton: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "mainButton"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
        
    }()
    
    private let addDietButton = ActionButton()
    private let refillWaterButton = ActionButton()
    private let addPlanButton = ActionButton()
    private let addWorkoutButton = ActionButton()
    private let addWeightutton = ActionButton()
    
    private var menuButtons = [ActionButton]()
    
    private var addDietButtonTopAnchor: NSLayoutConstraint?
    private var addDietButtonLeadingAnchor: NSLayoutConstraint?
    
    private var addWaterButtonTopAnchor: NSLayoutConstraint?
    private var addWaterButtonLeadingAnchor: NSLayoutConstraint?
    
    private var menuButton2TopAnchor: NSLayoutConstraint?
    private var menuButton2LeadingAnchor: NSLayoutConstraint?
    
    private var addWorkoutButtonTopAnchor: NSLayoutConstraint?
    private var addWorkoutButtonLeadingAnchor: NSLayoutConstraint?
    
    private var addWeightButtonTopAnchor: NSLayoutConstraint?
    private var addWeightButtonLeadingAnchor: NSLayoutConstraint?
    
    private var radius: CGFloat = 0
    
    private var isMenuOpened: Bool = false {
        didSet {
            handleMenu()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        menuButtons = [addDietButton, refillWaterButton, addPlanButton, addWorkoutButton, addWeightutton]
        self.delegate = self
        
        setupViewControllers()
        setupActionButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        radius = view.bounds.maxX * 0.5 - 40.0
    }
    
    private func setupActionButton() {
        
        let width = view.bounds.width / 5.0
        tabBar.addSubview(mainButton)
        mainButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 12, right: 8)
        mainButton.clipsToBounds = true
        mainButton.layer.cornerRadius = width/2.0
        mainButton.backgroundColor = .whiteSmoke
        mainButton.addTarget(self, action: #selector(MainTabBarViewController.openMenu), for: .touchUpInside)
        

        refillWaterButton.button.setImage(UIImage(named: "water"), for: .normal)
        refillWaterButton.label.text = "Refill Water"
        
        addPlanButton.button.setImage(UIImage(named: "waiter"), for: .normal)
        addPlanButton.label.text = "Call Waiter"
        
        addDietButton.button.setImage(UIImage(named: "order"), for: .normal)
        addDietButton.label.text = "My Order"
        
        addWorkoutButton.button.setImage(UIImage(named: "receipt"), for: .normal)
        addWorkoutButton.label.text = "Get Bill"
        
        addWeightutton.button.setImage(UIImage(named: "note"), for: .normal)
        addWeightutton.label.text = "Something Else"

        
        for menuButton in menuButtons {
            view.insertSubview(menuButton, belowSubview: tabBar)
            menuButton.button.imageEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
            menuButton.button.addTarget(self, action: #selector(menuButtonsTapped(_:)), for: .touchUpInside)
            menuButton.isHidden = true
            menuButton.widthAnchor.constraint(equalTo: mainButton.widthAnchor).isActive = true
            menuButton.heightAnchor.constraint(equalTo: mainButton.heightAnchor, constant: 4).isActive = true
        }
        

        addDietButtonTopAnchor = addDietButton.topAnchor.constraint(equalTo: mainButton.topAnchor)
        addDietButtonLeadingAnchor = addDietButton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor)
        
        addWaterButtonTopAnchor = refillWaterButton.topAnchor.constraint(equalTo: mainButton.topAnchor)
        addWaterButtonLeadingAnchor = refillWaterButton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor)
        
        menuButton2TopAnchor = addPlanButton.topAnchor.constraint(equalTo: mainButton.topAnchor)
        menuButton2LeadingAnchor = addPlanButton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor)
        
        addWorkoutButtonTopAnchor = addWorkoutButton.topAnchor.constraint(equalTo: mainButton.topAnchor)
        addWorkoutButtonLeadingAnchor = addWorkoutButton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor)
        
        addWeightButtonTopAnchor = addWeightutton.topAnchor.constraint(equalTo: mainButton.topAnchor)
        addWeightButtonLeadingAnchor = addWeightutton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor)
        
        
        NSLayoutConstraint.activate([
            mainButton.widthAnchor.constraint(equalToConstant: width),
            mainButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            mainButton.heightAnchor.constraint(equalToConstant: width),
            mainButton.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -12),
            
            addDietButtonTopAnchor!,
            addDietButtonLeadingAnchor!,
            
            addWaterButtonTopAnchor!,
            addWaterButtonLeadingAnchor!,
            
            menuButton2TopAnchor!,
            menuButton2LeadingAnchor!,

            addWorkoutButtonTopAnchor!,
            addWorkoutButtonLeadingAnchor!,
            
            addWeightButtonTopAnchor!,
            addWeightButtonLeadingAnchor!,
        ])
        
    }
    
    private func setupViewControllers() {
        
        tabBar.tintColor = .black
        
        let apperance = UITabBarAppearance()
        apperance.backgroundColor = .whiteSmoke
        tabBar.standardAppearance = apperance
        
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let homeTBI = UITabBarItem(title: "HOME", image: UIImage(named: "home-1"), tag: 0)
        homeViewController.tabBarItem = homeTBI
        
        
        let menuNavViewController = UINavigationController(rootViewController: MenuViewController())
//        let menuNavViewController = MenuViewController()
        menuNavViewController.tabBarItem = UITabBarItem(title: "MENU", image: UIImage(named: "menu"), tag: 1)
        
        let actionViewController = ActionViewController()
        actionViewController.tabBarItem = UITabBarItem(title: nil, image: nil, tag: 2)
        
        
        let pastOrdersViewController = OrderHistoryViewController()
        NetworkManager.shared.addActiveOrderListener()
        NetworkManager.shared.activeOrderListenerDelegate = pastOrdersViewController
        pastOrdersViewController.tabBarItem = UITabBarItem(title: "ORDERS", image: UIImage(named: "invoice-1"), tag: 3)
        
        let accountViewController = AccountViewController()
        let accountNav = UINavigationController(rootViewController: accountViewController)
        accountNav.tabBarItem = UITabBarItem(title: "MY", image: UIImage(named: "user-1"), tag: 4)
        
        
        let tabBarList = [homeViewController, menuNavViewController, actionViewController ,pastOrdersViewController, accountNav]
        viewControllers = tabBarList
    }
    
    
    //MARK: - ACTIONS
    
    @objc private func menuButtonsTapped(_ sender: UIButton)  {
        
        isMenuOpened = false
        
        if sender === addDietButton.button {
            print("add diet")
        }
        
        if sender === addWeightutton.button {
            print("add weight")
        }
        
        if sender === addWorkoutButton.button {
            print("add workout")
        }
        
        if sender === refillWaterButton.button {
            
//           present(AddWaterViewController(), animated: true, completion: nil)
        }
        
        if sender === addPlanButton.button {
//            showAddPlanAlert()
        }
    }
    
    @objc private func openMenu() {
        isMenuOpened = !isMenuOpened
    }
    
    //MARK: - TABBAR DELEGATE
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController.isKind(of: ActionViewController.self) {
            print("seleted action vc")
            return false
        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("seleted")
    }

    
    //MARK: - MENU BUTTON ANIMATION
    
    private func updateButtonConstraints() {
        let sin120 = sin(120.0 * Double.pi / 180) //0.866
        if isMenuOpened {
            addDietButtonTopAnchor?.constant = -radius
            
            addWaterButtonTopAnchor?.constant = -(radius * 0.5)
            addWaterButtonLeadingAnchor?.constant = -(radius * CGFloat(sin120))
            
            menuButton2TopAnchor?.constant = -(radius * CGFloat(sin120))
            menuButton2LeadingAnchor?.constant = -(radius * 0.5)
            
            addWorkoutButtonTopAnchor?.constant = -(radius * CGFloat(sin120))
            addWorkoutButtonLeadingAnchor?.constant = radius * 0.5
            
            addWeightButtonTopAnchor?.constant = -(radius * 0.5)
            addWeightButtonLeadingAnchor?.constant = radius * CGFloat(sin120)
        } else {
            addDietButtonTopAnchor?.constant = 0
            
            addWaterButtonTopAnchor?.constant = 0
            addWaterButtonLeadingAnchor?.constant = 0
            
            menuButton2TopAnchor?.constant = 0
            menuButton2LeadingAnchor?.constant = 0
            
            addWorkoutButtonTopAnchor?.constant = 0
            addWorkoutButtonLeadingAnchor?.constant = 0
            
            addWeightButtonTopAnchor?.constant = 0
            addWeightButtonLeadingAnchor?.constant = 0
        }
    }
    
    private func handleMenu() {
        
        if APPSetting.shared.currentTable == nil {
            let scanVC = ScannerViewController()
            scanVC.delegate = self
            let nvc = UINavigationController(rootViewController: scanVC)
            nvc.modalPresentationStyle = .fullScreen
            present(nvc, animated: true, completion: nil)
            return
        }
        
        
        if isMenuOpened {
            
            for menuButton in menuButtons {
                menuButton.isHidden = !isMenuOpened
            }
            
            updateButtonConstraints()
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            
            updateButtonConstraints()
            
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            }) { (_) in
                for menuButton in self.menuButtons {
                    menuButton.isHidden = !self.isMenuOpened
                }
            }
        }
    }

}

extension MainTabBarViewController: QRCodeScannerDelegate {
    

    
    func found(tableNumber: String) {
        APPSetting.shared.currentTable = tableNumber
    }
    
    func failedReadingQRCode() {
        
        //TODO: show alert
        print("failed")
    }
    
    
}

class ActionViewController: UIViewController { }
