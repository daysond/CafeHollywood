//
//  CheckoutViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-09.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import Stripe
import Alamofire

enum PaymentMethod {
    case online
    case inStore
}

class CheckoutViewController: UIViewController, STPAuthenticationContext {

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
    
    internal var paymentContext: STPPaymentContext?
    internal var customerContext: STPCustomerContext?
    
    internal var paymentMethod: PaymentMethod = .online
    
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
        
        let cutlery = CustomOption(mainImageNmae: "cutlery", mainTitle: "UTENSILS, STRAWS, ETC", subTitle: "No, thank you.", subImageName: nil, optionType: .utensil)
        let pickupTime = CustomOption(mainImageNmae: "clock", mainTitle: "PICK UP TIME", subTitle: "Now", subImageName: nil, optionType: .scheduler)
        let paymentMethod = CustomOption(mainImageNmae: "creditCard", mainTitle: "PAYMENT METHOD", subTitle: "Visa", subImageName: nil, optionType: .payment)
        let note = CustomOption(mainImageNmae: "notes", mainTitle: "NOTE", subTitle: "", subImageName: nil, optionType: .note)
        
        options = [cutlery, pickupTime, paymentMethod, note]
   
    }
    
    private func setupView() {
        
        setupTableView()
        setupNavigationBar()
        view.backgroundColor = .white
        view.addSubview(placeOrderButton)
        placeOrderButton.configureTitle(title: "Place order")
        placeOrderButton.addTarget(self, action: #selector(placeOrder), for: .touchUpInside)
        
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
    
    
    func setupSTP() {
        
        let config = STPPaymentConfiguration.shared()
        //        config.additionalPaymentOptions = .applePay
        config.companyName = "DSN TECH"
        let theme = STPTheme()
        theme.accentColor = .black
        paymentContext = STPPaymentContext(customerContext: customerContext!, configuration: config, theme: theme)
        
        self.paymentContext!.delegate = self
        self.paymentContext!.hostViewController = self
        self.paymentContext!.paymentAmount = Cart.shared.cartTotal.amountInCents
        self.paymentContext?.paymentCurrency = "cad"
        
    }
    
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
    
    //MARK: - ACTION
    
    @objc func placeOrder() {
        
        switch paymentMethod {
            
        case .online:
            // send order && add listener to the oder status
            print("sending order")
            NetworkManager.shared.sendOrder { (error) in
                guard error == nil else { return }
                NetworkManager.shared.orderStatusDelegate = self
                print("order sent")
            }
            
            // now go to update status delegate
            
        case .inStore:
            print("in store")
        }
        print("place order logic here")
        
    }
    
    
    @objc func addCardButtonTapp() {
        
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        navigationController?.pushViewController(addCardViewController, animated: true)
        
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

    
    private func didFinishPayment() {

            self.navigationController?.dismiss(animated: true)

            Cart.shared.meals = []
            
        //then tell the res payment is made !
    }
    

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



//MARK: - STP DELEGATE


extension CheckoutViewController: STPAddCardViewControllerDelegate {

    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        navigationController?.popViewController(animated: true)
    }

    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        //        paymentMethod.stripeId
        print(paymentMethod.stripeId)
        addCardViewController.dismiss(animated: true, completion: nil)

    }

}

extension CheckoutViewController: STPPaymentContextDelegate{
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
    
        //        self.activityIndicator.animating = paymentContext.loading
        //        self.paymentButton.enabled = paymentContext.selectedPaymentOption != nil
        //        self.paymentLabel.text = paymentContext.selectedPaymentOption?.label
        //        self.paymentIcon.image = paymentContext.selectedPaymentOption?.image
        for option in options {
            if option.optionType == .payment {
                option.subTitle = paymentContext.selectedPaymentOption?.label ?? "Please select a payment method"
                optionsTableView.reloadData()
                break
            }
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        self.navigationController?.popViewController(animated: true)
        // Show the error to your user, etc.
    }
    
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
        StripeAPIClient.shared.createPaymenintent(paymentContext: paymentContext) { [self] (paymentIntentResponse, error) in
                    guard error == nil else {
                        print(error!)
//                        self.displayStatus(error!.localizedDescription)
                        return
                    }
                    
                    guard let responseDict = paymentIntentResponse as? [String : Any] else {
                        print("wrong data")
                        return
                    }

                       let clientSecret = responseDict["clientSecret"] as! String //local server
                    
                    
                    let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                    paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
                    paymentIntentParams.paymentMethodParams = paymentResult.paymentMethodParams
                    //                    let paymentMethodParams = STPPaymentMethodParams(card: self.paymentTextField.cardParams, billingDetails: nil, metadata: nil)
                    //                    paymentIntentParams.paymentMethodParams = paymentMethodParams
                    STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymenintent, error) in
                        
                        switch status {
                            
                        case .succeeded:
                            self.didFinishPayment()
                            print("paid \(paymenintent?.amount)")
                        case .failed:
                            print(error?.localizedDescription)
                          
                        case .canceled:
                           print("cancelled")
                        @unknown default:
                            print("defauklt")
                        }
                    }
                }
    
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
                switch status {
                case .error:
//                    self.showError(error)
                    print("hellp?")
                case .success:
//                    self.showReceipt()
                    print("succeesssss?????")
                case .userCancellation:
                    return // Do nothing
                @unknown default:
                    return 
        }
        
    }
 
}

//MARK: - UPDATE STATUS DELEGATE

extension CheckoutViewController: OrderStatusUpdateDelegate {
    
    func didUpdateStatusOf(order: String, to status: OrderStatus) {
        
        // once status is confirmed , request a payment then notify the restaurant the payment status
        switch status {
            
        case .confirmed:
            print("order confirmed")
            self.paymentContext?.requestPayment()
            
        case .cancelled:
            
            return
            
        case .ready:
            
            return
            
        default:
            return
        }
        
        
        
    }
    
    
    
    
    
    
}
