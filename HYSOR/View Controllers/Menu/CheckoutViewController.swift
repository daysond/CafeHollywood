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
    
    
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOptions()
        setupView()
//        setupSTP()
        
        
    }
    
    //MARK: - SETUPS
    
    private func setupOptions() {
        
        let cutlery = CustomOption(mainImageNmae: "cutlery", mainTitle: "UTENSILS, STRAWS, ETC", subTitle:  Cart.shared.needsUtensil ?  "Yes please!" : "No thanks!", optionType: .utensil)
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
        
        let child = LoadingViewController(animationFileName: "squareLoading")
        self.addChild(child)
        child.view.frame = self.view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        Cart.shared.tempMeals = Cart.shared.meals

        NetworkManager.shared.placeOrder { (error) in
            
            DispatchQueue.main.async {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
    
                guard error == nil else {
                    Cart.shared.meals = Cart.shared.tempMeals
                    Cart.shared.tempMeals = []
                    return
                }
                Cart.shared.tempMeals = []
                self.dismiss(animated: true, completion: nil)
                self.tabBarController?.selectedIndex = 2
            }
        }
        
        Cart.resetCart()
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

