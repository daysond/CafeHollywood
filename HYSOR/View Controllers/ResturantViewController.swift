//
//  ViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-11.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ResturantViewController: UIViewController {
    
    private let resturantCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        return cv
    }()
    
    private let bag = DisposeBag()
    private let resturants = BehaviorRelay<[Receipt]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.


        setupView()
        setupCollectionView()
        setupCellSelectedHandling()
        
        NetworkManager.shared.fetchOrderHistory { (history) in
            self.resturants.accept(history)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    //MARK: - Setup view
    
    private func setupView() {
        
        view.backgroundColor = .white
        resturantCollectionView.delegate = self
        resturantCollectionView.register(ResturantCollectionViewCell.self, forCellWithReuseIdentifier: ResturantCollectionViewCell.identifier)
        
        let scanButton = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(scanButtonTapped))
        navigationItem.rightBarButtonItem = scanButton
        
        view.addSubview(resturantCollectionView)
        
        NSLayoutConstraint.activate([
            resturantCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resturantCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            resturantCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            resturantCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
        ])
        
    }
    

    //MARK: - ACTIONS
    
    @objc private func scanButtonTapped() {
        let scanneeVC = ScannerViewController()
        scanneeVC.delegate = self
        self.navigationController?.pushViewController(scanneeVC, animated: true)
    }
    
    //MARK: - RX SETUP
    
    func setupCollectionView() {
        
        resturants.bind(to: resturantCollectionView.rx.items(cellIdentifier: ResturantCollectionViewCell.identifier, cellType: ResturantCollectionViewCell.self)) {
            row, resturant, cell in
//            print(resturant.orderID)
            cell.backgroundColor = .red
        }
        .disposed(by: bag)
        
    }
    
    
    func setupCellSelectedHandling() {
        
//        resturantCollectionView.rx.modelSelected(Resturant.self)
//            .subscribe(onNext: { [unowned self] resturant in
////                let menuViewController = SubMenuViewController(with: resturant)
////                self.navigationController?.pushViewController(menuViewController, animated: true)
////                if let selectedItemIndexPath = self.resturantCollectionView.indexPathsForSelectedItems?.first {
////                    self.resturantCollectionView.deselectItem(at: selectedItemIndexPath, animated: true)
////                }
//            }).disposed(by: bag)
    }


}

extension ResturantViewController: QRCodeScannerDelegate {
    
    func foundResturantDataFromQRCode(data: [String : Any]) {
        guard let name = data["name"] as? String else { print("name error"); return }
        guard let imageURL = data["imageURL"] as? String else { print("imageURL error"); return }
        guard let uid = data["uid"] as? String else { print("uid error"); return }
//        guard let name = data["menu"] as? Array else { print("menu error"); return }
//        let food1 = Meal(uid: "123456", name: "spaghettei bologness", price: 9.90, orderedTimestamp: "", details: "beef mean sauce", imageURL: "shit", preferences: nil)
//        let food2 = Meal(uid: "123456", name: "spaghettei bologness", price: 9.90, orderedTimestamp: "", details: "beef mean sauce", imageURL: "poo", preferences: nil)
//        let menu = [food1, food2,food1,food2,food1,food2,food2,food2,food1]
//        let resturant = Resturant(name: name, uid: uid, imageURL: imageURL, menu: menu)
//        print("found res \(resturant.name)")
////        let menuViewController = SubMenuViewController(with: resturant)
//        self.navigationController?.pushViewController(menuViewController, animated: true)
    }
    
    func failedReadingQRCode() {
         
        //TODO: show alert
        print("failed")
    }
    
    
}



extension ResturantViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = resturantCollectionView.frame.width
        return CGSize(width: width, height:  200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}
