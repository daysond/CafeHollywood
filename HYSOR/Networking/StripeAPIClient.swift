//
//  StripeClientAPI.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-09.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import Stripe
import Alamofire
import Firebase



class StripeAPIClient: NSObject, STPCustomerEphemeralKeyProvider{
    
//    let baseURL = URL(string:  "http://localhost:8080")!
    static let shared = StripeAPIClient()
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        let cusId = User.shared.stripeID
        
        // Firebase url
//        let url = Constants.localhostURLString.appendingPathComponent("ephemeral-keys")
//        let parameters = ["apiVersion": apiVersion, "customerId": cusId!]
        
        //heroku url
        let url = Constants.baseURL.appendingPathComponent("ephemeral_keys")
        let parameters = ["api_version": apiVersion, "customer_id": cusId!]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:] ).validate(statusCode: 200..<300).responseJSON { (responseJSON) in
            
            switch responseJSON.result {
                
            case .success(let json):
                // put guard stament here incase json file is nil 
                completion(json as? [String: Any], nil)
                print("JSON \(json)")
                
            case .failure(let error):
                
                completion(nil, error)
                print("error \(error.errorDescription)")
            }
            
            
        }
        
        
        
    }
    
    func createPaymenintent(paymentContext: STPPaymentContext,completion: @escaping STPJSONResponseCompletionBlock) {
        
        let cusId = User.shared.stripeID
        // fire base
//        let url = Constants.localhostURLString.appendingPathComponent("create-payment-intent")
//        let params = ["amount": paymentContext.paymentAmount, "currency" : paymentContext.paymentCurrency, "customerId": cusId! ] as [String : Any]
        
        //heroku
        let url = Constants.baseURL.appendingPathComponent("create_payment_intent")
        let params = ["amount": paymentContext.paymentAmount, "currency" : paymentContext.paymentCurrency, "customer_id": cusId! ] as [String : Any]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
                
            case .failure(let error):
                
                completion(nil, error)
                
            case .success(let json):
                
                completion(json as? [String: Any], nil)
                
            }
        }
        
    }
    
   //MARK: - CREATE CUSTOMERS
    
    func createCustomer() -> Result<String, Error> {

        let user = User.shared

        //fire base
//        let customerData: [String: String] = [ "email": user.email, "name" : user.name, "description": user.uid, ]
//
//        let url = Constants.localhostURLString.appendingPathComponent("create-customer")

        //heroku
        let customerData: [String: String] = [ "email": user.email, "name" : user.name, "description": user.uid, ]

        let url = Constants.baseURL.appendingPathComponent("create_customer")
        
        
        
        let semaphore = DispatchSemaphore(value: 0)
         
        var result:  Result<String, Error>!
        
        AF.request(url, method: .post, parameters: customerData, encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).responseJSON { (responseJSON) in

            switch responseJSON.result {

            case .success(let json) :
                guard let jsonDict = json as? [String: Any], let id = jsonDict["id"] as? String else {
                    result = .failure(NetworkError.jsonDataError)
                    semaphore.signal()
                    return
                }
                result = .success(id)
                semaphore.signal()
                
            case .failure(let error):
                result = .failure(error)
                semaphore.signal()
            }
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return result
    }
    
    func createCustomerWithAuthDateResult(_ authDateResult: AuthDataResult) -> Result<[String: Any], Error> {
        
        let semaphore = DispatchSemaphore(value: 0)
         
        var result:  Result<[String: Any], Error>!
        
        let url = Constants.localhostURLString.appendingPathComponent("create-customer")
        
        var customerData = [String: String]()
        customerData["email"] = authDateResult.user.email
        customerData["phone"] = authDateResult.user.phoneNumber ?? ""
        customerData["name"] = APPSetting.shared.customerName ?? "No name"
        customerData["description"] = authDateResult.user.uid
        
        AF.request(url, method: .post, parameters: customerData, encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).responseJSON { (responseJSON) in
            
            switch responseJSON.result {
            
            case .success(let json) :
                guard let jsonDict = json as? [String: Any] else {
                    result = .failure(NetworkError.jsonDataError)
                    semaphore.signal()
                    return
                }
                result = .success(jsonDict)
                semaphore.signal()
                
            case .failure(let error):
                result = .failure(error)
                semaphore.signal()
            }
            
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return result
      
    }
    
    

    
    
    
    
}
