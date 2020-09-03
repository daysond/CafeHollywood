//
//  AccountViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-14.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

enum AccountField: String {
    
    case email = "Email"
    case phone = "Phone Number"
    case name = "Name"
    case password = "Password"
    case reservation = "Manage Reservation"
    case favourite = "My Favourite"
    case about = "About"
    
}

class AccountViewController: UIViewController {
    
    let logoutButton = BlackButton()
    //    let scheduleView = FavouriteView()
    
    private let myTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.register(AccountTableViewCell.self, forCellReuseIdentifier: AccountTableViewCell.identifier)
        tb.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.identifier)
        return tb
    }()
    
    let accountTitles: [AccountField] = [.name, .phone, .email, .password]
    
    let myTitles: [AccountField]  = [.favourite, .reservation]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        self.navigationItem.title = "Hi, \(APPSetting.customerName)"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        myTableView.reloadData()
//        print("will appear")
//        print("user \(User.shared)")
//    }
    
    
    private func setupView() {
        
        print(NetworkManager.shared.isAuth)
        view.backgroundColor = .white
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.backgroundColor = .whiteSmoke
        myTableView.alwaysBounceVertical = false
        view.addSubview(myTableView)
        
        NSLayoutConstraint.activate([
            
            myTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            myTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            myTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            myTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
        
        setupFooterView()
        
    }
    
    private func setupFooterView() {
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.frame.width, height: Constants.kOrderButtonHeightConstant + 32))
        containerView.addSubview(logoutButton)
        
        logoutButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        logoutButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -0).isActive = true
        
        logoutButton.configureTitle(title: "Log out")
        logoutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        
        myTableView.tableFooterView = containerView

        
    }
    
    
    @objc private func logOut() {
        do {
            try NetworkManager.shared.signOut()
            print(NetworkManager.shared.isAuth)
//            let nav = UINavigationController(rootViewController: LoginViewController())
            let nav = UINavigationController(rootViewController: AuthViewController())
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true) {
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
    
    private func handleSelectionForField(_ field: AccountField) {
        
        switch field {
        case .favourite:
            
            presentController(ManageFavouriteViewController(), style: .popover)
            
        case .reservation:
            let res = Reservation(pax: 2, date: "today")
//            presentController(ReservationViewController(reservation: res), style: .fullScreen)
            
        case .password:
            
            return
            
        case .about:
            
            return
            
        default:
            
            let updateProfileVC = UpdateProfileViewController(field: field)
            
            self.navigationController?.pushViewController(updateProfileVC, animated: true)
            
        }
        
        
        
    }
    
    private func presentController(_ vc: UIViewController, style: UIModalPresentationStyle) {
        
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = style
        self.present(nvc, animated: true, completion: nil)
        
    }
    
    
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return accountTitles.count
        case 1:
            return myTitles.count
        case 2:
            return 1
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: AccountTableViewCell.identifier, for: indexPath) as! AccountTableViewCell
            cell.configureCellForField(accountTitles[indexPath.row])
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier, for: indexPath) as! MyTableViewCell
            cell.configureCellForField(myTitles[indexPath.row])
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier, for: indexPath) as! MyTableViewCell
            cell.configureCellForField(.about)
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 72
        default:
            return 52
        }
        
    }
    
    
    //Section
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 16
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        default:
            let view = UIView(frame: .zero)
            view.backgroundColor = .whiteSmoke
            return view
        }
    }
    
    //Selection
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let index = indexPath.row
        
        switch section {
        case 0:
            handleSelectionForField(accountTitles[index])
        case 1:
            handleSelectionForField(myTitles[index])
        case 2:
            handleSelectionForField(.about)
        default:
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    
    
    
    
    
    
}
