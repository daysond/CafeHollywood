//
//  CartViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-06-29.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import Stripe

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

    
//    override func viewDidLayoutSubviews() {
//        let footerLabelHeight = cartFooterView.totalLabel.frame.height
//        cartFooterView.frame.size.height = (footerLabelHeight + 8 ) * 5 + 32
//    }
    
    
    // MARK: - VIEW SET UP
    
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
        
        cartTableView.delegate = self
        cartTableView.dataSource = self
        Cart.shared.delegate = self
        view.backgroundColor = .offWhite
        view.addSubview(cartTableView)
        
        setupButtons()
        setupFooterView()
        
        NSLayoutConstraint.activate([
            
            cartTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cartTableView.bottomAnchor.constraint(equalTo: checkoutButton.topAnchor),
            cartTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cartTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
        ])
    }
    
    private func setupButtons() {
        
        view.addSubview(checkoutButton)
        checkoutButton.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
//        checkoutButton.totalLabel.text = "$\(Cart.shared.cartTotal.roundedAmount.stringRepresentation)"
        switch APPSetting.shared.isDineIn {
        
        case true:
            let sendOrderButton = BlackButton()
            view.addSubview(sendOrderButton)
            sendOrderButton.addTarget(self, action: #selector(orderButtonTapped), for: .touchUpInside)
            checkoutButton.configureTitle(title: "Pay")
            sendOrderButton.configureTitle(title: "Send Order")
            
            NSLayoutConstraint.activate([
                
                checkoutButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
                checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                checkoutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                checkoutButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.49),
                
                sendOrderButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
                sendOrderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                sendOrderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.49),
                sendOrderButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -0),
            ])
            
        case false:
            
            checkoutButton.configureTitle(title: "Checkout")
            NSLayoutConstraint.activate([
                checkoutButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
                checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                checkoutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                checkoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -0),
            ])
        }
    }
    
    private func setupFooterView() {
        
        cartTableView.tableFooterView = cartFooterView
        cartFooterView.frame.size.height = 200
        cartFooterView.backgroundColor = .white
        cartFooterView.updateFooterLabels()
        
    }
    
    //MARK: - HELPERS
    
    private func prepareForCheckout() {
        
//        if APPSetting.shared.user.stripeID == nil {
//
//            DispatchQueue.global(qos: .background).async {
//                let result = StripeAPIClient.shared.createCustomer()
//
//                switch result {
//
//                case .success(let stripeID):
//
//                    DispatchQueue.main.async {
//                        print("did create id \(stripeID)")
//                        UserDefaults.standard.set(stripeID, forKey: "stripeID")
//                        NetworkManager.shared.updateCurrentUserStripeID(stripeID: stripeID)
//                        self.pushCheckoutViewController()
//
//                    }
//
//                case .failure(let error):
//
//                    print(error.localizedDescription)
//
//                    DispatchQueue.main.async {
//                         self.dismissLoadingView()
//                    }
//
//
//                }
//            }
//        } else {
//
//            pushCheckoutViewController()
//
//
//        }
        
        pushCheckoutViewController()
        
        
    }
    
    private func pushCheckoutViewController() {
        
//        let customerContext = STPCustomerContext(keyProvider: StripeAPIClient())
        let checkoutVC = CheckoutViewController()
//        checkoutVC.customerContext = customerContext
        dismissLoadingView()
        self.navigationController?.pushViewController(checkoutVC, animated: true)
        
    }
    
    private func createLoadingView() {
        
        addChild(loadingView)
        loadingView.view.frame = view.frame
        view.addSubview(loadingView.view)
        loadingView.didMove(toParent: self)

        // wait two seconds to simulate some work happening
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            // then remove the spinner view controller
//            child.willMove(toParent: nil)
//            child.view.removeFromSuperview()
//            child.removeFromParent()
//        }
    }
    
    private func dismissLoadingView() {
        
        
        loadingView.willMove(toParent: nil)
        loadingView.view.removeFromSuperview()
        loadingView.removeFromParent()
        
    }
    
    
    // MARK: - ACTIONS
    
    @objc func orderButtonTapped() {
        
        
        NetworkManager.shared.sendOrder { (err) in
            print("error \(err)")
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func checkoutButtonTapped() {
        
        /*
         Show loading
         IMPORTANT:
         check if user has a stripeID, if not, create one !!!!
         
         StripeAPIClient.shared.createCustomer()
         
         1. preload customer context
         let customerContext = STPCustomerContext(keyProvider: MyAPIClient())
         2.assign customerContext to the CheckoutViewController
    */
        
        createLoadingView()
        prepareForCheckout()
        
//        let checkoutVC = CheckoutViewController()
//        navigationController?.pushViewController(checkoutVC, animated: true)
        
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
