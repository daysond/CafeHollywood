//
//  CheckoutViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-09.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class CheckoutViewController: UIViewController {

    internal let optionsTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.allowsSelection = false
        tb.register(CheckoutOptionsTableViewCell.self, forCellReuseIdentifier: CheckoutOptionsTableViewCell.identifier)
        return tb
    }()
    
    internal let placeOrderButton = BlackButton()
    internal let cartFooterView = CartFooterView()
    
    internal var options: [CustomOption] = []
    internal let kCellHeightConstant: CGFloat = 80.0
    internal let kChangeButtonWidth: CGFloat = 88.0
    
    internal var menuLauncher: SlideInMenuLauncher?
    
    internal weak var scheduelerView: SchedulerView?
    
    init() {
        
//        self.customerContext = STPCustomerContext(keyProvider: StripeAPIClient())

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOptions()
        setupView()
//        setupSTP()
        
        
    }
    
    //MARK: - SETUPS
    
    private func setupOptions() {
        
        let cutlery = CustomOption(mainImageNmae: "cutlery", mainTitle: "UTENSILS, STRAWS, ETC", subTitle: "No, thank you.", optionType: .utensil)
        let pickupTime = CustomOption(mainImageNmae: "clock", mainTitle: "PICK UP TIME", subTitle: "Now", optionType: .scheduler)
//        let paymentMethod = CustomOption(mainImageNmae: "creditCard", mainTitle: "PAYMENT METHOD", subTitle: "Visa", subImageName: nil, optionType: .payment)
        let note = CustomOption(mainImageNmae: "notes", mainTitle: "NOTE", subTitle: Constants.checkoutNoteHolder ,optionType: .note)
        let gift = CustomOption(mainImageNmae: "gift", mainTitle: "GIFT OPTIONS", subTitle: "None", optionType: .gift)
        
        options = [cutlery, pickupTime, note, gift]
   
    }
    
    private func setupView() {
        
        setupTableView()
        setupNavigationBar()
        view.backgroundColor = .white
        view.addSubview(placeOrderButton)
        placeOrderButton.configureTitle(title: APPSetting.shared.isRestaurantOpen ? "Place order" : "Restaurant Closed")
        placeOrderButton.backgroundColor = APPSetting.shared.isRestaurantOpen ? .black : .lightGray
        placeOrderButton.addTarget(self, action: #selector(placeOrder), for: .touchUpInside)
        placeOrderButton.isEnabled = APPSetting.shared.isRestaurantOpen
        
        NSLayoutConstraint.activate([
            
            optionsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionsTableView.bottomAnchor.constraint(equalTo: placeOrderButton.topAnchor),
            
            placeOrderButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            placeOrderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            placeOrderButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            placeOrderButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -0),
        ])
        
        
        
    }
    
    private func setupTableView() {
        
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        //        optionsTableView.contentInsetAdjustmentBehavior = .never
        view.addSubview(optionsTableView)
        setupFooterView()
        
    }
    
    private func setupFooterView() {
        
        optionsTableView.tableFooterView = cartFooterView
        cartFooterView.frame.size.height = 200
        cartFooterView.backgroundColor = .white
        cartFooterView.updateFooterLabels()
        
    }
    
    private func setupNavigationBar() {
 
        navigationItem.title = "Summary"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let backButton = UIBarButtonItem(image: UIImage(named: "back84x84"), style: .plain, target: self, action:  #selector(backButtonTapped))

        navigationController?.navigationBar.tintColor = .black

        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()

    }
    
    

    
    //MARK: - ACTION
    
    @objc func placeOrder() {
        
        // send order && add listener to the oder status
        print("sending order")
        NetworkManager.shared.placeOrder { (error) in
            guard error == nil else { return }
//            NetworkManager.shared.orderStatusDelegate = self
            self.dismiss(animated: true, completion: nil)
            Cart.resetCart()
            self.tabBarController?.selectedIndex = 2
        }
        
        // now go to update status delegate
        

    }
    

    
    @objc private func backButtonTapped() {
         
         self.navigationController?.popViewController(animated: true)
     }
    
    //MARK: - HELPER
    
    private func heightForCellLabel(text: String) -> CGFloat{
        
        let cell = CheckoutOptionsTableViewCell()
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: optionsTableView.frame.width - kChangeButtonWidth, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = cell.rowSubLabel.font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height - 18
    }

    
//    private func didFinishPayment() {
//
//            self.navigationController?.dismiss(animated: true)
//
//            Cart.shared.meals = []
//
//        //then tell the res payment is made !
//    }
    

}

//MARK: - TABLE VIEW DELEGATE

extension CheckoutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CheckoutOptionsTableViewCell.identifier, for: indexPath) as? CheckoutOptionsTableViewCell {
            cell.indexPath = indexPath
            cell.delegate = self
            cell.configureCell(with: options[indexPath.row])
            return cell
            
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeightConstant + heightForCellLabel(text: options[indexPath.row].subTitle)
    }
    
}


//MARK: - UPDATE STATUS DELEGATE
//
//extension CheckoutViewController: OrderStatusUpdateDelegate {
//
//    func didUpdateStatusOf(order: String, to status: OrderStatus) {
//
//        // once status is confirmed , request a payment then notify the restaurant the payment status
//        switch status {
//
//        case .confirmed:
//            print("order confirmed")
//
//        case .cancelled:
//
//            return
//
//        case .ready:
//
//            return
//
//        default:
//            return
//        }
//
//
//
//    }
//
//
//
//
//
//
//}
