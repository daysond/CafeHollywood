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
    
    private var availableFoodMenu: [Menu] {
        return foodMenu.filter { !APPSetting.shared.unavailableMenus.contains($0.uid) }
    }
    
    private var availableDrinkMenu: [Menu] {
        return drinkMenu.filter { !APPSetting.shared.unavailableMenus.contains($0.uid) }
    }
    
    private let loadingView = LoadingViewController(animationFileName: "dotsLoading")
    
    private var shouldHideTakeOutMenus: Bool = false {
        didSet{
            populateMenus()
        }
    }
    
    private var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupView()
        setupCollectionView()
        setupCellSelectedHandling ()
        checkUpdateAndGetData()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        shouldHideTakeOutMenus = Table.shared.tableNumber != nil
    }
    
    
    //MARK: - Setup view
    
    private func setupView() {
        
        view.backgroundColor = .white
        
        menuCollectionView.delegate = self
        menuCollectionView.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: MenuCollectionViewCell.identifier)
        menuCollectionView.alwaysBounceVertical = true
        view.addSubview(menuCollectionView)
        
        segmentControl = CustomSegmentedControl(frame: .zero, buttonTitle: ["Foods", "Drinks"])
        segmentControl.delegate = self
        view.addSubview(segmentControl)
        
        
        NSLayoutConstraint.activate([
            
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier:  0.95),
            segmentControl.heightAnchor.constraint(equalToConstant: 50),
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            menuCollectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            menuCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            menuCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            menuCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
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
    
    @objc private func dismissMenu() {
        menuLauncher?.dismissMenu()
    }
    
    private func populateMenus() {
        
        switch selectedIndex {
        case 0:
            menus.accept(shouldHideTakeOutMenus ? availableFoodMenu.filter({ $0.isTakeOutOnly == false }) : availableFoodMenu)
        default:
            menus.accept(shouldHideTakeOutMenus ? availableDrinkMenu.filter({ $0.isTakeOutOnly == false }) : availableDrinkMenu)
        }
        
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
        
        guard let menuVersion = APPSetting.shared.versions["menu"] else {
            
            NetworkManager.shared.getCurrentVersions { (error) in
                guard error == nil else {
                    self.showError(message: error!.localizedDescription)
                    return
                }
                
                if let menuVersion = APPSetting.shared.versions["menu"] {
                    self.compareCurrentVersion(with: menuVersion)
                } else {
                    self.showError(message: "Fail checking menu updates.")
                }
            }
            return
        }
        
        compareCurrentVersion(with: menuVersion)
        
    }
    
    private func compareCurrentVersion(with newVersion: String) {
        
        func deleteAndSet() {
            DBManager.shared.deleteAllData()
            userDefaults.set(newVersion, forKey: Key.menuVersion)
            getMenuData()
        }
        
        guard let currentMenuVersion = userDefaults.string(forKey: Key.menuVersion) else {
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
                group.leave()
            }
            
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
            
            self.menus.accept(self.availableFoodMenu)
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
                            //                            print("got \(meal.uid) from FB")
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
        
    }
    
    func failedReadingQRCode() {
        self.showError(message: "Failed reading QRCode.")
    }
    
    
}

extension MenuViewController: CustomSegmentedControlDelegate {
    
    func changeToIndex(index: Int) {
        
        selectedIndex = index
        populateMenus()
        
    }
    
    
    
    
    
}
