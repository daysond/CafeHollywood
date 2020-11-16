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
    case unknowError
    case recentLoginRequired
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
    
    private var onlineOrdersRef: CollectionReference  {
        let db = Firestore.firestore()
        let ref = db.collection("onlineOrders")
        return ref
    }
    
    private var dineInOrdersRef: CollectionReference  {
        let db = Firestore.firestore()
        let ref = db.collection("dineInOrders")
        return ref
    }
    
    private var resturantInfoRef: CollectionReference  {
        let db = Firestore.firestore()
        let ref = db.collection("restaurantInfo")
        return ref
    }
    
    private var activeOrderListener: ListenerRegistration?
    
    private var orderStatusListener: ListenerRegistration?
    
    private var unavailablityListener: ListenerRegistration?
    
    private var activeTableListener: ListenerRegistration?
    
    
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
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    var orderStatusDelegate: OrderStatusUpdateDelegate?
    var activeOrderListenerDelegate: ActiveOrderListenerDelegate?
    
    // CACHE
    let preferencesCache = NSCache<NSString, PreferenceCache>()
    let mealsCache = NSCache<NSString, MealCache>()
    
    
    
    // MARK: - ON START CHECKING
    
    func addunavailablityListener() {
        
        if unavailablityListener != nil {
            unavailablityListener?.remove()
        }
        
        unavailablityListener = databaseRef.collection("restaurantInfo").document("unavailablity").addSnapshotListener({ (snapshot, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let data = snapshot?.data(), let unavailableMeals = data["meals"] as? [String], let unavailableItems = data["items"] as? [String], let unavailableMenus = data["menus"] as? [String], let unavailableDates = data["reservationDates"] as? [String] {
                APPSetting.shared.unavailableMeals = unavailableMeals
                APPSetting.shared.unavailableItems = unavailableItems
                APPSetting.shared.unavailableMenus = unavailableMenus
                APPSetting.shared.unavailableDates = unavailableDates
            }
            
        })
        
        
    }
    
    func getCurrentVersions(completion: @escaping (Error?) -> Void) {
        
        databaseRef.collection("restaurantInfo").document("versions").getDocument { (snapshot, error) in
            
            guard error == nil else {
                completion(error)
                return
            }
         
            if let data = snapshot?.data() as? [String: String] {
                APPSetting.shared.versions = data
                completion(nil)
            } else {
                completion(NetworkError.unknowError)
            }
        }
    }
    

    //On start, check self active table
    
    func checkActiveTable() {
        
        guard let myID = currentUserUid else { return }
        
        let myActiveTableRef = databaseRef.collection("customers").document(myID).collection("activeTables")
        
        myActiveTableRef.getDocuments { (snapshot, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else {
                return
            }
            
            if snapshot.documents.count == 0 {
                // no table found , do nothing
                return
            } else if let id = snapshot.documents.first?.documentID {
                //1. table found, set up table number
                Table.shared.tableNumber = id
                //2. set up table listener
                self.addTableListener()
                
            }
        }
    }
    
    func getBusinessHours(completion: @escaping ([String: String]?, Error?) -> Void) {
        
        resturantInfoRef.document("businessHours").getDocument { (snapshot, error) in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot,  let data = snapshot.data() as? [String: String]  else {
                completion(nil, NetworkError.unknowError)
                return
            }
            
            print(data)
            completion(data, nil)
           
        }

    }
    
    func getTaxRates(completion: @escaping ([String: Int]?) -> Void ) {
        
        databaseRef.collection("restaurantInfo").document("taxRate").getDocument { (snapshot, error) in
            
            guard error == nil else {
                completion(nil)
                return
            }
            
            if let data = snapshot?.data() as? [String : Int] {
                completion(data)
            } else {
                completion(nil)
            }
            
        }
    }
    
    func getCredits(completion: @escaping ([String: Int]?) -> Void ) {
        
        databaseRef.collection("restaurantInfo").document("creditAmounts").getDocument { (snapshot, error) in
            
            guard error == nil else {
                completion(nil)
                return
            }
            
            if let data = snapshot?.data() as? [String : Int] {
                completion(data)
            } else {
                completion(nil)
            }
        }
  
    }
    
    
    
    // MARK: - Auth
    
    func verifyPhoneNumber(_ phone: String, completion: @escaping (String?, Error?) -> Void) {
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
            
            completion(verificationID, error)
        }
        
    }
    
    
    func signInWith(_ email: String, _ password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            completion(authDataResult, error)
        }
        
    }
    
    func signInWithPhoneNumber(verificationCode code: String, completion: @escaping (AuthDataResult?, Error?) -> Void ) {
        
        guard let verificationID = APPSetting.verificationID else {
            completion(nil, NetworkError.unknowError)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (dataResult, error) in
            completion(dataResult,error)
        }
        
    }
    
    
    func signUpWith(_ email: String, _ password: String, _ name: String, _ code: String) -> Result<AuthDataResult, Error> {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: Result<AuthDataResult, Error>!
        
        let group = DispatchGroup()
        
        group.enter()
        
        Auth.auth().createUser(withEmail: email, password: password) { (dataResult, err) in
            
            guard err == nil else {
                print(err!.localizedDescription)
                result = .failure(err!)
                semaphore.signal()
                return
            }
            guard let dataResult = dataResult else { return }
            
            result = .success(dataResult)
            
            group.enter()
            self.updateProfileField(.name, to: name) { (err) in
                group.leave()
                guard err == nil else { print(err!.localizedDescription ); return }
                print("did set name \(name)")
            }
            
            group.enter()
            self.setAuthPhoneNumber(verificationCode: code) { (err) in
                group.leave()
                guard err == nil else { print(err!.localizedDescription ); return }
                print("did set phone \(code)")
            }
            
            group.leave()

        }
        
        group.notify(queue: .main) {
            print("notified")
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        
        return result
    }
    
    
    func signOut() throws {
        
        do {
            try Auth.auth().signOut()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    

    //MARK: - MENUS
    
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
                      let mealsInUID = doc["mealsInUID"] as? [String],
                      let menuTitle = doc["menuTitle"] as? String else {
                    print("cannot get menu for \(uid)")
                    return
                }
                
                let menuDetail = doc["menuDetail"] as? String
                let isTakeOutOnly = doc["isTakeOutOnly"] as? Bool
                let menu = Menu(uid: uid, menuTitle: menuTitle, menuDetail: menuDetail, mealUIDs: mealsInUID, imageURL: imageURL, isTakeOutOnly: isTakeOutOnly ?? false)
                menus.append(menu)
            }
            
            completion(menus)
            
        }
        
    }
    
    func fetchMealWithMealUID(_ uid: String, completion: @escaping (Meal?) -> Void) {
        
        if let mealFromCache = mealsCache.object(forKey: uid as NSString) {
            print("found cache")
            completion(mealFromCache.meal)
            return
        }
        
        let group = DispatchGroup()
        
        var tempPreferences: [Preference] = []
        
        databaseRef.collection("meals").document(uid).getDocument { (documentSnapShot, error) in
            
            guard error == nil, let data = documentSnapShot?.data() else {
                print(error.debugDescription)
                print("wrong data \(uid) \n \(String(describing: documentSnapShot?.data()))")
                completion(nil)
                return
                
            }
            
            guard let mealUID = documentSnapShot?.documentID else { print("uid wrong"); return }
            guard let name = data["name"] as? String else { print("name wrong"); return }
            guard let price = data["price"] as? Double else { print("price wrong \(uid)"); return }
            guard let mealDescription = data["description"] as? String else {print("mealDescription \(uid) not found "); return }
            
            let detail = data["detail"] as? String
            let imageURL = data["imageURL"] as? String
            let comboTag = data["comboTag"] as? Int
            var meal = Meal(uid: mealUID, name: name, price: Decimal(floatLiteral: price), details: detail ?? "", imageURL: imageURL, preferences: nil, comboMealTag: comboTag, description: mealDescription)
            
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
                    }
                    meal.preferences = tempPreferences
                    self.mealsCache.setObject(MealCache(meal), forKey: uid as NSString)
                    completion(meal)
                }
            } else {
                self.mealsCache.setObject(MealCache(meal), forKey: uid as NSString)
                completion(meal)
            }
        }
        
    }
    
    fileprivate func fetchPreferenceItemWithUID(_ uid: String, completion: @escaping (PreferenceItem?) -> Void) {
        
        databaseRef.collection("preferenceItems").document(uid).getDocument { (snapshot, error) in
            guard error == nil, let data = snapshot?.data() else {
                print(error.debugDescription)
                print("wrong item data at \(uid)")
                return
            }
            guard let uid = snapshot?.documentID else { print("no snapshot"); return }
            guard let name = data["name"] as? String else { print("no item name \(uid)"); return }
            guard let itemDescription = data["description"] as? String else { print("no itemDescription \(uid)"); return}
            
            var item = PreferenceItem(name: name, price: nil, uid: uid, description: itemDescription)
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
                
                let preference = Preference(uid: uid, isRequired: isRequired, name: name, maxPick: maxPick, preferenceItems: tempItems, maxItemQuantity: maxItemQuantity)
                self.preferencesCache.setObject(PreferenceCache(preference), forKey: uid as NSString)
                completion(preference)
            }
        }
    }
    
    func getGiftOptions(completion: @escaping ([Meal]) -> Void) {
        
        var options: [Meal] = []
        
        let group = DispatchGroup()
        
        group.enter()
        
        databaseRef.collection("customMenu").document("giftOptions").getDocument { (snapshot, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                group.leave()
                return
            }
            
            if let data = snapshot?.data(), let optionIDs = data["mealsInUID"] as? [String] {
                
                optionIDs.forEach { (uid) in
                    group.enter()
                    self.fetchMealWithMealUID(uid) { (meal) in
                        
                        if let meal = meal {
                            options.append(meal)
                        }
                        group.leave()
                    }
                }
            }
            
            group.leave()

        }
        
        group.notify(queue: .main) {
            completion(options)
        }
        
        
        
    }
    
    
    //MARK: - DINE IN ORDERS
    
    
    func sendOrder(completion: @escaping (Error?) -> Void) {
        
        guard let table = Table.shared.tableNumber, let customerID = currentUser?.uid else { return }
        
        addTableListener()
        
        let activeTableRef = databaseRef.collection("activeTables").document(table)
        
        let orderID = String.randomString(length: 6)
        
        let ordersRef = dineInOrdersRef.document(orderID)
        
        let customerActiveTableRef = databaseRef.collection("customers").document(customerID).collection("activeTables").document(table)
        
        ordersRef.setData(Cart.shared.dineInRepresentation) { (error) in
            
            guard error == nil else {
                completion(error)
                return
            }
            
            activeTableRef.setData([orderID: OrderStatus.unconfirmed.rawValue], merge: true)
          
            customerActiveTableRef.setData([:])
            completion(nil)
        }

        
        
    }
    
    func checkIfTableDoesExist(completion: @escaping (Error?, Bool?) -> Void) {

        guard let table = Table.shared.tableNumber else { return }

        let activeTableRef = databaseRef.collection("activeTables").document(table)

        activeTableRef.getDocument { (doc, err) in
            guard err == nil else {
                completion(err, nil)
                print(err! .localizedDescription)
                return
            }
            if let doc = doc {

                doc.data() == nil ? completion(nil, false) : completion(nil, true)

            }
        }

    }

    
    func addTableListener() {
        
        if activeTableListener != nil {
            return
        }
        
        guard let table = Table.shared.tableNumber else { return }
        let activeTableRef = databaseRef.collection("activeTables").document(table)
        
        activeTableListener = activeTableRef.addSnapshotListener({ (snapshot, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot, let data = snapshot.data() as? [String: Int] else { return }
            
            for (key, value) in data {
                
                if key == "isTableActive" {
                    if value == 0 {
                        self.closeTable()
                        continue
                    }
                }
                
                // check if order exists, if nil, then it's a new order, then we fetch it
                if Table.shared.orderIDs.firstIndex(of: key) == nil {
                    
                    self.fetchTableOrder(key) { (order) in
                        guard let order = order else { return }
                        Table.shared.tableOrders.append(order)
                    }
                    
                } else {
                    // if order exists, check status
                    if let status = OrderStatus(rawValue: value) {
                        // if status changed, update status
                        Table.shared.tableOrders.filter{$0.orderID == key && $0.status != status }.first?.status = status
                        NotificationCenter.default.post(name: .didUpdateDineInOrderStatus, object: nil)
                    }
                    
                }
            }
        })
        
    }
    
    private func closeTable() {
        
        guard let table = Table.shared.tableNumber, let customerID = currentUser?.uid else { return }
        
        let customerActiveTableRef = databaseRef.collection("customers").document(customerID).collection("activeTables").document(table)
        
        customerActiveTableRef.delete()
        activeTableListener?.remove()
        activeTableListener = nil
        Table.reset()

    }
    
    
    private func fetchTableOrder(_ orderID: String, completion: @escaping (TableOrder?) -> Void ) {
        
        print("fetching table order \(orderID)")
        dineInOrdersRef.document(orderID).getDocument { (snapshot, error) in
            
            guard error == nil else { return }
            
            guard let data = snapshot?.data() else { return }
            
            if let order = TableOrder(id: orderID, data: data) {
                completion(order)
            } else {
                completion(nil)
            }
        }
    }
    
     func sendRequest(_ request: String, completion: @escaping (Error?) -> Void) {
        
        let ref = databaseRef.collection("requests")
        
        let uid = String.randomString(length: 4)
        
        let data = ["request": request]
        
        ref.document(uid).setData(data) { (error) in
            guard error == nil else {
                completion(error)
                return
            }
            
            completion(nil)
        }
        
    }

    
    

    
    
    //MARK: - Online ORDERS
    
    func placeOrder(completion: @escaping (Error?) -> Void) {
        //DATA
        let orderID = String.randomString(length: 6)
        
        let customerID = Cart.shared.representation["customerID"] as! String
        
        let group = DispatchGroup()
        
        var err: Error?
        
        // send order
        let ordersRef = onlineOrdersRef.document(orderID)
        
        let activeOrderRef = databaseRef.collection("activeOrders").document(orderID)
        
        let customerActiveOrderRef = databaseRef.collection("customers").document(customerID).collection("activeOrders").document(orderID)
        
        group.enter()
        
        //        databaseRef.collection("orders").order(by: "timestamp").limit(to: 5)
        
        
        
        ordersRef.setData(Cart.shared.representation) { (error) in
            guard error == nil else {
                ordersRef.delete()
                err = error
                group.leave()
                return
            }
            group.leave()
        }
        //TODO: NEED TO FIX THIS ...
        guard err == nil else { completion(err); return } // if err, exti the function ,if no error continue to notify res and cus
        
        group.enter()
        
        customerActiveOrderRef.setData(["status": OrderStatus.unconfirmed.rawValue, "timestamp": Cart.shared.orderTimestamp]) { (error) in
            err = error
            group.leave()
        }
        
        group.enter()
        
        activeOrderRef.setData([:]) { (error) in
            err = error
            group.leave()
        }
        
        
        group.notify(queue: .main) {
            
            guard err == nil else {
                ordersRef.delete()
                customerActiveOrderRef.delete()
                activeOrderRef.delete()
                completion(err)
                return
            }
            
            completion(err)
        }
        
    }
    
    func fetchCloseOrders() -> Result<[Receipt], Error> {
        
        let customerOrdersRef = databaseRef.collection("customers").document(APPSetting.customerUID).collection("orders").order(by: "timestamp", descending: true).limit(to: 10)
        //        customerOrdersRef.limit(to: 5)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let group = DispatchGroup()
        
        var result: Result<[Receipt], Error>!
        
        var recepits: [Receipt] = []
        
        group.enter()
        
        customerOrdersRef.getDocuments { (snapshot, error) in
            
            guard error == nil, let docs = snapshot?.documents else {
                result = .failure(error!)
                semaphore.signal()
                return
            }
            
            docs.forEach { (doc) in
                
                group.enter()
                
                self.fetchOrderDetails(doc.documentID) { (receipt) in
                    if let receipt = receipt {
                        recepits.append(receipt)
                    }
                    group.leave()
                }
            }
            
            group.leave()
        }
        
        
        group.notify(queue: .main) {
            
            semaphore.signal()
        }
        
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        recepits.sort { $0.orderTimestamp > $1.orderTimestamp }
        result = .success(recepits)
        
        
        
        return result
        
    }
    
    
    // GET Single Order
    private func fetchOrderDetails(_ orderID: String, completion: @escaping (Receipt?) -> Void ) {
        
        
        onlineOrdersRef.document(orderID).getDocument { (snapshot, error) in
            
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
        
        if activeOrderListener != nil {
            activeOrderListener?.remove()
        }
        
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

                    self.fetchOrderDetails(change.document.documentID) { (receipt) in
                        guard let receipt = receipt else { return }
                        
                        if receipt.status == .completed || receipt.status == .cancelled {
                            self.closeOrder(receipt.orderID, status: receipt.status, timestamp: receipt.orderTimestamp)
                        } else {
                            self.activeOrderListenerDelegate?.didReceiveActiveOrder(receipt)
                        }
 
                    }
                }
                
                if change.type == .modified {
                    
                    guard let statusCode = change.document.data()["status"] as? Int else { return }
                    
                    let orderID = change.document.documentID
                    
                    let info = ["orderID": orderID, "status": statusCode] as [String : Any]
                    
                    NotificationCenter.default.post(name: .didUpdateOrderStatus, object: self, userInfo: info)
                }
                
                if change.type == .removed {
                    
                    guard let statusCode = change.document.data()["status"] as? Int else { return }
                    
                    let orderID = change.document.documentID
                    
                    let info = ["orderID": orderID, "status": statusCode] as [String : Any]
                    
                    NotificationCenter.default.post(name: .didUpdateOrderStatus, object: self, userInfo: info)
                    
                }
            }
        })
    }
    
    func removeOrderListener() {
        activeOrderListener?.remove()
    }
    
    func closeOrder(_ id: String, status: OrderStatus, timestamp: String) {
        
        let activeOrderRef = databaseRef.collection("customers").document(APPSetting.customerUID).collection("activeOrders")
        
        let orderRef = databaseRef.collection("customers").document(APPSetting.customerUID).collection("orders")
        
        activeOrderRef.document(id).delete()
        
        orderRef.document(id).setData(["status": status.rawValue, "timestamp": timestamp])
        
        
    }
    

    
    //MARK: - RESERVATIONS
    
    func sendReservation(_ reservation: Reservation, completion: @escaping (Error?) -> Void) {
        
        let reservationRef = databaseRef.collection("reservations")
        
        let customerReservation = databaseRef.collection("customers").document(APPSetting.customerUID).collection("reservations")
        
        reservationRef.document(reservation.uid).setData(reservation.representation) { (err) in
            
            guard err == nil else {
                completion(err)
                return
            }
            
            customerReservation.document(reservation.uid).setData(["status": reservation.status.rawValue])
            
            completion(err)
            
        }
        
    }
    
    func addSpecialRequest(_ note: String, to reservationID: String) {
        
        let reservationRef = databaseRef.collection("reservations").document(reservationID)
        
        reservationRef.updateData(["note": note])
        
        
    }
    
    func updateReservation(_ reservation: Reservation) {
        
        let reservationRef = databaseRef.collection("reservations").document(reservation.uid)
        
        reservationRef.updateData(["pax": reservation.pax, "date" : reservation.date, "time" : reservation.time ])
   
        
    }
    
    func cancelReservation(_ reservation: Reservation) {
        
        let reservationRef = databaseRef.collection("reservations")
        let customerReservation = databaseRef.collection("customers").document(APPSetting.customerUID).collection("reservations")
        reservationRef.document(reservation.uid).updateData(["status": reservation.status.rawValue])
        customerReservation.document(reservation.uid).delete()
        
    }
    
    func getMyReservations(completion:@escaping ([Reservation]) -> Void ) {
        
        guard let myID = currentUserUid else { return }
        
        let group = DispatchGroup()
        
        var reservations = [Reservation]()
        
        let customerReservationRef = databaseRef.collection("customers").document(myID).collection("reservations")
        
        let reservationRef = databaseRef.collection("reservations")
        
        group.enter()
        
        customerReservationRef.getDocuments { (snapshot, error) in
            
            guard error == nil else {
                group.leave()
                return
            }
            
            if let snapshot = snapshot {
                
                snapshot.documents.forEach { (doc) in
                    group.enter()
                    reservationRef.document(doc.documentID).getDocument { (document, error) in
                        guard error == nil else {
                            group.leave()
                            return
                        }
                        
                        if let document = document, let data = document.data(), let reservation = Reservation(id: document.documentID, data: data)  {
                            
                            reservations.append(reservation)
                            group.leave()
                            
                        } else {
                            group.leave()
                        }
                        
                    }
                    
                }
                
            }
            group.leave()
            
            
        }
        
        group.notify(queue: .main) {
            completion(reservations)
        }
        
    }
    
    //MARK: - ACCOUNT

    
    func updateProfileField(_ field: AccountField, to newProfile: String, completion: @escaping (Error?) -> Void) {
        
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        
        switch field {
        case .name:
            
            changeRequest?.displayName = newProfile
            changeRequest?.commitChanges(completion: { (error) in
                completion(error)
            })
            
        case .email:
            
            Auth.auth().currentUser?.updateEmail(to: newProfile, completion: { (error) in
                
                if let err = error, let errCode = AuthErrorCode(rawValue: err._code) {
                    if errCode == .requiresRecentLogin {
                        completion(NetworkError.recentLoginRequired)
                    }
                } else {
                    completion(error)
                }
                
                
            })
            
        case .password:
            
            Auth.auth().currentUser?.updatePassword(to: newProfile, completion: { (error) in
                completion(error)
            })
            
            
        default:
            return
        }
        
        
    }
    
    func setAuthPhoneNumber(verificationCode code: String, completion: @escaping (Error?) -> Void ) {
        
        guard let verificationID = APPSetting.verificationID else {
            completion(NetworkError.unknowError)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code)
        
        
        Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { (error) in
            completion(error)
        })
        
        
    }
    
    func reAuthenticateUser(password: String, onComplete: @escaping (String?, Error?) -> Void) {
        
        guard let email = currentUser?.email else { return }
        
        var credential: AuthCredential
        // Prompt the user to re-provide their sign-in credentials
        credential =  EmailAuthProvider.credential(withEmail: email, password: password)
        
        currentUser?.reauthenticate(with: credential, completion: { (result, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                onComplete(nil, error)
                return
            }
            result != nil ?
                onComplete(result!.user.uid, nil) :
                onComplete(nil, nil)
            
        })
        
    }
    
    
    
}
