//
//  OrderHistoryCollectionViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-16.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class ReceiptCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    //Model:

    //make a mealInfo Object or rather a receipt object.
    
    var receipt: Receipt? {
        didSet {
            if let receipt = receipt {
                headerView.configureHeader(orderStatus: receipt.orderStatus, timestamp: receipt.orderTimestamp, orderID: receipt.orderID, restaurantName: receipt.restaurantName)
                
                footerView.configureFooter(total: Money(amt: receipt.total).amount.stringRepresentation, tip: nil)
                receiptTableView.reloadData()
            }
        }
    }
    
    private let receiptTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.register(ReceiptTableViewCell.self, forCellReuseIdentifier: ReceiptTableViewCell.identifier)
        return tb
    }()
    
    private let headerView = ReceiptTableViewHeader()
    
    private let footerView = ReceiptTableViewFooter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setupTableView()
        
        
     
        
    }
    
    private func setupTableView() {
        
        receiptTableView.delegate = self
        receiptTableView.dataSource = self
        addSubview(receiptTableView)
        
        setupHeaderView()
        setupFooterView()
        
        NSLayoutConstraint.activate([
            
            receiptTableView.topAnchor.constraint(equalTo: topAnchor),
            receiptTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            receiptTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            receiptTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
        ])
        
    }
    
    private func setupHeaderView() {
        
        receiptTableView.tableHeaderView = headerView
        headerView.frame.size.height = Constants.kReceiptHeaderHeight
//        headerView.configureHeader()
        
    }
    
    private func setupFooterView() {
        
        receiptTableView.tableFooterView = footerView
        footerView.frame.size.height = Constants.kReceiptFooterHeight
//        footerView.configureFooter()
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension ReceiptCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receipt?.mealsInfo.count ?? 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let mealsInfo = receipt?.mealsInfo else { return UITableViewCell() }

        if let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptTableViewCell.identifier, for: indexPath) as? ReceiptTableViewCell {

            cell.configureCellWithMealInfo(mealsInfo[indexPath.row])

            return cell
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.kReceiptCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    
    
    
}
