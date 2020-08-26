//
//  StripeViewComtroller.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-10.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Stripe
import Alamofire
import UIKit

class StripeViewController: UIViewController, STPAuthenticationContext {
    
    var paymentContext: STPPaymentContext?
    var customerContext: STPCustomerContext?
    
    var paymentTextField = STPPaymentCardTextField()
    
    var outputTextview = UITextView()
    
    var payButton = UIButton()
    
    var theRealPayButton = UIButton()
    
    var addCardButton = UIButton()
    
    var optionsButton = UIButton()
    
    var imageview = UIImageView()
    
    let backendURL = URL(string: "https://hysor-stripe.herokuapp.com")!
    
    init() {
        
        
        self.customerContext = STPCustomerContext(keyProvider: StripeAPIClient())
        let config = STPPaymentConfiguration.shared()
        config.additionalPaymentOptions = .applePay
        config.companyName = "DSN TECH"
        paymentContext = STPPaymentContext(customerContext: customerContext!, configuration: config, theme: .default())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(paymentTextField)
        paymentTextField.frame = CGRect(x: 16, y: 200, width: view.frame.width - 32, height: 64)
        
        view.addSubview(payButton)
        payButton.frame = CGRect(x: 16, y: 270, width: view.frame.width - 32, height: 48)
        payButton.setTitle("Pay", for: .normal)
        payButton.addTarget(self, action: #selector(payButtonTapp), for: .touchUpInside)
        payButton.backgroundColor = .black
        
        view.addSubview(theRealPayButton)
        theRealPayButton.frame = CGRect(x: 16, y: 396, width: view.frame.width - 32, height: 48)
        theRealPayButton.setTitle("R Pay", for: .normal)
        theRealPayButton.setTitle("R add payment", for: .disabled)
        theRealPayButton.addTarget(self, action: #selector(realpayButtonTapp), for: .touchUpInside)
        theRealPayButton.backgroundColor = .black
        
        
        view.addSubview(optionsButton)
        optionsButton.setTitle("options", for: .normal)
        optionsButton.addTarget(self, action: #selector(optionsbuttonTapped), for: .touchUpInside)
        optionsButton.backgroundColor = .black
        optionsButton.frame = CGRect(x: 16, y: 330, width: view.frame.width - 32, height: 50)
        
        view.addSubview(addCardButton)
        addCardButton.frame = CGRect(x: 16, y: 462, width: view.frame.width - 32, height: 48)
        addCardButton.setTitle("Add Card", for: .normal)
        addCardButton.addTarget(self, action: #selector(addCardButtonTapped), for: .touchUpInside)
        addCardButton.backgroundColor = .black
        
        view.addSubview(outputTextview)
        outputTextview.frame = CGRect(x: 16, y: 520, width: view.frame.width - 32, height: 300)
        outputTextview.font = .systemFont(ofSize: 24)
        
        view.addSubview(imageview)
        imageview.backgroundColor = .red
        imageview.frame = CGRect(x: 16, y: 100, width: 50, height: 50)
        
        
        setupSTP()
//        StripeAPIClient.shared.createCustomer()
    }
    
    func setupSTP() {
        
        
        //1. set up an STP Custoner Context
        
        /*
         To reduce load times, preload your customer’s information by initializing STPCustomerContext before they enter your payment flow.
         
         if your current user logs out of the app and a new user logs in, create a new instance of STPCustomerContext or clear the cached customer using the provided clearCachedCustomer method. On your backend, create and return a new ephemeral key for the Customer object associated with the new user.
         */
        
        //2.set up an STP payment context
        
        //        self.paymentContext = STPPaymentContext(customerContext: customerContext!)
        self.paymentContext!.delegate = self
        self.paymentContext!.hostViewController = self
        self.paymentContext!.paymentAmount = Cart.shared.cartTotal.amountInCents
        self.paymentContext?.paymentCurrency = "cad"
        print("set up STP! ")
        
    }
    
    
    func displayStatus(_ msg: String) {
        
        outputTextview.text = outputTextview.text + msg + "\n"
        
    }
    
    @objc func realpayButtonTapp() {
        
        self.paymentContext?.requestPayment()
        
    }
    
    @objc func optionsbuttonTapped() {
        print("options tapped")
        paymentContext?.pushPaymentOptionsViewController()
        
    }
    
    @objc func addCardButtonTapped() {
        print("wtf is going on ")
//        let addCardViewController = STPAddCardViewController()
//        addCardViewController.delegate = self
//        navigationController?.pushViewController(addCardViewController, animated: true)
//
    }
    
    
    @objc func payButtonTapp() {
        print("pay tapped")
        
        // 1. create a payment intent / server side
        // 2. confirm the payment intent / client side
        
        //make a POST request to the /create_payment_intent endpoint
        displayStatus("creating intent")
        
        createPaymenintent { [self] (paymentIntentResponse, error) in
            guard error == nil else {
                print(error!)
                self.displayStatus(error!.localizedDescription)
                return
            }
            
            guard let responseDict = paymentIntentResponse as? [String : Any] else {
                print("wrong data")
                return
            }
            
            let clientSecret = responseDict["clientSecret"] as! String  // secret for heroku
            //            print(responseDict)
            self.displayStatus("created intent")
            // 3.confirm the paymentIntent using STPPaymentHandler
            // implement deledates
            
            let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
            let paymentMethodParams = STPPaymentMethodParams(card: self.paymentTextField.cardParams, billingDetails: nil, metadata: nil)
            paymentIntentParams.paymentMethodParams = paymentMethodParams
            //            let paymentCard = self.paymentContext?.selectedPaymentOption
            //            paymentIntentParams.paymentMethodOptions = paymentCard
            
            STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymenintent, error) in
                
                switch status {
                    
                case .succeeded:
                    
                    self.displayStatus("Payment sucessful $\(paymenintent?.amount ?? 00)")
                case .failed:
                    self.displayStatus("payment failed")
                case .canceled:
                    self.displayStatus("payment cancelled")
                @unknown default:
                    print("defauklt")
                }
                
                
            }
            
            
        }
        
        
        
        
    }
    
    func createPaymenintent(completion: @escaping STPJSONResponseCompletionBlock) {
        
//        let url = backendURL.appendingPathComponent("create_payment_intent")
        let url2 = Constants.localhostURLString.appendingPathComponent("create-payment-intent")
        let cusId = User.shared.stripeID
        //        let parameters: [String: Any] = ["amount": amount, "currency": currency, "customerId": customerID]
        let params = ["amount": self.paymentContext?.paymentAmount, "currency" : self.paymentContext?.paymentCurrency, "customerId": cusId! ] as [String : Any]
        
        AF.request(url2, method: .post, parameters: params, encoding: JSONEncoding.default).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
                
            case .failure(let error):
                
                completion(nil, error)
                
            case .success(let json):
                
                completion(json as? [String: Any], nil)
                
            }
        }
        
        
    }

    
    
