//
//  MealViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-20.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MealViewController: UIViewController {
    
    let preferenceTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.register(PreferenceTableViewCell.self, forCellReuseIdentifier: PreferenceTableViewCell.identifier)
        tb.register(MultiQuantityPreferenceTableViewCell.self, forCellReuseIdentifier: MultiQuantityPreferenceTableViewCell.identifier)
        return tb
    }()
    
    let addToCartButton = BlackButton()
    
    let footerView = PreferenceFooterView()
    let headerView = PreferenceHeaderView()
    
    let kHearderViewTitleHeight: CGFloat = 92.0
    
    var meal: Meal {
        didSet {
            preferenceTableView.reloadData()
        }
    }
    
    let isNewMeal: Bool
    
    var mealInCartIndex: Int?
    
    var navigationBarHeight: CGFloat?
    
    let kFooterViewHeightConstant: CGFloat = 208
    
//    private let favoriteButton = UIButton(type: .custom)
    
    fileprivate var preferenceTableViewTopConstraint: NSLayoutConstraint?
    
    
    init(meal : Meal, isNewMeal: Bool ) {
        self.meal = meal
        self.isNewMeal = isNewMeal
        super.init(nibName: nil, bundle: nil)

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.navigationBarHeight =  self.navigationController?.navigationBar.frame.maxY
  
    }
    
    
    // MARK: - VIEW SET UP
    
    private func setupView() {
        
        view.backgroundColor = .white
        setupNavigationBar()
        setupTableView()
        view.addSubview(addToCartButton)
        setupAddToCartButton()
   
        preferenceTableViewTopConstraint = preferenceTableView.topAnchor.constraint(equalTo: view.topAnchor)
        
        NSLayoutConstraint.activate([
            
            preferenceTableViewTopConstraint!,
            preferenceTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            preferenceTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            preferenceTableView.bottomAnchor.constraint(equalTo: addToCartButton.topAnchor),
            
            addToCartButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            addToCartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            addToCartButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            addToCartButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -0),
        ])
        
        
        // Disable add to cart button when there is a require field
        addToCartButton.isEnabled = shouldEnableAddToCartButton()
        
    }
    
    open func setupAddToCartButton() {
        
        let orderOrCart = APPSetting.shared.isDineIn ? "Order" : "Cart"
        
        addToCartButton.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
        
        let title =  isNewMeal ? "Add To \(orderOrCart)" : "Update \(orderOrCart)"
        let subtitle = "$\(meal.totalPrice.amount.stringRepresentation)"
        
        addToCartButton.configureButton(headTitleText: title, subtitleText: subtitle)
 
//        view.bringSubviewToFront(addToCartButton)
    }
    
    private func setupNavigationBar() {
   
        self.navigationController?.isNavigationBarHidden = false
        let backButton = UIBarButtonItem(image: UIImage(named: "back84x84"), style: .plain, target: self, action:  #selector(backButtonTapped))
        navigationController?.navigationBar.tintColor =  meal.imageURL == nil ? .black : .white
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
    

    }
    

    
    private func setupTableView() {
        
        preferenceTableView.delegate = self
        preferenceTableView.dataSource = self
        preferenceTableView.contentInsetAdjustmentBehavior = .never
        view.addSubview(preferenceTableView)
        setupHeaderView()
        setupFooterView()
        
    }
    
    private func setupHeaderView() {
        
        
        preferenceTableView.tableHeaderView = headerView
        headerView.frame.size.width = view.frame.width
        headerView.frame.size.height = meal.imageURL != nil ? view.frame.width * 2.0/3.0 : kHearderViewTitleHeight + (navigationBarHeight ?? 88.0)
        headerView.configureHeaderViewWith(meal)
        headerView.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)

    }
    
    private func setupFooterView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(instructionLabelTapped))
        footerView.delegate = self
        footerView.isNewMeal = isNewMeal
        footerView.instructionTextLabel.addGestureRecognizer(tapGesture)
        footerView.instructionTextLabel.text = meal.instruction == nil ? "Special Instructions?" : meal.instruction!
        footerView.instructionTextLabel.textColor = meal.instruction == nil ? .gray : .black
        footerView.quantity = meal.quantity
        preferenceTableView.tableFooterView = footerView
        setFooterViewHeight()
        
    }
    
    
    // MARK: - HELPERS
    
    
    private func updatePreferences(preference: Preference, indexPath: IndexPath ) {
        
        meal.preferences![indexPath.section] = preference
        
        addToCartButton.configureSubtitle(title: "$\(meal.totalPrice.amount.stringRepresentation)" )
        addToCartButton.isEnabled = shouldEnableAddToCartButton()
        preferenceTableView.reloadData()
    }
    
    //Enable AddToCart Button when all require fields are selected
    
    private func shouldEnableAddToCartButton() -> Bool {
        
        var shouldEnableButton = false
        
        guard let preferences = meal.preferences, preferences.count > 0 else { print("no preferences found "); return true }
        
        
        for preference in preferences {
            
            if preference.isRequired {
                
                for preferenceItem in preference.preferenceItems {
                    // if item is selected, stop searching and move onto next
                    if preferenceItem.isSelected == true {
                        shouldEnableButton = true
                        break
                    } else {
                        shouldEnableButton = false
                    }
                }
                
                if shouldEnableButton == false {
                    break
                }
            } else {
                shouldEnableButton = true
            }
        }
        
        addToCartButton.backgroundColor = shouldEnableButton ? .black : .lightGray
        
        return shouldEnableButton
        
    }
    
    
    private func heightForInstruction(text: String) -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 16, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = footerView.instructionTextLabel.font
        label.text = text
        label.sizeToFit()
        return label.frame.height + 48
    }
    
    private func setFooterViewHeight() {
        
        if meal.instruction == nil {
             footerView.frame.size.height = kFooterViewHeightConstant
        } else {
            let h = heightForInstruction(text: meal.instruction!)
            footerView.frame.size.height = kFooterViewHeightConstant - 64 + h
        }
   
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let yTransition = scrollView.contentOffset.y
        updateUIAccrodingToContentOffsetY(yTransition)
    }
    
    private func updateUIAccrodingToContentOffsetY(_ yTransition: CGFloat) {
        
        let height: CGFloat = view.frame.width * 2.0/3.0
        
        if yTransition > height - (navigationBarHeight ?? 88.0) - 32{
            preferenceTableViewTopConstraint?.constant = -44
            self.navigationController?.navigationBar.standardAppearance.configureWithDefaultBackground()
            navigationController?.navigationBar.tintColor = .black
            navigationItem.title = meal.name
            return
        }
        
        preferenceTableViewTopConstraint?.constant = 0
        headerView.frame.size.height = meal.imageURL == nil ?  kHearderViewTitleHeight + (navigationBarHeight ?? 88.0) : height
       navigationItem.title = nil
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.tintColor = meal.imageURL == nil ? .black : .white
        
        
    }
    
    
    // MARK: - ACTIONS
    
    @objc private func addToCartButtonTapped() {
        
        switch isNewMeal {
            
        case true:
            // 1. add to cart
            Cart.shared.meals.append(meal)
            //2. dissmiss VC
            self.navigationController?.popViewController(animated: true)
            
        case false:
            // update cart
            guard let index = mealInCartIndex else {
                print("can not find meal in cart, index error")
                break
            }
            if meal.quantity == 0 {
                removeItemFromCart()
            } else {
                Cart.shared.meals[index] = meal
            }
            
            self.dismiss(animated: true, completion: nil)
        }

        
    }
    
    @objc func instructionLabelTapped(){
        
        let instructionVC = InstructionsInputViewController(title: "Special Instruction")
        instructionVC.delegate = self
        
        if meal.instruction != nil {
            instructionVC.textView.text = meal.instruction!
        }
        let nav = UINavigationController(rootViewController: instructionVC)
        present(nav, animated: true, completion: nil)
        
    }
    
    @objc private func backButtonTapped() {
         
         self.navigationController?.popViewController(animated: true)
     }
    
    @objc func favoriteButtonTapped(sender: UIButton) {
        
//        print("tapped \(User.shared.favouriteList)")
        
        if meal.isFavourite {
          
            APPSetting.unfavouriteMeal(uid: meal.uid)
            sender.setImage(UIImage(named: "heartEmpty"), for: .normal)
            
        } else {
            
            APPSetting.favouriteMeal(uid: meal.uid)
            sender.setImage(UIImage(named: "heartFilled"), for: .normal)
        }
//        print("after \(User.shared.favouriteList)")
        
        
    }
    
    
}

