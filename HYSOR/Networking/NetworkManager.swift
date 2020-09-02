//
//  NetworkManager.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-11.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

enum NetworkError: Error {
    case badURL
    case standard
    case jsonDataError
    case argumentError
    case invalidData
}


protocol OrderStatusUpdateDelegate {
    
    func didUpdateStatusOf(order: String, to status: OrderStatus)
    
}

protocol ActiveOrderListenerDelegate {
    func didReceiveActiveOrder(_ receipt: Receipt)
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let databaseRef = Firestore.firestore()
    
    private var ordersRef: CollectionReference  {
        let db = Firestore.firestore()
        let ref = db.collection("orders")
        return ref
    }
    
    private var resturantsRef: CollectionReference  {
        let db = Firestore.firestore()
        let ref = db.collection("resturants")
        return ref
    }
    
    private var activeOrderListener: ListenerRegistration?
    
    private var orderStatusListener: ListenerRegistration?
    
    var isAuth: Bool {
        get{
            return Auth.auth().currentUser != nil
        }
    }
    
    var currentUserUid: String? {
        get {
            return Auth.auth().currentUser?.uid
        }
    }
    
    var orderStatusDelegate: OrderStatusUpdateDelegate?
    var activeOrderListenerDelegate: ActiveOrderListenerDelegate?
    
    // CACHE
    let preferencesCache = NSCache<NSString, PreferenceCache>()
    

    
    // MARK: - VERSION CHECKING
    
    func getCurrentVersion(completion: @escaping (String?) -> Void) {

        
        databaseRef.collection("version").document("versionNumber").getDocument { (snapshot, error) in
            guard error == nil else {
                print("error")
                return
            }
            
            if let data = snapshot?.data(), let version = data["menuVersion"] as? String {
                completion(version)
            }
        }
    }
    
    
    
    func signIn(completion: @escaping (AuthDataResult?, Error?) -> Void) {
        
        Auth.auth().signInAnonymously { (result, err) in
            completion(result,err)
        }
        
    }
    
    
    
    // MARK: - Auth
    
