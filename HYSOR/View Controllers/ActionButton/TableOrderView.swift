//
//  TableOrderView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-15.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class TableOrderView: ReceiptView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        receiptTableView.delegate = self
        receiptTableView.dataSource = self
    }
    
    private let table = Table.shared
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setupHeader() {
        
        receiptTableView.tableHeaderView = receiptHeaderView
        receiptHeaderView.frame.size.height = 120
        receiptHeaderView.backgroundColor = .white
        receiptHeaderView.configureHeaderForCurrentTable()
    }
    
    override func setupFooterView() {
        receiptTableView.tableFooterView = receiptFooterView
        receiptFooterView.frame.size.height = 200
        receiptFooterView.backgroundColor = .white
        receiptFooterView.setupFooterViewForCurrentTable()
    }
    
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(Table.shared.meals.count)
        return table.meals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell {
        
            cell.configureCellWithMealInfo(table.meals[indexPath.row])
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    override func heightForCellDetailLabel(at indexPath: IndexPath) -> CGFloat{
        
        
        let addonInfo = table.meals[indexPath.row].addOnInfo
        var text = addonInfo
        let instruction = table.meals[indexPath.row].instruction
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
    
    
}


