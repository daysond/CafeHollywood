//
//  ManageReservationViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-03.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class ManageReservationViewController: UIViewController {
    
    private let reservationListTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .none
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.register(ReservationListTableViewCell.self, forCellReuseIdentifier: ReservationListTableViewCell.identifier)
        return tb
    }()
    
    let hintLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "You have no upcoming reservation."
        l.numberOfLines = 0
        l.textColor = .black
        l.textAlignment = .left
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return l
    }()
    
    var reservations: [Reservation] = [] {
        didSet {
            setupTableView()
            reservationListTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupView()
        
        NetworkManager.shared.getMyReservations { (reservations) in
            self.reservations = reservations
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
 
    private func setupTableView() {
        
        if reservations.isEmpty {
            
            view.addSubview(hintLabel)
            
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            return
        }
        
        view.addSubview(reservationListTableView)
        reservationListTableView.delegate = self
        reservationListTableView.dataSource = self
        
        NSLayoutConstraint.activate([
        
            reservationListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            reservationListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            reservationListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            reservationListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        
        ])
        
    }

    private func setupView() {
        
        view.backgroundColor = .white

        navigationItem.title = "Upcoming Reservations"
        
        let backButton = UIBarButtonItem(image: UIImage(named: "back84x84"), style: .plain, target: self, action:  #selector(back))
        navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
  
    }
    
    @objc private func back() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.popViewController(animated: true)
    }
    

}

extension ManageReservationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReservationListTableViewCell.identifier, for: indexPath) as! ReservationListTableViewCell
        cell.configureCellWith(reservations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 112
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let rvc = ReservationViewController(reservation: reservations[indexPath.row])
        tableView.cellForRow(at: indexPath)?.isSelected = false
//        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.pushViewController(rvc, animated: true)
        
    }
    

    
    
    
    
    
    
    
    
}