    //MARK: - STPPAYMENTAUTHENTICATION DELEGATE
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
    
    
    
}


extension StripeViewController: STPPaymentContextDelegate{
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
        //        self.payButton.isEnabled = paymentContext.selectedPaymentOption != nil
        
        // triggered when user updates payment context eg. payment method / new shipping info . good place to update UI
        //        self.activityIndicator.animating = paymentContext.loading

        //        self.paymentLabel.text = paymentContext.selectedPaymentOption?.label
        displayStatus(paymentContext.selectedPaymentOption?.label ?? "no selected payment option")
        imageview.image = paymentContext.selectedPaymentOption?.image
        displayStatus(paymentContext.selectedPaymentOption?.description ?? " ?")
        
        //        self.paymentIcon.image = paymentContext.selectedPaymentOption?.image
        
        //        print(paymentContext.selectedShippingMethod)
        //        self.paymentContext = paymentContext
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        self.navigationController?.popViewController(animated: true)
        // Show the error to your user, etc.
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
        
        //make a POST request to the /create_payment_intent endpoint
        displayStatus("creating intent from context")
        
        createPaymenintent { [self] (paymentIntentResponse, error) in
            guard error == nil else {
                print(error!)
                self.displayStatus(error!.localizedDescription)
                return
            }
            
            guard let responseDict = paymentIntentResponse as? [String : Any] else {
                print("wrong data")
                return
            }
            
//            let clientSecret = responseDict["secret"] as! String  //heroku version 
               let clientSecret = responseDict["clientSecret"] as! String //local server
            
            //            print(responseDict)
            self.displayStatus("created intent")
            // 3.confirm the paymentIntent using STPPaymentHandler
            // implement deledates
            
            let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
            paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
            paymentIntentParams.paymentMethodParams = paymentResult.paymentMethodParams
            //                    let paymentMethodParams = STPPaymentMethodParams(card: self.paymentTextField.cardParams, billingDetails: nil, metadata: nil)
            //                    paymentIntentParams.paymentMethodParams = paymentMethodParams
            STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymenintent, error) in
                
                switch status {
                    
                case .succeeded:
                    
                    self.displayStatus("Payment sucessful $\(paymenintent?.amount ?? 00)")
                    paymenintent?.setupFutureUsage
                case .failed:
                    self.displayStatus("payment failed \(error.debugDescription)")
                  
                case .canceled:
                    self.displayStatus("payment cancelled")
                @unknown default:
                    print("defauklt")
                }
                
                
            }
            
            
        }
        
        // Request a PaymentIntent from your backend
        //        MyAPIClient.sharedClient.createPaymentIntent(products: self.products, shippingMethod: paymentContext.selectedShippingMethod) { result in
        //            switch result {
        //            case .success(let clientSecret):
        //                // Assemble the PaymentIntent parameters
        //                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        //                paymentIntentParams.paymentMethodId = paymentResult.paymentMethod.stripeId
        //
        //                // Confirm the PaymentIntent
        //                STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
        //                    switch status {
        //                    case .succeeded:
        //                        // Your backend asynchronously fulfills the customer's order, e.g. via webhook
        //                        completion(.success, nil)
        //                    case .failed:
        //                        completion(.error, error) // Report error
        //                    case .canceled:
        //                        completion(.userCancellation, nil) // Customer cancelled
        //                    @unknown default:
        //                        completion(.error, nil)
        //                    }
        //                }
        //            case .failure(let error):
        //                completion(.error, error) // Report error from your API
        //                break
        //            }
        //        }
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
        //        switch status {
        //        case .error:
        //            self.showError(error)
        //        case .success:
        //            self.showReceipt()
        //        case .userCancellation:
        //            return // Do nothing
        //        }
        
    }
    
}


extension StripeViewController: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        //        paymentMethod.stripeId
        print(paymentMethod.stripeId)
        addCardViewController.dismiss(animated: true, completion: nil)
        
    }
    
}
