//
//  MenusViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-07.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MenuViewController: UIViewController {
    
    private let menuCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        return cv
    }()
    
    private let selectButton = BlackButton()
    private var menuLauncher: SlideInMenuLauncher?
    private var segmentControl = CustomSegmentedControl()
    
    private let bag = DisposeBag()
    private let menus = BehaviorRelay<[Menu]>(value: []) // [uid: imageURL] [key: value]
    
    private var foodMenu = [Menu]()
    private var drinkMenu = [Menu]()
    
    private let loadingView = LoadingViewController(animationFileName: "dotsLoading")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //PAUSE SCREEN WHILE GETTING MENU
        setupView()
        setupCollectionView()
        setupCellSelectedHandling ()
        checkUpdateAndGetData()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    //MARK: - Setup view
    
    private func setupView() {
        
        view.backgroundColor = .white
        
        menuCollectionView.delegate = self
        menuCollectionView.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: MenuCollectionViewCell.identifier)
        menuCollectionView.alwaysBounceVertical = true
        view.addSubview(menuCollectionView)
        
//        selectButton.configureTitle(title: "Online Order & Pick Up")
//        selectButton.addTarget(self, action: #selector(setupLaunchMenu), for: .touchUpInside)
//        view.addSubview(selectButton)
//
        segmentControl = CustomSegmentedControl(frame: .zero, buttonTitle: ["Foods", "Drinks"])
        segmentControl.delegate = self
        view.addSubview(segmentControl)
        
        let roundedCartButton = RoundCartButton()
        roundedCartButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCart)))
        view.addSubview(roundedCartButton)
        
        NSLayoutConstraint.activate([
            
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier:  0.95),
            segmentControl.heightAnchor.constraint(equalToConstant: 50),
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            menuCollectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            menuCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            menuCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            menuCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
//            selectButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
//            selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
//            selectButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            selectButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            roundedCartButton.widthAnchor.constraint(equalToConstant: 64),
            roundedCartButton.heightAnchor.constraint(equalToConstant: 64),
            roundedCartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            roundedCartButton.bottomAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
//            roundedCartButton.bottomAnchor.constraint(equalTo: selectButton.topAnchor, constant: -16),
        ])
        
        
    }
    
    
    
    //MARK: - ACTIONS
    
    @objc private func dineInOrPickUpButtonTapped(sender: UIButton) {
        
        // NOTE:  Tag: dine in = 0, pick up = 1
        switch sender.tag {
        case 0:
            let scanneeVC = ScannerViewController()
            scanneeVC.delegate = self
            self.navigationController?.pushViewController(scanneeVC, animated: true)
            
        case 1:
//            APPSetting.shared.isDineIn = false
            Table.shared.tableNumber = nil
            selectButton.configureTitle(title: "Online Order & Pick Up")
        default:
            return
        }
        
        dismissMenu()
        
    }
    
    @objc
    private func setupLaunchMenu() {
        
        let dineInbutton = BlackButton()
        dineInbutton.tag = 0
        dineInbutton.configureButton(headTitleText: "Dine In At Restaurant", titleColor: .black, backgroud: UIColor.white)
        dineInbutton.addTarget(self, action: #selector(dineInOrPickUpButtonTapped(sender:)), for: .touchUpInside)
        
        
        let onlineButton = BlackButton()
        onlineButton.tag = 1
        onlineButton.configureButton(headTitleText: "Order Online & Pick Up", titleColor: .black, backgroud: UIColor.white)
        onlineButton.addTarget(self, action: #selector(dineInOrPickUpButtonTapped(sender:)), for: .touchUpInside)
        
        let cancelButton = BlackButton()
        cancelButton.configureTitle(title: "Cancel")
        cancelButton.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
        
        
        let menuStackView = UIStackView(arrangedSubviews: [onlineButton, dineInbutton, cancelButton])
        menuStackView.axis = .vertical
        menuStackView.distribution = .fillEqually
        menuStackView.spacing = 0
        
        
        let height = Constants.kOrderButtonHeightConstant * 2 + 40
        
        let blackView = UIView()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tapGes)
        blackView.isUserInteractionEnabled = true
        
        let menuLauncher = SlideInMenuLauncher(blackView: blackView, menuView: menuStackView, menuHeight: height)
        self.menuLauncher = menuLauncher
        menuLauncher.showMenu()
        
        
    }
    
    @objc func dismissMenu() {
        menuLauncher?.dismissMenu()
    }
    
    @objc func showCart() {
        
        let cartVC = CartViewController()
        let nav = UINavigationController(rootViewController: cartVC)
        nav.modalPresentationStyle = .automatic
        self.present(nav, animated: true, completion: nil)
        
        
    }
    
    //MARK: - HELPERS
    
    private func createLoadingView() {
        
        addChild(loadingView)
        loadingView.view.frame = view.frame
        view.addSubview(loadingView.view)
        loadingView.didMove(toParent: self)
        
    }
    
    private func dismissLoadingView() {
        
        loadingView.willMove(toParent: nil)
        loadingView.view.removeFromSuperview()
        loadingView.removeFromParent()
        
    }
    
    //MARK: - NETWORKING
    
    private func checkUpdateAndGetData() {
        
        createLoadingView()
        
        NetworkManager.shared.getCurrentVersion { (newVersion) in
            guard let newVersion = newVersion else { print("returned")
                return }
            
            
            self.compareCurrentVersion(with: newVersion)
        }
        
    }
    
    private func compareCurrentVersion(with newVersion: String) {

        func deleteAndSet() {
            DBManager.shared.deleteAllData()
            userDefaults.set(newVersion, forKey: "menuVersion")
            getMenuData()
        }
        
        guard let currentMenuVersion = userDefaults.string(forKey: "menuVersion") else {
            deleteAndSet()
            return
        }
        
        newVersion == currentMenuVersion ? getMenuData() : deleteAndSet()
        
    }
    
    private func getMenuData() {
        
        let group = DispatchGroup()
        
        foodMenu = DBManager.shared.readMenu(type: .foodMenu)
        drinkMenu = DBManager.shared.readMenu(type: .drinkMenu)
        
        if foodMenu.count == 0 {
            group.enter()
            NetworkManager.shared.getMenu(type: .foodMenu) { (menus) in
                guard let menus = menus else { return }
                menus.forEach { (menu) in
                    DBManager.shared.writeMenu(menu, to: .foodMenu)
                }
                self.foodMenu = menus
                self.menus.accept(self.foodMenu)
                group.leave()
            }
            
        } else {
            
             menus.accept(foodMenu)
            
        }
        
        if drinkMenu.count == 0 {
            group.enter()
            NetworkManager.shared.getMenu(type: .drinkMenu) { (menus) in
                guard let menus = menus else { return }
                menus.forEach { (menu) in
                    DBManager.shared.writeMenu(menu, to: .drinkMenu)
                }
                self.drinkMenu = menus
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.dismissLoadingView()
        }
        
    }
    
    //MARK: - RX SETUP
    
    private func setupCollectionView() {
        
        menus.bind(to: menuCollectionView.rx.items(cellIdentifier: MenuCollectionViewCell.identifier, cellType: MenuCollectionViewCell.self)) {
            row, menu, cell in
            let imageURL = menu.imageURL
            cell.configureCellWith(imageURL: imageURL )
            
            
        }
        .disposed(by: bag)
        
    }
    
    
    private func setupCellSelectedHandling() {
        
        menuCollectionView.rx.modelSelected(Menu.self)
            .subscribe(onNext: { [unowned self] menu in
                let uid = menu.mealsInUID[0]
                if menu.isSingleMealMenu {
                    
                    if let meal = DBManager.shared.readMeal(uid: uid) {
                        self.pushMealVC(meal: meal)
                        
                    } else {
                        NetworkManager.shared.fetchMealWithMealUID(uid) { (meal) in
                            guard let meal = meal else { return }
                            print("got \(meal.uid) from FB")
                            DBManager.shared.writeMeal(meal)
                            DispatchQueue.main.async {
                                self.pushMealVC(meal: meal)
                            }
                        }
                    }
                    
                } else {
                    let menuViewController = SubMenuViewController(with: menu)
                    self.navigationController?.pushViewController(menuViewController, animated: true)
                }
                
                if let selectedItemIndexPath = self.menuCollectionView.indexPathsForSelectedItems?.first {
                    self.menuCollectionView.deselectItem(at: selectedItemIndexPath, animated: true)
                }
                
                
            }).disposed(by: bag)
    }
    
    private func pushMealVC(meal: Meal) {
        
        let mealVC = MealViewController(meal: meal, isNewMeal: true)
        self.navigationController?.pushViewController(mealVC, animated: true)
        
    }
    
    
    
    
}

//MARK: - DELEGATES

extension MenuViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (menuCollectionView.frame.width - 16) / 2.0
        return CGSize(width: width, height:  width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}



extension MenuViewController: QRCodeScannerDelegate {
    
    
    func found() {
//        Table.shared.tableNumber = tableNumber
    }
    
    func failedReadingQRCode() {
        
        //TODO: show alert
        print("failed")
    }
    
    
}

extension MenuViewController: CustomSegmentedControlDelegate {
    
    func changeToIndex(index: Int) {
        
        switch index {
        case 0:
            menus.accept(foodMenu)
        case 1:
            menus.accept(drinkMenu)
        default:
            return
        }
        
        
    }
    
    
    
    
    
}
