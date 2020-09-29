//
//  FavouriteView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-11.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class FavouriteView: UIView, UpdateFavouriteTableViewDelegate {
    
    private let favouriteMealTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.register(FavouriteTableViewCell.self, forCellReuseIdentifier: FavouriteTableViewCell.identifier)
        return tb
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Quick Order From Favourite"
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return l
    }()
    
    private let hintLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Uh-oh, your favourite list is empty."
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return l
    }()
    
    let addToCartButton = BlackButton()
    let cancelButton = BlackButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        print("init view")
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .updateFavouriteListTableView, object: nil)
        
        downloadData()
        
        backgroundColor = .ghostWhite
        layer.cornerRadius = 8
        
        addToCartButton.configureTitle(title: "Add To Cart")
        addToCartButton.layer.cornerRadius = 4
        updateAddToCartButtonStatus()
        addSubview(addToCartButton)
        
        
        cancelButton.configureTitle(title: "Cancel")
        cancelButton.layer.cornerRadius = 4
        addSubview(cancelButton)
        
        favouriteMealTableView.dataSource = self
        favouriteMealTableView.delegate = self
        favouriteMealTableView.backgroundColor = .whiteSmoke
        favouriteMealTableView.layer.cornerRadius = 8
        favouriteMealTableView.separatorStyle = .none
        
        addSubview(favouriteMealTableView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            favouriteMealTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            favouriteMealTableView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            favouriteMealTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            favouriteMealTableView.bottomAnchor.constraint(equalTo: addToCartButton.topAnchor, constant: -8),
            
            addToCartButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            addToCartButton.leadingAnchor.constraint(equalTo: favouriteMealTableView.leadingAnchor),
            addToCartButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -20),
            addToCartButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            cancelButton.widthAnchor.constraint(equalTo: addToCartButton.widthAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: favouriteMealTableView.trailingAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            
        ])
        
        if APPSetting.favouriteList.isEmpty {
            
            addSubview(hintLabel)
            
            hintLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            hintLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
        }
        
    }
    
   private func shouldEnableAddToCartButton() -> Bool {
    
        var shouldEnable = false
    
        for meal in APPSetting.favouriteMeals {
             
            if meal.isSelected && meal.isModificationRequired {
                return false
            } else if meal.isSelected && !meal.isModificationRequired {
                shouldEnable = true
            }
        }
  
        return shouldEnable
    }
    
    private func updateAddToCartButtonStatus() {
        
        addToCartButton.isEnabled = shouldEnableAddToCartButton()
        addToCartButton.backgroundColor = addToCartButton.isEnabled ? .black : .lightGray
        
    }
    
    private func downloadData() {
        
        let group = DispatchGroup()
        
        let uids = APPSetting.favouriteMeals.map { (meal) -> String in
            return meal.uid
        }
        
        APPSetting.favouriteList.forEach { (uid) in
            
            if !uids.contains(uid) {
                
                group.enter()
                
                if var meal = DBManager.shared.readMeal(uid: uid) {
                    meal.recoverPreferenceState()
                    APPSetting.favouriteMeals.append(meal)
                    group.leave()
                    
                } else {
                    
                    NetworkManager.shared.fetchMealWithMealUID(uid) { (meal) in
                        guard var meal = meal else {
                            group.leave()
                            return
                        }

                        DBManager.shared.writeMeal(meal)
                        meal.recoverPreferenceState()
                        APPSetting.favouriteMeals.append(meal)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                
                APPSetting.favouriteMeals.sort { (m1, m2) -> Bool in
                    m1.uid < m2.uid
                }
                
                self.favouriteMealTableView.reloadData()
            }
            
        }
        
    }
    

    
    
    private func heightForCellDetailLabel(at indexPath: IndexPath) -> CGFloat{
        
        let meal = APPSetting.favouriteMeals[indexPath.row]
    
        var text = meal.addOnInfo
        let instruction = meal.instruction
        if instruction != nil {
            text =  text == "" ?  "Note: \(instruction!)" :  text + "\n\nNote: \(instruction!)"
            print(text)
        }
        
        if meal.isModificationRequired {
            text = text == "" ? text + "Please select the required fileds from meal." : text + "\nPlease select the required fileds from meal."
        }

        if text == "" {
            return 0
        }
        
        let cell = FavouriteTableViewCell()
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: favouriteMealTableView.frame.width - cell.modifyButtonWidth - 16, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = cell.detailLabel.font
        label.text = text + "\n"
        label.sizeToFit()
        
        return label.frame.height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFavouriteTableView() {
        
        updateAddToCartButtonStatus()
        self.favouriteMealTableView.reloadData()
        
    }
    
    
}

extension FavouriteView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("reloaded with \(APPSetting.favouriteMeals.count)")
        return APPSetting.favouriteMeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let meal = APPSetting.favouriteMeals[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteTableViewCell.identifier, for: indexPath) as? FavouriteTableViewCell {
            cell.configureCellWithMeal(meal)
            cell.indexPath = indexPath
            return cell
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 + heightForCellDetailLabel(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? FavouriteTableViewCell {
            var meal = APPSetting.favouriteMeals[indexPath.row]
            meal.isSelected = !meal.isSelected
            cell.isCellSelected = meal.isSelected
            APPSetting.favouriteMeals[indexPath.row] = meal
            tableView.deselectRow(at: indexPath, animated: false)
             updateAddToCartButtonStatus()
        }
        
    }
    
}