//MARK: - TABLEVIEW EXTENSION


extension MealViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return meal.preferences?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let preferences = meal.preferences {
            return preferences[section].isSectionCollapsed ? 0 : preferences[section].preferenceItems.count
        }
        
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let preferences = meal.preferences else { return UITableViewCell() }
        let preference =  preferences[indexPath.section]
        let preferenceItem = preferences[indexPath.section].preferenceItems[indexPath.row]
        
        switch preference.maxItemQuantity {
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: PreferenceTableViewCell.identifier, for: indexPath) as? PreferenceTableViewCell
            {
                
                cell.configureCellWithPreference(preferenceItem)
                return cell
            }
            
        default:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: MultiQuantityPreferenceTableViewCell.identifier, for: indexPath) as? MultiQuantityPreferenceTableViewCell
            {
                cell.indexPath = indexPath
                let shouldDisableAddButton = preferenceItem.quantity == preference.maxItemQuantity
                cell.configureCellWithPreference(preferenceItem, shouldDisableAddButton: shouldDisableAddButton)
                cell.delegate = self
                return cell
            }
        }
        
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let preferences = meal.preferences {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
            header.titleLabel.text =  preferences[section].isRequired ? "\(preferences[section].name)" + " (Required)" : "\(preferences[section].name)" + ""
            header.toggled(isCollapsed: preferences[section].isSectionCollapsed)
            header.section = section
            header.delegate = self
            return header
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let preferences = meal.preferences {
            return preferences[indexPath.section].isSectionCollapsed ? 0 : 58
        }
        return 58
    }
    
    // MARK: DID SELECT ROW
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let preferences = meal.preferences else { return }
        
        var preference = preferences[indexPath.section]
        

        
        switch preference.maxPick {
            
        case 1: //MAX PICK IS 1
            
            if preference.isRequired == false && preference.preferenceItems[indexPath.row].isSelected == true {
                 preference.preferenceItems[indexPath.row].isSelected = false
            } else {
                
                for (index,var item) in preference.preferenceItems.enumerated() {
                    // unselect everything
                    item.isSelected = false
                    preference.preferenceItems[index] = item
                }
                // then select the selected
                preference.preferenceItems[indexPath.row].isSelected = true
                
                
            }
            

            
//            tableView.cellForRow(at: indexPath)
            
        default: // MAX PICK greater than 1
            
            switch preference.maxItemQuantity {
            // SINGLE ITEM
            case 1:
                
                let currentSelected = preference.preferenceItems.reduce(0) { (res, item) -> Int in
                    return item.isSelected ? res + 1 : res + 0
                }
                
                if currentSelected < preference.maxPick {
                    preference.preferenceItems[indexPath.row].isSelected = !preference.preferenceItems[indexPath.row].isSelected
                } else {
                    
                    if preference.preferenceItems[indexPath.row].isSelected {
                        preference.preferenceItems[indexPath.row].isSelected = false
                    }
                    
                }
                
                
            // MULTI ITEM WITH - 99 +
            default:
                
                if preference.preferenceItems[indexPath.row].isSelected {
                    break
                }
                
                preference.preferenceItems[indexPath.row].isSelected = !preference.preferenceItems[indexPath.row].isSelected
                
                //OPEN ANIMATION TODO _______________________________
                //                let cell = tableView.cellForRow(at: indexPath) as! MultiQuantityPreferenceTableViewCell
                //                cell.shouldAnimate = true
            }
        }
        
        
        
        tableView.cellForRow(at: indexPath)?.isSelected = false
        //        updatePreferences(price: addOnPrice, preference: preference, indexPath: indexPath)
        updatePreferences(preference: preference, indexPath: indexPath)
    }
    
    
}


