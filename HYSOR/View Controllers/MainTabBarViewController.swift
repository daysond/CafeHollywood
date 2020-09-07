//
//  MainTabBarViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-14.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewControllers()
        
        let name = UserDefaults.standard.string(forKey: "name") ?? ""
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let uid = UserDefaults.standard.string(forKey: "uid") ?? ""
        let stripeID = UserDefaults.standard.string(forKey: "stripeID") ?? ""
        
        print("userinfo \(name) \(email) \(uid) \(stripeID)")
    }
    
    private func setupViewControllers() {
        
        tabBar.tintColor = .black
        
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let homeTBI = UITabBarItem(title: "HOME", image: UIImage(named: "home-1"), tag: 0)
        homeViewController.tabBarItem = homeTBI
        
        
        
        let menuNavViewController = UINavigationController(rootViewController: MenuViewController())
//        let menuNavViewController = MenuViewController()
        menuNavViewController.tabBarItem = UITabBarItem(title: "MENU", image: UIImage(named: "menu"), tag: 1)
        
        
        
        
        let pastOrdersViewController = OrderHistoryViewController()
        NetworkManager.shared.addActiveOrderListener()
        NetworkManager.shared.activeOrderListenerDelegate = pastOrdersViewController
        pastOrdersViewController.tabBarItem = UITabBarItem(title: "ORDERS", image: UIImage(named: "invoice-1"), tag: 2)
        
        let accountViewController = AccountViewController()
        let accountNav = UINavigationController(rootViewController: accountViewController)
        accountNav.tabBarItem = UITabBarItem(title: "MY", image: UIImage(named: "user-1"), tag: 3)
        
        
        let tabBarList = [homeViewController, menuNavViewController, pastOrdersViewController, accountNav]
        viewControllers = tabBarList
    }
    


}
