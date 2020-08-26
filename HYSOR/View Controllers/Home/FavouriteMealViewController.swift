//
//  FavouriteMealViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-13.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

protocol UpdateFavouriteTableViewDelegate {
    func updateFavouriteTableView()
}

class FavouriteMealViewController: MealViewController {
    
    let index: Int
    
    var delegate: UpdateFavouriteTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
    }
    
    
    init(meal : Meal, index: Int) {
        self.index = index
        super.init(meal: meal, isNewMeal: true)

    }
    override func setupAddToCartButton() {
        
        addToCartButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        let title = "Save Modification"
        let subtitle = "$\(meal.totalPrice.amount.stringRepresentation)"
        addToCartButton.configureButton(headTitleText: title, subtitleText: subtitle)
        
    }
    
    @objc
    private func didTapSave() {
        
        APPSetting.shared.favouriteMeals[index] = meal
        storePreferenceForMeal(meal)
        self.delegate?.updateFavouriteTableView()
        self.dismiss(animated: true, completion: nil)
//        NotificationCenter.default.post(name: .updateFavouriteListTableView, object: self)
    }
    
    private func storePreferenceForMeal(_ meal: Meal) {
        
        if meal.instruction == nil && meal.preferences == nil {
            return
        }
        
        let userDefaults = UserDefaults.standard
        let data = meal.preferencesInJSON
        
        userDefaults.set(data, forKey: meal.uid)
        
    }
    
    @objc override func favoriteButtonTapped(sender: UIButton) {
        
        if meal.isFavourite {
          
            User.unfavouriteMeal(uid: meal.uid)
            sender.setImage(UIImage(named: "heartEmpty"), for: .normal)
            
        } else {
            
            User.favouriteMeal(uid: meal.uid)
            sender.setImage(UIImage(named: "heartFilled"), for: .normal)
        }
        
        self.delegate?.updateFavouriteTableView()
        
        
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
