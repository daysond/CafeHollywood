//
//  OrderHistoryViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-15.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OrderHistoryViewController: UIViewController {
    
    private var segmentControl = CustomSegmentedControl()
    
    private let bag = DisposeBag()
    
    private let receiptCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .whiteSmoke
        return cv
    }()
    
    private let receipts = BehaviorRelay<[Receipt]>(value: [])
    
    //MARK: - TODO
    //SET SWIPE GESTURE REG FOR SEGMENT CONTROL

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
      
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appeat ")
//         addActiveOrderListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("will disappeat")
//        removeActiveOrderListener()
    }
    

    private func setupView() {
        
        view.backgroundColor = .offWhite
        setupSegmentedControl()
        setupCollectionView()
        setupCollectionViewRX()
        
    }
    
    private func setupSegmentedControl() {
        
        segmentControl = CustomSegmentedControl(frame: .zero, buttonTitle: ["Upcoming", "Past Orders"])
        segmentControl.delegate = self
        
        view.addSubview(segmentControl)
        
        NSLayoutConstraint.activate([
             
             segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             segmentControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier:  0.95),
             segmentControl.heightAnchor.constraint(equalToConstant: 50),
             segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])

    }
    
    private func setupCollectionView() {
        
        receiptCollectionView.delegate = self
        receiptCollectionView.register(ReceiptCollectionViewCell.self, forCellWithReuseIdentifier: ReceiptCollectionViewCell.identifier)
        receiptCollectionView.alwaysBounceVertical = true
        receiptCollectionView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(receiptCollectionView)
        
        receiptCollectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8).isActive = true
        receiptCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        receiptCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        receiptCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }
    
    private func setupCollectionViewRX() {
        
        
        receipts.bind(to: receiptCollectionView.rx.items(cellIdentifier: ReceiptCollectionViewCell.identifier, cellType: ReceiptCollectionViewCell.self)) {
            row, receipt, cell in
            cell.receipt = receipt
//            print( "meal info \(receipt.mealsInfo)")
        }
        .disposed(by: bag)
        
        

        
    }
    
    //MARK: - NETWORKING
    
    private func loadHistory() {
        
        NetworkManager.shared.fetchOrderHistory { (history) in
            self.receipts.accept(history)
        }
    
    }
    
    private func addActiveOrderListener() {
        
        NetworkManager.shared.addActiveOrderListener()
        NetworkManager.shared.activeOrderListenerDelegate = self
    }
    
    private func removeActiveOrderListener() {
        
        NetworkManager.shared.removeOrderListener()
        
    }

}

//MARK: - COLLECTION VIEW DELEGATE

extension OrderHistoryViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        
        let itemCount = receipts.value[indexPath.item].mealsInfo.count
        let width = receiptCollectionView.frame.width - 32
        let height = Constants.kReceiptFooterHeight + Constants.kReceiptHeaderHeight + Constants.kReceiptCellHeight * CGFloat(itemCount)

        return CGSize(width: width, height: height )
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
}


//MARK: - SEGMENTED CONTROL DELEGATE

extension OrderHistoryViewController: CustomSegmentedControlDelegate {
    
    func changeToIndex(index: Int) {
        print(index)
    }
    
}

extension OrderHistoryViewController: ActiveOrderListenerDelegate {
    
    func didReceiveActiveOrder(_ receipt: Receipt) {
        
        var receipts = self.receipts.value
        receipts.append(receipt)
        receipts.sort { (r1, r2) -> Bool in
            r1.orderTimestamp > r2.orderTimestamp
        }
        
        self.receipts.accept(receipts)
        
    }
    
    
    
    
}
