//
//  CartViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-06-29.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {
    
    private let cartTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.register(CartTableViewCell.self, forCellReuseIdentifier: CartTableViewCell.identifier)
        return tb
    }()
    
    private let checkoutButton = BlackButton()
    
    private let cartFooterView = CartFooterView()
    
    private let kCellHeightConstant: CGFloat = 64.0
    private let kPriceLabelWidth: CGFloat = 76.0
    
    private var loadingView = LoadingViewController(animationFileName: "dotsLoading")
    
    private var cartImageView: UIImageView?
    
    private var emptyCartLabel: UILabel?
    
    private var isTableViewSetup: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Items"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        switch Cart.shared.isEmpty {
            
        case true:
            
           setupEmptyCartView()
            
        default:
            
            setupView()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Cart.shared.isEmpty {
            isTableViewSetup ? cartTableView.reloadData() : reSetUp()
        }
        
        
    }

    // MARK: - VIEW SET UP
    
    private func reSetUp() {
        
        cartImageView?.removeFromSuperview()
        emptyCartLabel?.removeFromSuperview()
        setupView()
        
    }
    
    private func setupEmptyCartView() {
        
        view.backgroundColor = .offWhite
        
        let cartImageView = UIImageView(image: UIImage(named: "cart" ))
        cartImageView.contentMode = .scaleAspectFit
        view.addSubview(cartImageView)
        cartImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .black
        label.text = "Your cart is empty."
        
        self.cartImageView = cartImageView
        self.emptyCartLabel = label
        
        view.addSubview(cartImageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
        
            cartImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cartImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            cartImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            cartImageView.heightAnchor.constraint(equalTo: cartImageView.widthAnchor),
            
            label.topAnchor.constraint(equalTo: cartImageView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: cartImageView.centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: 40),
        
        ])
        
    }
    
    
    private func setupView() {
        isTableViewSetup = true
        cartTableView.delegate = self
        cartTableView.dataSource = self
        Cart.shared.delegate = self
        view.backgroundColor = .offWhite
        view.addSubview(cartTableView)
        
        view.addSubview(checkoutButton)
        checkoutButton.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
        checkoutButton.configureTitle(title: APPSetting.shared.isDineIn ? "Send Order" : "Check Out")
        
         if APPSetting.shared.isRestaurantOpen == false {
            checkoutButton.isEnabled = false
            checkoutButton.backgroundColor = .lightGray
            checkoutButton.configureTitle(title: "Kitchen Closed")
        }
        
        setupFooterView()
        
        NSLayoutConstraint.activate([
            
            cartTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cartTableView.bottomAnchor.constraint(equalTo: checkoutButton.topAnchor),
            cartTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cartTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            checkoutButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            checkoutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            checkoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -0),
            
        ])
    }
    

    
    private func setupFooterView() {
        
        cartTableView.tableFooterView = cartFooterView
        cartFooterView.frame.size.height = 200
        cartFooterView.backgroundColor = .white
        cartFooterView.updateFooterLabels()
        
    }
    
    //MARK: - HELPERS
    
    private func onlineOrderCheckout() {
        
        let checkoutVC = CheckoutViewController()
        self.navigationController?.pushViewController(checkoutVC, animated: true)
        
    }
    
    private func dineInSendOrder() {
        
        NetworkManager.shared.sendOrder { error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
            Cart.resetCart()

        }
    }

    
    // MARK: - ACTIONS
    
    @objc func didAuthBeforeCheckout() {
        NetworkManager.shared.addReservationListener()
        NetworkManager.shared.checkActiveTable()
        NetworkManager.shared.addActiveOrderListener()
        APPSetting.shared.isDineIn ? dineInSendOrder() : onlineOrderCheckout()
    }

    @objc func checkoutButtonTapped() {
        
        if !NetworkManager.shared.isAuth {
            let authHome = AuthHomeViewController()
            authHome.modalPresentationStyle = .automatic
            self.present(authHome, animated: true) {
                
            }
            NotificationCenter.default.addObserver(self, selector: #selector(didAuthBeforeCheckout), name: .didAuthUser, object: nil)
//            self.navigationController?.pushViewController(AuthHomeViewController(), animated: true)
            
            return 
        }
        APPSetting.shared.isDineIn ? dineInSendOrder() : onlineOrderCheckout()
    }
    
}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cart.shared.meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell {
            
            cell.configureCartCellWithMeal(Cart.shared.meals[indexPath.row])
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return kCellHeightConstant + heightForCellDetailLabel(at: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mealViewController = MealViewController(meal: Cart.shared.meals[indexPath.row], isNewMeal: false)
        mealViewController.mealInCartIndex = indexPath.row
        // need to tell meal VC if its in cart mode : remove item button and change button text to update Cart
        tableView.cellForRow(at: indexPath)?.isSelected = false
        self.present(mealViewController, animated: true, completion: nil)
        
    }
    
    //- MARK: HELPERS
    
    private func heightForCellDetailLabel(at indexPath: IndexPath) -> CGFloat{
        let addonInfo = Cart.shared.meals[indexPath.row].addOnInfo
        var text = addonInfo
        let instruction = Cart.shared.meals[indexPath.row].instruction
        if instruction != nil {
            text =  text == "" ?  "Note: \(instruction!)" :  text + "\n\nNote: \(instruction!)"
            print(text)
        }
        
        if text == "" {
            return 0
        }
        
        let cell = CartTableViewCell()
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: cartTableView.frame.width - kPriceLabelWidth, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = cell.detailLabel.font
        label.text = text + "\n"
        label.sizeToFit()
        
        return label.frame.height
    }
    

    
}

extension CartViewController: CartDelegate {
    
    func didFinishUpdateCart() {
        
        if Cart.shared.isEmpty {
            checkoutButton.removeFromSuperview()
            cartTableView.removeFromSuperview()
            setupEmptyCartView()
        } else {
            cartFooterView.updateFooterLabels()
            //        checkoutButton.totalLabel.text = "$\(Cart.shared.cartTotal.roundedAmount.stringRepresentation)"
            cartTableView.reloadData()
        }
        
    }

}
