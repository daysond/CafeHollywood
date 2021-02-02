//
//  HomeViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-15.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let backgroundImageView = UIImageView()
    
    let reservationButton = BlackButton()
    
    let orderNowButton = BlackButton()
    
    let quickOrderButton = BlackButton()
    
//    let myAccountButton = BlackButton()
    
    private var menuLauncher: SlideInMenuLauncher?
    
    private  var scheduelerView: SchedulerView?
    private  var paxView: PaxView?
    private  var favouriteView: FavouriteView?
    private let loadingView = LoadingViewController(animationFileName: "dotsLoading")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(pushPreferenceVC(_:)), name: .didTapModifyButton, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor =  .white
    }
    //MARK: - SET UP
    
    private func setupView() {
        
        view.backgroundColor = .offWhite
        
        backgroundImageView.image = UIImage(named: "homebg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = view.frame
        view.addSubview(backgroundImageView)
        
        reservationButton.configureButton(headTitleText: "Make Reservation", titleColor: .black, backgroud: .white)
        reservationButton.addTarget(self, action: #selector(reservationTapped), for: .touchUpInside)
        
        orderNowButton.configureButton(headTitleText: "Online Order Now", titleColor: .black, backgroud: .white)
        orderNowButton.addTarget(self, action: #selector(onlineOrderTapped), for: .touchUpInside)
        
        quickOrderButton.configureButton(headTitleText: "Quick Order", titleColor: .black, backgroud: .white)
        quickOrderButton.addTarget(self, action: #selector(quickOrderButtonTapped), for: .touchUpInside)
        
//        myAccountButton.configureButton(headTitleText: "My Account", titleColor: .black, backgroud: .white)
//        myAccountButton.addTarget(self, action: #selector(myAccountTapped), for: .touchUpInside)

        
        [quickOrderButton, reservationButton, orderNowButton].forEach { (button) in
            button.layer.cornerRadius = 4
            view.addSubview(button)
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2.0/5.0).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        NSLayoutConstraint.activate([
            
            
            quickOrderButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -48),
 
            reservationButton.topAnchor.constraint(equalTo: quickOrderButton.bottomAnchor, constant: 16),
            
            orderNowButton.topAnchor.constraint(equalTo: reservationButton.bottomAnchor, constant: 16),
            
//            myAccountButton.topAnchor.constraint(equalTo: orderNowButton.bottomAnchor, constant: 16),

        ])
        
        setupNavigationBar()
        
    }
    
    private func setupNavigationBar() {
        
        self.navigationController?.isNavigationBarHidden = false
        let openMenuButton = UIBarButtonItem(image: UIImage(named: "openMenu"), style: .plain, target: self, action:  #selector(myAccountTapped))
        navigationController?.navigationBar.tintColor =  .white
        self.navigationItem.rightBarButtonItem = openMenuButton
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        
        
    }
    
    //MARK: - ACTIONS
    
    
    @objc private func myAccountTapped() {
        navigationController?.pushViewController(AccountViewController(), animated: true)
//        navigationController?.pushViewController(GiftOptionViewController(), animated: true)
    }
    
    @objc private func onlineOrderTapped() {
        
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }
        
//        self.tabBarController?.selectedIndex = 1
        var uids: [String] = []
        for i in 1...7 {
            uids.append("UE0\(i)")
        }
        
        let names:[String] = ["焗肉醬意粉", "焗葡國雞", "焗茄汁豬扒", "咖喱牛肉", "咖喱雞", "焗白汁石斑", "韓式牛肉石鍋拌飯"]
        let imageURL: [String] = ["H23","H24", "H14","","","H19", ""]
        let price = 11.50
        let detail:[String] = ["Spaghttie Bologness", "Baked Portuguess Style Chicken", "Pork Chop Casserole", "Curry Beef", "Curry Chicken", "Garoupa Casserole", "Korean Beef Bibimbap"]
        let preferences: [String] = ["mainSideForBaked", "onlineSoftDrinks"]
//        let sbp: [String] = ["mainSideForbaked", "addBacon"]
        
        for (index, uid) in uids.enumerated() {
            
            let data: [String : Any] = ["name": names[index],
                        "imageURL": imageURL[index],
                        "description": names[index],
                        "preferences": preferences,
                        "price": price,
                        "uid": uid,
                        "detail": detail[index]
            ]
            
            NetworkManager.shared.uploadMeal(uid: uid, data: data)
            
            
        }
        
    }
    
    @objc
    private func reservationTapped() {
        
        guard let isTakingReservation = APPSetting.shared.isTakingReservation else {
            showError(message: "Network Error. Please try again later.")
            return
        }
        
        if isTakingReservation == false {
            showError(title: "Sorry!", message: "We are currently not accepting reservations.")
            return
        }
        
        guard let openHours = APPSetting.shared.openHours, let closeHours = APPSetting.shared.closedHours else {
            showError(message: "Network Error. Can not fetch business hour information.")
            return
        }
        
        let width = view.frame.width
        let paxView = PaxView(frame: CGRect(x: 0, y: 0, width: width, height: 120))
        let schedulerView = SchedulerView(openHours: openHours, closeHours: closeHours)
        schedulerView.frame = CGRect(x: 0, y: 120, width: width, height: 300)
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.addSubview(paxView)
        containerView.addSubview(schedulerView)
        
        self.scheduelerView = schedulerView
        self.paxView = paxView
        schedulerView.donebutton.addTarget(self, action: #selector(didConfirmReservation), for: .touchUpInside)
        
        launchMenu(view: containerView, height: 420)
        
    }
    
    @objc func didConfirmReservation() {
        
        let date = self.scheduelerView!.selectedDate
        let time = self.scheduelerView!.selectedTime
        let pax = self.paxView!.paxSize
        menuLauncher?.dismissMenu()
        
        createLoadingView()
        let reservation = Reservation(pax: pax, date: date, time: time)
        //upload reservation
        
        NetworkManager.shared.sendReservation(reservation) { [self] (err) in
            guard err == nil else { return }
            
            DispatchQueue.main.async {
                let rvc = ReservationViewController(reservation: reservation)
                rvc.modalPresentationStyle = .popover
                self.navigationController?.pushViewController(rvc, animated: true)
                
                self.dismissLoadingView()
                
            }
        }
    }

    @objc private func quickOrderButtonTapped() {
        
        let width = view.frame.width
        let height = view.frame.height * 2.0/3.0
        self.favouriteView  = FavouriteView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        favouriteView?.addToCartButton.addTarget(self, action: #selector(addFavouriteToCart), for: .touchUpInside)
        favouriteView?.cancelButton.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
        for (index, meal) in APPSetting.favouriteMeals.enumerated() {
            if meal.isSelected {
                APPSetting.favouriteMeals[index].isSelected = false
            }
        }
        launchMenu(view: favouriteView!, height: height)
        
    }
    
    @objc private func addFavouriteToCart() {
        var count = 0
        for (index, meal) in APPSetting.favouriteMeals.enumerated() {
            if meal.isSelected {
                APPSetting.favouriteMeals[index].isSelected = false
                Cart.shared.meals.append(meal)
                count += 1
            }
        }
        
//        showAlert(alertTitile: "Successfully added \(count) meals to cart!", message: nil, actionTitle: "View Cart", action: showCart)
        let cartVC = CartViewController()
        let nav = UINavigationController(rootViewController: cartVC)
        nav.modalPresentationStyle = .automatic
        self.present(nav, animated: true, completion: nil)

        dismissMenu()
        
    }
    
    @objc private func dismissMenu() {
        
        menuLauncher?.dismissMenu()
        
    }
    
    @objc private func pushPreferenceVC(_ notification: Notification) {

        if let data = notification.userInfo as? [String: Int], let index = data["index"] {
            
            let meal = APPSetting.favouriteMeals[index]
            let mealViewController = FavouriteMealViewController(meal:meal, index: index)
            mealViewController.delegate = favouriteView
            mealViewController.modalPresentationStyle = .popover
            self.present(mealViewController, animated: true, completion: nil)
//            self.navigationController?.pushViewController(mealViewController, animated: true)
            
        }
        
    }
    
    //MARK: - HELPERS
    
    private func createLoadingView() {
        
        addChild(loadingView)
        loadingView.view.frame = view.frame
        view.addSubview(loadingView.view)
        loadingView.didMove(toParent: self)
        
    }
    
    private func dismissLoadingView() {
        
        loadingView.willMove(toParent: nil)
        loadingView.view.removeFromSuperview()
        loadingView.removeFromParent()
        
    }
    
    
    private func launchMenu(view: UIView, height: CGFloat) {
        
        let blackView = UIView()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tapGes)
        blackView.isUserInteractionEnabled = true
        
        let menuLauncher = SlideInMenuLauncher(blackView: blackView, menuView: view, menuHeight: height)
        self.menuLauncher = menuLauncher
        menuLauncher.showMenu()
        
    }
    
    
    
}
