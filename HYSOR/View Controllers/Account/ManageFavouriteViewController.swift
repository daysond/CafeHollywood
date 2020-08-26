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
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        downloadData()
        
    }
    
    private func setupView() {
        
        view.backgroundColor = .white
        view.addSubview(favouriteListTableView)
        favouriteListTableView.delegate = self
        favouriteListTableView.dataSource = self
        
        
        NSLayoutConstraint.activate([
        
            favouriteListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            favouriteListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            favouriteListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            favouriteListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        
        ])
        
        navigationItem.title = "My Favourite"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = editButtonItem
   
        
        
    }
    
    @objc private func back() {
        dismiss(animated: true, completion: nil)
    }
    

    private func downloadData() {
        
        let group = DispatchGroup()
        
        let uids = APPSetting.shared.favouriteMeals.map { (meal) -> String in
            return meal.uid
        }
        
        User.shared.favouriteList.forEach { (uid) in
            
            if !uids.contains(uid) {
                
                group.enter()
                
                if var meal = DBManager.shared.readMeal(uid: uid) {
                    meal.recoverPreferenceState()
                    APPSetting.shared.favouriteMeals.append(meal)
                    group.leave()
                    
                } else {
                    
                    NetworkManager.shared.fetchMealWithMealUID(uid) { (meal) in
                        guard var meal = meal else {
                            group.leave()
                            return
                        }

                        DBManager.shared.writeMeal(meal)
                        meal.recoverPreferenceState()
                        APPSetting.shared.favouriteMeals.append(meal)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                
                APPSetting.shared.favouriteMeals.sort { (m1, m2) -> Bool in
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
        return APPSetting.shared.favouriteMeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = APPSetting.shared.favouriteMeals[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let uid = User.shared.favouriteList[indexPath.row]
            User.unfavouriteMeal(uid: uid)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    
    
    
    
    
}
