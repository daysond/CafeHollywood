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
    
    private let myOrderButton = ActionButton()
    private let refillWaterButton = ActionButton()
    private let requestWaiterButton = ActionButton()
    private let getBillButton = ActionButton()
    private let noteButton = ActionButton()
    
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

        menuButtons = [myOrderButton, refillWaterButton, requestWaiterButton, getBillButton, noteButton]
        self.delegate = self
        
        setupViewControllers()
        setupActionButton()
        networkSetup()
        observerSetup()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        radius = view.bounds.maxX * 0.5 - 40.0
    }
    
    
    private func observerSetup() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabBarViewController.handleTableClosed), name: .didCloseTable, object: nil)
        
    }
    
    
    private func networkSetup() {
        
        NetworkManager.shared.checkActiveTable()
        NetworkManager.shared.addActiveOrderListener()
        
        NetworkManager.shared.checkBusinessHoursUpdate { (newVersion) in
            
            guard let newVersion = newVersion else { print("returned")
                return }
            
            print("TAG  hours \(newVersion)")
            
            self.compareBusinessHoursVersion(with: newVersion)
        }

    }
    
    private func compareBusinessHoursVersion(with newVersion: String) {

        func setKeyAndHours() {
            print("TAG  hours \(newVersion) did set key")
            userDefaults.set(newVersion, forKey: "businessHoursVersion")
            setBusinessHours()
        }
        
        guard let currentMenuVersion = userDefaults.string(forKey: "businessHoursVersion") else {
            // first time: set key and hours
            setKeyAndHours()
            return
        }
        
        // got updates: set hours and reset key
        if newVersion != currentMenuVersion {
            setKeyAndHours()
        }

    }
    
    private func setBusinessHours() {
        
        NetworkManager.shared.getBusinessHours { (data, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let hours = data {
                userDefaults.setValue(hours, forKey: Constants.businessHoursKey)
                print("TAG  hours \(hours)")
            }
        }
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
        
        requestWaiterButton.button.setImage(UIImage(named: "waiter"), for: .normal)
        requestWaiterButton.label.text = "Call Waiter"
        
        myOrderButton.button.setImage(UIImage(named: "order"), for: .normal)
        myOrderButton.label.text = "My Order"
        
        getBillButton.button.setImage(UIImage(named: "receipt"), for: .normal)
        getBillButton.label.text = "Get Bill"
        
        noteButton.button.setImage(UIImage(named: "note"), for: .normal)
        noteButton.label.text = "Something Else"

        
        for menuButton in menuButtons {
            view.insertSubview(menuButton, belowSubview: tabBar)
            menuButton.button.imageEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
            menuButton.button.addTarget(self, action: #selector(menuButtonsTapped(_:)), for: .touchUpInside)
            menuButton.isHidden = true
            menuButton.widthAnchor.constraint(equalTo: mainButton.widthAnchor).isActive = true
            menuButton.heightAnchor.constraint(equalTo: mainButton.heightAnchor, constant: 4).isActive = true
        }
        

        addDietButtonTopAnchor = myOrderButton.topAnchor.constraint(equalTo: mainButton.topAnchor)
        addDietButtonLeadingAnchor = myOrderButton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor)
        
        addWaterButtonTopAnchor = refillWaterButton.topAnchor.constraint(equalTo: mainButton.topAnchor)
        addWaterButtonLeadingAnchor = refillWaterButton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor)
        
        menuButton2TopAnchor = requestWaiterButton.topAnchor.constraint(equalTo: mainButton.topAnchor)
        menuButton2LeadingAnchor = requestWaiterButton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor)
        
        addWorkoutButtonTopAnchor = getBillButton.topAnchor.constraint(equalTo: mainButton.topAnchor)
        addWorkoutButtonLeadingAnchor = getBillButton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor)
        
        addWeightButtonTopAnchor = noteButton.topAnchor.constraint(equalTo: mainButton.topAnchor)
        addWeightButtonLeadingAnchor = noteButton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor)
        
        
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
        
        if sender === myOrderButton.button {
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.75))
            containerView.backgroundColor = .white
            let donebutton = BlackButton(frame: CGRect(x: 0, y: containerView.frame.maxY - 48, width: containerView.frame.width, height: 48))
            let tableOrderView = TableOrderView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height - 48 - 8))
            
            donebutton.configureTitle(title: "Done")
            donebutton.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
            donebutton.translatesAutoresizingMaskIntoConstraints = true
            
            containerView.addSubview(donebutton)
            containerView.addSubview(tableOrderView)

            launchMenu(view: containerView, height: containerView.frame.height)
        }
        
        if sender === noteButton.button {
            let ivc = InstructionsInputViewController(title: "Message")
            ivc.delegate = self
            let nav = UINavigationController(rootViewController: ivc)
            nav.modalPresentationStyle = .popover
            self.present(nav, animated: true, completion: nil)
        }
        
        if sender === getBillButton.button {
            sendRequest("bill")
        }
        
        if sender === refillWaterButton.button {
            
            sendRequest("water refill")
        }
        
        if sender === requestWaiterButton.button {
            sendRequest("waiter")
        }
    }
    
    @objc private func openMenu() {
        isMenuOpened = !isMenuOpened
    }
    
    @objc private func handleTableClosed() {
        isMenuOpened = false 
    }
    
    
    private func sendRequest(_ text: String) {
        
        guard let table = Table.shared.tableNumber else {
            return
        }
        
        let request = "Table \(table) request \(text)."
        
        NetworkManager.shared.sendRequest(request) { (error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
        }
    }

    
    
    //MARK:- HELPERS
    
    private var menuLauncher: SlideInMenuLauncher?

    private func launchMenu(view: UIView, height: CGFloat) {
        
        let blackView = UIView()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tapGes)
        blackView.isUserInteractionEnabled = true
        
        let menuLauncher = SlideInMenuLauncher(blackView: blackView, menuView: view, menuHeight: height, menuViewCornerRadius: 8)
        self.menuLauncher = menuLauncher
        menuLauncher.showMenu()
        
    }
    
    //MARK: - OBJC
    
    @objc private func dismissMenu() {
        
        menuLauncher?.dismissMenu()
        
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
//        print("seleted")
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
        
        if Table.shared.tableNumber == nil {
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

extension MainTabBarViewController: QRCodeScannerDelegate, InstructionInputDelegate {
    
    
    func didInputInstructions(_ instructions: String) {
        
        sendRequest(instructions)
        
    }
    
    func found() {
        
    }
    
    func failedReadingQRCode() {
        
        //TODO: show alert
        print("failed")
    }
    
    
}

class ActionViewController: UIViewController { }
