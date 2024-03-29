//
//  ReceiptView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-03.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class ReceiptView: UIView {
    
    private let kCellHeightConstant: CGFloat = 64.0
    internal let kPriceLabelWidth: CGFloat = 76.0
    
    internal let receiptTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
//        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.allowsSelection = false
        tb.backgroundColor = .white
        tb.register(CartTableViewCell.self, forCellReuseIdentifier: CartTableViewCell.identifier)
        return tb
    }()
    
    internal let receiptHeaderView = RecepitTableViewHeader()
    
    internal let receiptFooterView = CartFooterView()
    
    var receipt: Receipt? {
        
        didSet {
            setupHeader()
            setupFooterView()
            receiptTableView.reloadData()
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        receiptTableView.delegate = self
        receiptTableView.dataSource = self
        addSubview(receiptTableView)
        
        setupHeader()
        setupFooterView()
        
        receiptTableView.frame = self.frame

        
    }
    
    internal func setupHeader() {
        
        guard let receipt = self.receipt else { return }
        receiptTableView.tableHeaderView = receiptHeaderView
        receiptHeaderView.frame.size.height = 120 + receipt.orderNote.textHeightFor(font: .systemFont(ofSize: 20, weight: .regular), width: frame.width - 32)
        receiptHeaderView.backgroundColor = .white
        receiptHeaderView.configureHeader(orderID: receipt.orderID, note: receipt.orderNote, timestamp: receipt.orderTimestamp)
        
        
    }
    
    
    internal func setupFooterView() {
        
        guard let receipt = self.receipt else { return }
        receiptTableView.tableFooterView = receiptFooterView
        receiptFooterView.frame.size.height = 200
        receiptFooterView.backgroundColor = .white
        receiptFooterView.setupFooterViewWithReceipt(receipt)
        
    }
    
    internal func heightForCellDetailLabel(at indexPath: IndexPath) -> CGFloat{
        
        guard let receipt = self.receipt else { return 0 }
        let addonInfo = receipt.mealsInfo[indexPath.row].addOnInfo
        var text = addonInfo
        let instruction = receipt.mealsInfo[indexPath.row].instruction
        if instruction != "" {
            text =  text == "" ?  "Note: \(instruction)" :  text + "\n\nNote: \(instruction)"
            print(text)
        }
        
        if text == "" {
            return 0
        }
        
        let cell = CartTableViewCell()
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: receiptTableView.frame.width - kPriceLabelWidth, height: CGFloat.greatestFiniteMagnitude))
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
    
    
    
    
    
    
    
}

extension ReceiptView: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let receipt = self.receipt else { return 0}
        return receipt.mealsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell {
            
            guard let receipt = self.receipt else { return UITableViewCell()}
            cell.configureCellWithMealInfo(receipt.mealsInfo[indexPath.row])
            
            return cell
        }
        
        return UITableViewCell()
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeightConstant + heightForCellDetailLabel(at: indexPath)
    }
    
    
    
    
    
    
}