// MARK: - COLLAPSIBLE TABLEVIEW DELEGATE

extension MealViewController: CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(header: CollapsibleTableViewHeader, section: Int) {
        guard meal.preferences != nil else { return }
        let collapsed = !meal.preferences![section].isSectionCollapsed
        
        // Toggle collapse
        meal.preferences![section].isSectionCollapsed = collapsed
        header.toggled(isCollapsed: collapsed)
        
        // Reload the whole section
        preferenceTableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .fade)
        
    }
    
    
    
    
    
}

// MARK: - MultiQuantityCellDelegate && FooterViewDelegate

extension MealViewController: MultiQuantityCellDelegate, PreferenceFooterViewDelegate {
    

    
    func didTapMinusButton(at indexPath: IndexPath) {
        
        guard let preferences = meal.preferences else { return }
        var preference = preferences[indexPath.section]
        let q = preference.preferenceItems[indexPath.row].quantity
        let s = preference.preferenceItems[indexPath.row].isSelected
        
        switch (q, s) {
        case (1, true):
            // quantity == 1 && is selected: deselect cell and close buttons
            preference.preferenceItems[indexPath.row].isSelected = false
            
        default:
            //else: quantity - 1
            preference.preferenceItems[indexPath.row].quantity -= 1
            if preference.preferenceItems[indexPath.row].quantity < preference.maxItemQuantity {
               let cell = preferenceTableView.cellForRow(at: indexPath) as! MultiQuantityPreferenceTableViewCell
                cell.shouldDisableAddButton = false
            }
        }
        
        updatePreferences(preference: preference, indexPath: indexPath)
        
    }
    
