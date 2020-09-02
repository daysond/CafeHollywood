//
//  OrderHistoryCollectionViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-16.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

protocol ViewReceiptDelegate {
    func showReceipt(_ receipt: Receipt)
}

class OrderHistoryCollectionViewCell: UICollectionViewCell {
    
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
    
    var delegate: ViewReceiptDelegate?
    
    private let receiptTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.register(OrderHistoryTableViewCell.self, forCellReuseIdentifier: OrderHistoryTableViewCell.identifier)
        return tb
    }()
    
    private let headerView = OrderHistoryTableViewHeader()
    
    private let footerView = OrderHistoryTableViewFooter()
    
    let viewReceiptButton = BlackButton()
//    let viewReceiptButton: BlackButton
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setupView()
        
        
    }
    
    private func setupView() {
        
        receiptTableView.delegate = self
        receiptTableView.dataSource = self
        receiptTableView.alwaysBounceVertical = false 
        
        addSubview(receiptTableView)
        addSubview(viewReceiptButton)
        viewReceiptButton.configureTitle(title: "View Receipt")
        viewReceiptButton.addTarget(self, action: #selector(viewReceipt), for: .touchUpInside)
        setupHeaderView()
        setupFooterView()
        
        NSLayoutConstraint.activate([
            
            receiptTableView.topAnchor.constraint(equalTo: topAnchor),
            receiptTableView.bottomAnchor.constraint(equalTo: viewReceiptButton.topAnchor, constant: -16),
            receiptTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            receiptTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            viewReceiptButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            viewReceiptButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            viewReceiptButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            viewReceiptButton.heightAnchor.constraint(equalToConstant: 48),
        
            
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
    
    @objc private func viewReceipt() {
        self.delegate?.showReceipt(receipt!)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension OrderHistoryCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receipt?.mealsInfo.count ?? 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let mealsInfo = receipt?.mealsInfo else { return UITableViewCell() }

        if let cell = tableView.dequeueReusableCell(withIdentifier: OrderHistoryTableViewCell.identifier, for: indexPath) as? OrderHistoryTableViewCell {

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