    func signInWith(_ email: String, _ password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            completion(authDataResult, error)
        }
        
        
    }
    
    
    func signUpWith(_ email: String, _ password: String, _ name: String) -> Result<AuthDataResult, Error> {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: Result<AuthDataResult, Error>!
        
        Auth.auth().createUser(withEmail: email, password: password) { (dataResult, err) in
            
            guard err == nil else {
                print(err!.localizedDescription)
                result = .failure(err!)
                semaphore.signal()
                return
            }
            guard let dataResult = dataResult else { return }
            
            self.setDataOfCustomer(name: name, with: dataResult)
            
            result = .success(dataResult)
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return result
    }
    
    private func setDataOfCustomer(name: String, with dataResult: AuthDataResult) {
        
        guard let email = dataResult.user.email else {
            print("no email found !!")
            return }
        
        let uid = dataResult.user.uid
        
        APPSetting.storeUserInfo(email, name, uid, nil)
        
        let data =  ["name": name, "email": email, "uid": uid ] as [String : Any]
        
        let customerReference = databaseRef.collection("customers").document(uid)
        
        customerReference.setData(data) { (err) in
            print(err?.localizedDescription)
        }
    }
    
    
    func signOut() throws {
        
        do {
            try Auth.auth().signOut()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    
    
//    // MARK: - Set/ Get Stripe ID
//
//    func setStripeCustomerInfoToDataBase(_ info: [String: Any]) -> Result<String, Error>{
//        //
//        let semaphore = DispatchSemaphore(value: 0)
//        //
//        var result: Result<String, Error>!
//
//        guard let uid = info["description"] as? String, let stripeID = info["id"] as? String else {
//            result = .failure(NetworkError.jsonDataError)
//            return result
//        }
//
//        let data = ["stripeID": stripeID]
//
//        let customerReference = databaseRef.collection("customers").document(uid)
//        customerReference.updateData(data) { (error) in
//
//            result = error == nil ? .success(stripeID) : .failure(error!)
//
//            semaphore.signal()
//        }
//
//        _ = semaphore.wait(timeout: .distantFuture)
//
//        return result
//    }
//
//
//    func fetchUserInfoFromDataBase(completion: @escaping (Result<[String: String], Error>) -> Void ) {
//
//        guard let uid = Auth.auth().currentUser?.uid else {
//            completion(.failure(NetworkError.argumentError))
//            return
//        }
//
//        let customerReference = databaseRef.collection("customers").document(uid)
//        customerReference.getDocument { (snapshot, error) in
//            guard error == nil else {
//                completion(.failure(error!))
//                return
//            }
//
//            guard let data = snapshot?.data() as? [String: String] else {
//                completion(.failure(NetworkError.jsonDataError))
//                return
//            }
//
//            completion(.success(data))
//        }
//
//    }
//
//    func updateCurrentUserStripeID(stripeID: String) {
//
//        let uid = User.shared.uid
//        let customerReference = databaseRef.collection("customers").document(uid)
//
//        let data = ["stripeID": stripeID]
//
//        customerReference.updateData(data)
//
//    }
    
    
    
    
    //MARK: - Get Meals & Menus
    
    func getMenu(type: MenuType, completion: @escaping ([Menu]?) -> Void) {
        
        databaseRef.collection(type.rawValue).getDocuments { (snapshot, err) in
            
            var menus = [Menu]()
            
            guard let snapshot = snapshot else { return }
            guard err == nil else {
                print(err.debugDescription)
                return
            }
            
            snapshot.documents.forEach { (doc) in
                
                let uid = doc.documentID
                guard let imageURL = doc["imageURL"] as? String,
                let isSingleMealMenu = doc["isSingleMealMenu"] as? Bool,
                let mealsInUID = doc["mealsInUID"] as? [String],
                let menuDetail = doc["menuDetail"] as? String,
                    let menuTitle = doc["menuTitle"] as? String else {
                        print("cannot get menu for \(uid)")
                        return
                }
                
                let menu = Menu(uid: uid, menuTitle: menuTitle, menuDetail: menuDetail, mealUIDs: mealsInUID, imageURL: imageURL)
                menus.append(menu)
            }
            
            completion(menus)
           
        }
        
    }
    
    
    
    
    func fetchMealWithMealUID(_ uid: String, completion: @escaping (Meal?) -> Void) {
        //
//        let resRef = databaseRef.collection("restaurants").document("YQk95Gnq5nQWWGqg7PIH")
        
        let group = DispatchGroup()
        
        var tempPreferences: [Preference] = []
        
        databaseRef.collection("meals").document(uid).getDocument { (documentSnapShot, error) in
           
            guard error == nil, let data = documentSnapShot?.data() else {
                print(error.debugDescription)
                print("wrong data \(uid) \n \(documentSnapShot?.data())")
                completion(nil)
                return
                
            }
            
            guard let mealUID = documentSnapShot?.documentID else { print("uid wrong"); return }
            guard let name = data["name"] as? String else { print("name wrong"); return }
            guard let price = data["price"] as? Double else { print("price wrong \(uid)"); return }
            
            let detail = data["detail"] as? String
            let imageURL = data["imageURL"] as? String
//            let priceInInt = Int(price * 100)
//            let priceInDecimal = Decimal(integerLiteral: priceInInt) / 100
            let comboTag = data["comboTag"] as? Int
            var meal = Meal(uid: mealUID, name: name, price: Decimal(floatLiteral: price), details: detail ?? "", imageURL: imageURL, preferences: nil, comboMealTag: comboTag)
            
            if let comboType = data["comboType"] as? Int, let type = ComboType(rawValue: comboType) {
                meal.comboType = type
            }
            
            if let preferenceUIDs = data["preferences"] as? [String] {
                for uid in preferenceUIDs {
                    
                    group.enter()
                    
                    self.fetchMealPreferencesWithUID(uid) { (preference) in
                        guard let preference = preference else { group.leave(); return }
                        tempPreferences.append(preference)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    tempPreferences.sort { (p1, p2) -> Bool in
                   
                        return p1.isRequired
//                        if p1.isRequired && !p2.isRequired {
//                            return p1.isRequired
//                        } else {
//                            return p1.uid < p2.uid
//                        }
                    }
                    meal.preferences = tempPreferences
                    completion(meal)
                }
            } else {
                completion(meal)
            }
        }
        
    }
    
    fileprivate func fetchPreferenceItemWithUID(_ uid: String, completion: @escaping (PreferenceItem?) -> Void) {
        
//        let resRef = databaseRef.collection("restaurants").document("YQk95Gnq5nQWWGqg7PIH")
        
        databaseRef.collection("preferenceItems").document(uid).getDocument { (snapshot, error) in
            guard error == nil, let data = snapshot?.data() else {
                print(error.debugDescription)
                print("wrong item data at \(uid)")
                return
            }
            guard let uid = snapshot?.documentID else { print("no snapshot"); return }
            guard let name = data["name"] as? String else { print("no item name \(uid)"); return }
            
            var item = PreferenceItem(name: name, price: nil, uid: uid)
            if let price = data["price"] as? Double {
//                let priceInInt = Decimal(price * 100)
                
                item.price = Money(amt: price)

            }
            
            if let tag = data["comboTag"] as? Int {
                item.comboTag = tag
            }
            
            completion(item)
            
        }
    }
    
    
    
    fileprivate func fetchMealPreferencesWithUID(_ uid: String, completion: @escaping (Preference?) -> Void) {
        
        if let preferenceFromCache = preferencesCache.object(forKey: uid as NSString) {
            print("found cache")
            completion(preferenceFromCache.preference)
            return
        }
        
//        let resRef = databaseRef.collection("restaurants").document("YQk95Gnq5nQWWGqg7PIH")
        
        let group = DispatchGroup()
        
        var tempItems: [PreferenceItem] = []
        
        databaseRef.collection("preferences").document(uid).getDocument { (snapshot, error) in
            guard error == nil, let data = snapshot?.data() else {
                print(error.debugDescription)
                print("wrong preference data")
                return
            }
            
            guard let isRequired = data["isRequired"] as? Bool else { print("isRequired wrong"); return }
            guard let name = data["name"] as? String else { print("name wrong"); return }
            guard let maxItemQuantity = data["maxItemQuantity"] as? Int else { print("maxItemQuantity wrong"); return }
            guard let maxPick = data["maxPick"] as? Int else { print("maxPick wrong"); return }
            guard let itemUIDs = data["items"] as? [String] else { print("no items"); return }
            
            for itemUID in itemUIDs {
                
                group.enter()
                
                self.fetchPreferenceItemWithUID(itemUID) { (item) in
                    guard let item = item else { group.leave(); return }
                    tempItems.append(item)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                tempItems.sort { (item1, item2) -> Bool in
                    item1.uid < item2.uid
                }
//                print(tempItems)
                let preference = Preference(uid: uid, isRequired: isRequired, name: name, maxPick: maxPick, preferenceItems: tempItems, maxItemQuantity: maxItemQuantity)
                self.preferencesCache.setObject(PreferenceCache(preference), forKey: uid as NSString)
                completion(preference)
            }
        }
    }
    
    
    //MARK: - Send / Get Order
    
    func sendOrder(completion: @escaping (Error?) -> Void) {
        //DATA
        let orderID = String.randomString(length: 6)
        
        let restaurantID = Cart.shared.representation["restaurantID"] as! String
        
        let customerID = Cart.shared.representation["customerID"] as! String
        
        let group = DispatchGroup()
        
        var err: Error?
        //References
        // send order
        let orderDestinationRef = databaseRef.collection("orders").document(orderID)
        // tell res and cus the active order
        let customerActiveOrderRef = databaseRef.collection("customers").document(customerID).collection("activeOrders").document(orderID)
        
        let restaurantActiveOrderRef = databaseRef.collection("restaurants").document(restaurantID).collection("activeOrders").document(orderID)
        // Send data to database
        group.enter()
        
//        databaseRef.collection("orders").order(by: "timestamp").limit(to: 5)
        
        orderDestinationRef.setData(Cart.shared.representation) { (error) in
            guard error == nil else {
                orderDestinationRef.delete()
                group.leave()
                err = error
                return
            }
            group.leave()
        }
        
        guard err == nil else { completion(err); return } // if err, exti the function ,if no error continue to notify res and cus
        
        group.enter()
        
        customerActiveOrderRef.setData(["hasPaid": false]) { (error) in
                err = error
                group.leave()
            }
            
            group.enter()
        
        restaurantActiveOrderRef.setData(["hasPaid": false]) { (error) in
                err = error
                group.leave()
                
            }

        
        group.notify(queue: .main) {
            
            guard err == nil else {
                orderDestinationRef.delete()
                customerActiveOrderRef.delete()
                restaurantActiveOrderRef.delete()
                completion(err)
                return
            }
            
            self.trackStatusOfOrder(orderID)
            completion(err)
        }
        
    }
    
    private func trackStatusOfOrder(_ orderID: String) {
      
        orderStatusListener = ordersRef.document(orderID).addSnapshotListener({ (snapshot, error) in
            
            guard error == nil else {
                print("Error adding listener to channel \(snapshot.debugDescription)")
                return
            }
            guard let data = snapshot?.data(), let statusCode = data["orderStatus"] as? Int, let newStatus = OrderStatus(rawValue: statusCode) else { return }
            
            self.orderStatusDelegate?.didUpdateStatusOf(order: orderID, to: newStatus)
            
            switch newStatus {
                
            case .confirmed:
//                self.databaseRef.collection("customer_order").document(APPSetting.shared.user.uid).collection("orders").document(orderID).setData(["timestamp": Date.timestampInInt()])
                return
                
            case .completed:
                print("shoud delete")
                self.databaseRef.collection("customers").document(APPSetting.customerUID).collection("activeOrders").document(orderID).delete()
                return
                
            default:
                return
                
            }
        })
        
    }
    
    
    
    
    
    //MARK: - PULL ORDER HISTORY
    
    
    func fetchOrderHistory(completion: @escaping ([Receipt]) -> Void ) {
        
        let orderRef = databaseRef.collection("orders")
        
        var receipts: [Receipt] = []
 
        orderRef.getDocuments { (snapShots, error) in
            
            guard error == nil else {
                //error handling here
                return
            }
            
            guard let documents = snapShots?.documents else { return }

            for doc in documents {
                
                if let receipt = Receipt(id: doc.documentID, data: doc.data()) {
                    receipts.append(receipt)
                }
            }
            completion(receipts)
        }
    }
    
    // GET Single Order
    private func fetchOrder(_ orderID: String, completion: @escaping (Receipt?) -> Void ) {
        
        let orderRef = databaseRef.collection("orders")
        
        orderRef.document(orderID).getDocument { (snapshot, error) in
            
            guard error == nil else { return }
            
            guard let data = snapshot?.data() else { return }
            
            if let receipt = Receipt(id: orderID, data: data) {
                completion(receipt)
            } else {
                completion(nil)
            }
        }
    }
    
    func addActiveOrderListener() {
        
        let activeOrderRef = databaseRef.collection("customers").document(APPSetting.customerUID).collection("activeOrders")
        
        activeOrderListener = activeOrderRef.addSnapshotListener({ (querySnapshot, err) in
            
            guard err == nil else {
                print("Error adding listener to channel \(err.debugDescription)")
                return
            }
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(err?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { (change) in
                if change.type == .added {
                    print("add")
                    self.fetchOrder(change.document.documentID) { (receipt) in
                        guard let receipt = receipt else { return }
                        self.activeOrderListenerDelegate?.didReceiveActiveOrder(receipt)
                    }
                }
                
                if change.type == .modified {
                    print("modified")
                }
                
                if change.type == .removed {
                    print("removed")
                }
            }
        })
    }
    
    func removeOrderListener() {
        activeOrderListener?.remove()
        print("did remove listener")
    }
    
    
    //MARK: - RESERVATIONS
    
    func sendReservation(_ reservation: Reservation, completion: @escaping (Error?) -> Void) {
        
        let reservationRef = databaseRef.collection("reservations")
        let customerReservation = databaseRef.collection("customer_reservation")
        
        reservationRef.document(reservation.uid).setData(reservation.representation) { (err) in
            
            guard err == nil else {
                completion(err)
                return
            }
            
            customerReservation.document(reservation.customerID).collection("reservations").document(reservation.uid).setData(["status": reservation.status.rawValue])
            
            completion(err)

        }

    }
    
    func addSpecialRequest(_ note: String, to reservationID: String) {
        
        let reservationRef = databaseRef.collection("reservations").document(reservationID)
        
        reservationRef.updateData(["note": note])
        
        
    }
    
    func updateReservation(_ reservation: Reservation) {
        
        let reservationRef = databaseRef.collection("reservations").document(reservation.uid)
        
        reservationRef.updateData(["pax": reservation.pax, "date" : reservation.date ])
        
    }
    
    func cancelReservation(_ reservation: Reservation) {
        
        let reservationRef = databaseRef.collection("reservations")
        let customerReservation = databaseRef.collection("customer_reservation")
        reservationRef.document(reservation.uid).updateData(["status": reservation.status.rawValue])
        customerReservation.document(reservation.customerID).collection("reservations").document(reservation.uid).delete()
        
    }
    
    func getReservations() {
        
        
        
    }
    
    

    
    //MARK: - old ones
    
    
    func sendOrder(order: String, completion: @escaping (Error?) -> Void) {
        
        let orderRef = databaseRef.collection("orders")
        let orderDocRef = orderRef.document("myodrder3")
        orderDocRef.setData(["foo2": "bar2d3 omg"])
    }
    
    func getOrder(completion:@escaping ([String:String]) -> Void) {
        
        ordersRef.getDocuments { (snapshot, error) in
            guard error == nil else { print("can not get moods \(error.debugDescription)"); return }
            guard let documents = snapshot?.documents else { return }
            guard let doc = documents.first else {
                return
            }
            
            completion(doc.data() as! [String : String])
        }
    }
    
    
    func getResturants(fromCode json: [String: Any], completion:@escaping ([String:Any]?) -> Void) {
        
        guard let uid = json["uid"] as? String else {
            completion(nil)
            return }
        
        resturantsRef.document(uid).getDocument { (doccumentSnapshot, error) in
            guard error == nil else {
                print("can not get resturant \(error.debugDescription)")
                completion(nil)
                return
            }
            guard let doc = doccumentSnapshot, let docData = doc.data() else {
                completion(nil)
                return }
            var data = docData
            data["uid"] = uid
            completion(data)
            
        }
    }
    

    
}
