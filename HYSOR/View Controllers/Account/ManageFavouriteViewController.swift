//
//  ManageFavouriteViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-25.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class ManageFavouriteViewController: UIViewController {
    
    private let favouriteListTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.allowsSelection = false 
        tb.register(ManageFavouriteListTableViewCell.self, forCellReuseIdentifier: ManageFavouriteListTableViewCell.identifier)
        return tb
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func setupView() {
        
        view.backgroundColor = .white
        
//        self.navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "My Favourites"
        let backButton = UIBarButtonItem(image: UIImage(named: "back84x84"), style: .plain, target: self, action:  #selector(back))
        navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        
        if APPSetting.favouriteList.isEmpty {
            
            view.addSubview(hintLabel)
            
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            return
        }
        
        
        view.addSubview(favouriteListTableView)
        favouriteListTableView.delegate = self
        favouriteListTableView.dataSource = self
        
        NSLayoutConstraint.activate([
        
            favouriteListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            favouriteListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            favouriteListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            favouriteListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        
        ])
        
        navigationItem.rightBarButtonItem = editButtonItem

        downloadData()
    }
    
    @objc private func back() {
//        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.popViewController(animated: true)
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
                
                self.favouriteListTableView.reloadData()
            }
            
        }
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        favouriteListTableView.setEditing(editing, animated: true)
    }

    

}

extension ManageFavouriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APPSetting.favouriteMeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ManageFavouriteListTableViewCell.identifier, for: indexPath) as! ManageFavouriteListTableViewCell
        cell.configureCellWith(meal: APPSetting.favouriteMeals[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let uid = APPSetting.favouriteList[indexPath.row]
            APPSetting.unfavouriteMeal(uid: uid)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    
    
    
    
    
}
