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
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrderUpdates), name: .didUpdateDineInOrderStatus, object: nil)
        
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
    
    @objc private func handleOrderUpdates() {
        
        receiptTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return table.unconfirmedMeals.count
        case 1:
            return table.confirmedMeals.count
        case 2:
            return table.cancelledMeals.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell {
            
            switch indexPath.section {
            case 0:
                cell.configureCellWithMealInfo(table.unconfirmedMeals[indexPath.row], status: .unconfirmed)
            case 1:
                cell.configureCellWithMealInfo(table.confirmedMeals[indexPath.row], status: .confirmed)
            case 2:
                cell.configureCellWithMealInfo(table.cancelledMeals[indexPath.row], status: .cancelled)
            default:
                break
            }

            return cell
        }
        
        return UITableViewCell()
        
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "Unconfirmed"
        case 1:
            return "Confirmed"
        case 2:
            return "Cancelled"
        default:
            return nil
        }
        
    }
    
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            return table.unconfirmedMeals.count == 0 ? 0 : 24
        case 1:
            return table.confirmedMeals.count == 0 ? 0 : 24
        case 2:
            return table.cancelledMeals.count == 0 ? 0 : 24
        default:
            return 0
        }
        
        
    }
    
    override func heightForCellDetailLabel(at indexPath: IndexPath) -> CGFloat{
        
        var meals: [MealInfo] = []
        
        switch indexPath.section {
        case 0:
            meals = table.unconfirmedMeals
        case 1:
            meals = table.confirmedMeals
        case 2:
            meals = table.cancelledMeals
        default:
            return 0
        }
        
        let addonInfo = meals[indexPath.row].addOnInfo
        var text = addonInfo
        let instruction = meals[indexPath.row].instruction
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