    func didTapAddButton(at indexPath: IndexPath) {
        
        guard let preferences = meal.preferences else { return }
        var preference = preferences[indexPath.section]
        let q = preference.preferenceItems[indexPath.row].quantity
        let s = preference.preferenceItems[indexPath.row].isSelected
        
        switch (q, s) {
        case (1, false):
            // quantity == 1 && not selected: select cell and open buttons
            preference.preferenceItems[indexPath.row].isSelected = true
            
        default:
            //else: quantity + 1
            preference.preferenceItems[indexPath.row].quantity += 1
            if preference.preferenceItems[indexPath.row].quantity == preference.maxItemQuantity {
               let cell = preferenceTableView.cellForRow(at: indexPath) as! MultiQuantityPreferenceTableViewCell
                cell.shouldDisableAddButton = true
            }
        }
        
        updatePreferences(preference: preference, indexPath: indexPath)
    }
    
    func updateMealQuantityTo(_ quantity: Int) {
        meal.quantity = quantity
        addToCartButton.configureSubtitle(title: "$\(meal.totalPrice.amount.stringRepresentation)" )
    }
    
    func removeItemFromCart() {
        guard let index = mealInCartIndex else { return }
        Cart.shared.meals.remove(at: index)
        self.dismiss(animated: true, completion: nil)
    }
    
}

 //MARK: - InstructionInputDelegate

extension  MealViewController: InstructionInputDelegate {
    
    func didInputInstructions(_ instructions: String) {
        
        if instructions == "" {
            meal.instruction = nil
            footerView.instructionTextLabel.text = "Any special instructions?"
            footerView.instructionTextLabel.textColor = .gray
            return
        }
        
        meal.instruction = instructions
        
        footerView.instructionTextLabel.text = instructions
        footerView.instructionTextLabel.textColor = .black
        setFooterViewHeight()
    }

}
