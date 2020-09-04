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
        navigationController?.navigationBar.isHidden = true
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
        reservationButton.layer.cornerRadius = 4
        view.addSubview(reservationButton)
        
        orderNowButton.configureButton(headTitleText: "Online Order Now", titleColor: .black, backgroud: .white)
        orderNowButton.addTarget(self, action: #selector(onlineOrderTapped), for: .touchUpInside)
        orderNowButton.layer.cornerRadius = 4
        view.addSubview(orderNowButton)
        
        quickOrderButton.configureButton(headTitleText: "Quick Order", titleColor: .black, backgroud: .white)
        quickOrderButton.addTarget(self, action: #selector(quickOrderButtonTapped), for: .touchUpInside)
        quickOrderButton.layer.cornerRadius = 4
        view.addSubview(quickOrderButton)
        
        NSLayoutConstraint.activate([
            
            
            
            quickOrderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quickOrderButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -48),
            quickOrderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2.0/5.0),
            quickOrderButton.heightAnchor.constraint(equalToConstant: 40),
            
            reservationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reservationButton.topAnchor.constraint(equalTo: quickOrderButton.bottomAnchor, constant: 16),
            reservationButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2.0/5.0),
            reservationButton.heightAnchor.constraint(equalToConstant: 40),
            
            orderNowButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orderNowButton.topAnchor.constraint(equalTo: reservationButton.bottomAnchor, constant: 16),
            orderNowButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2.0/5.0),
            orderNowButton.heightAnchor.constraint(equalToConstant: 40),
            
        ])
        
        
    }
    
    //MARK: - ACTIONS
    
    @objc private func onlineOrderTapped() {
        
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc
    private func reservationTapped() {
        
        let width = view.frame.width
        let paxView = PaxView(frame: CGRect(x: 0, y: 0, width: width, height: 120))
        let schedulerView = SchedulerView(frame: CGRect(x: 0, y: 120, width: width, height: 300))
        
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
        let pax = self.paxView!.paxSize
        menuLauncher?.dismissMenu()
        
        createLoadingView()
        let reservation = Reservation(pax: pax, date: date)
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
    
    //MARK: - SHOW ALERT
    
    
//    private func showAlert(alertTitile: String, message: String?, actionTitle: String, action: @escaping () -> Void ) {
//
//        let alert = UIAlertController(title: alertTitile, message: message, preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel, handler: { (_) in
//            action()
//        }))
//
//
//        self.present(alert, animated: true)
//
//    }
//
    
    private func showCart() {
        
        let cartVC = CartViewController()
        let nav = UINavigationController(rootViewController: cartVC)
        nav.modalPresentationStyle = .automatic
        self.present(nav, animated: true, completion: nil)

    }
    
    private func showReservation() {
        
        print("developing ")
        
    }
    
    
    //MARK: - HELPER METHODS
    
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
