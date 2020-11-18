//
//  MenuViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-12.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import FirebaseStorage

class SubMenuViewController: UIViewController {
    
    private let subMenuCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: StretchyHeaderLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        return cv
    }()
    
    private let viewCartButton = BlackButton()
    
    private var headerView: SubMenuHeaderView?
    
    private let menu: Menu
    
    private var meals: [Meal] = [] {
        didSet{
            subMenuCollectionView.reloadData()
        }
    }
    
    
    
    fileprivate let padding: CGFloat = 16
    
    fileprivate var menuCollectionViewTopConstraint: NSLayoutConstraint?
    
    init(with menu : Menu) {
    
        self.menu = menu
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
        setupNavigationBar()
        fetchMealsFromMenu()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setupNavigationBar()
        viewCartButton.configureSubtitle(title: "$\(Cart.shared.cartSubtotal.amount.stringRepresentation)" )
        self.navigationController?.isNavigationBarHidden = false
        headerView?.setupVisualEffectBlur()
        let yTransition = subMenuCollectionView.contentOffset.y
        updateUIAccrodingToContentOffsetY(yTransition)
        

    }
    
    //MARK: - Setup view
    
    private func setupNavigationBar() {

        let backButton = UIBarButtonItem(image: UIImage(named: "back84x84"), style: .plain, target: self, action:  #selector(backButtonTapped))
        navigationController?.navigationBar.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        
        
    }
    
    private func setupView() {
        
        view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        
        view.addSubview(subMenuCollectionView)
        
        view.addSubview(viewCartButton)
        
        viewCartButton.addTarget(self, action: #selector(viewCartButtonTapped), for: .touchUpInside)
        
        let title = APPSetting.shared.isDineIn ? "View Order" : "View Cart"
        
        viewCartButton.configureButton(headTitleText: title, subtitleText: "$\(Cart.shared.cartSubtotal.amount.stringRepresentation)")
        
        Cart.shared.uiDelegate = self
        
        menuCollectionViewTopConstraint = subMenuCollectionView.topAnchor.constraint(equalTo: view.topAnchor)
        
        NSLayoutConstraint.activate([
            
            menuCollectionViewTopConstraint!,
            subMenuCollectionView.bottomAnchor.constraint(equalTo: viewCartButton.topAnchor),
            subMenuCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subMenuCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            viewCartButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            viewCartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            viewCartButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            viewCartButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            
            
        ])
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupCollectionView() {
        
        subMenuCollectionView.dataSource = self
        subMenuCollectionView.delegate = self
        subMenuCollectionView.register(SubMenuCollectionViewCell.self, forCellWithReuseIdentifier: SubMenuCollectionViewCell.identifier)
        subMenuCollectionView.register(SubMenuHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SubMenuHeaderView.identifier)
        
        subMenuCollectionView.contentInsetAdjustmentBehavior = .never
        subMenuCollectionView.alwaysBounceVertical = true
        subMenuCollectionView.backgroundColor = .white
        
        if let layout = subMenuCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
            
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let yTransition = scrollView.contentOffset.y
        updateUIAccrodingToContentOffsetY(yTransition)
    }
    
    private func updateUIAccrodingToContentOffsetY(_ yTransition: CGFloat) {
        
        let height: CGFloat = view.frame.width * 9.0/16.0
        if yTransition > height - 44 - 44 - 32 {
            headerView?.frame.size.height = 0
            menuCollectionViewTopConstraint?.constant = -44
            self.navigationController?.navigationBar.standardAppearance.configureWithDefaultBackground()
            self.navigationItem.title = menu.menuTitle
            navigationController?.navigationBar.tintColor = .black
            return
        }
        
        headerView?.frame.size.height = height
        menuCollectionViewTopConstraint?.constant = 0
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()

        navigationController?.navigationBar.tintColor = .white
        
        if yTransition >= 0 {
            headerView?.animator.fractionComplete = 0
            return
        } else {
            headerView?.animator.fractionComplete = abs(yTransition)/100
            return
        }
        
    }
    
    
    //MARK: - ACTION SETUP
    
    @objc private func viewCartButtonTapped() {
        
        let cartVC = CartViewController()
        let nav = UINavigationController(rootViewController: cartVC)
        nav.modalPresentationStyle = .automatic
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc private func backButtonTapped() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - HELPERS
    
    private func fetchMealsFromMenu() {
        
        //1. fetch from data base
        //2. if nil fetch from network then wtire to data base
        
        let group = DispatchGroup()
        var tempMeals: [Meal] = []
        
        menu.mealsInUID.forEach { (uid) in
            group.enter()
            
            if let meal = DBManager.shared.readMeal(uid: uid) {
//                print("got \(uid) from DB")
                tempMeals.append(meal)
                group.leave()
                
            } else {
                
                NetworkManager.shared.fetchMealWithMealUID(uid) { (meal) in
                    guard let meal = meal else {
                        group.leave()
                        return
                    }
//                    print("got \(meal.uid) from FB")
                    DBManager.shared.writeMeal(meal)
                    tempMeals.append(meal)
                    group.leave()
                }
            }
            
        }
        
        group.notify(queue: DispatchQueue.main) {
     
            tempMeals.sort { (m1, m2) -> Bool in
                m1.uid < m2.uid
            }

            self.meals = tempMeals
        }
        
    }
    
    func intrinsicCellHeight(at item: Int ) -> CGFloat {
        
        let width = subMenuCollectionView.frame.width - 104 - padding * 2
        
        let nameLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width , height: CGFloat.greatestFiniteMagnitude))
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.text = meals[item].name
        nameLabel.sizeToFit()
        
        let priceLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        priceLabel.numberOfLines = 0
        priceLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        priceLabel.font = .systemFont(ofSize: 16)
        priceLabel.text = "$\(meals[item].price.stringRepresentation)"
        priceLabel.sizeToFit()
        
        let detailLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        detailLabel.numberOfLines = 0
        detailLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        detailLabel.font = .systemFont(ofSize: 16)
        detailLabel.text = meals[item].details
        detailLabel.sizeToFit()
        
        return nameLabel.frame.height + priceLabel.frame.height + detailLabel.frame.height + 4 * 16
        
    }
    
    
    
    
}

// MARK: - FLOW LAYOUT

extension SubMenuViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let mealViewController = MealViewController(meal: meals[indexPath.item], isNewMeal: true)
        self.navigationController?.pushViewController(mealViewController, animated: true)
        
        if let selectedItemIndexPath = self.subMenuCollectionView.indexPathsForSelectedItems?.first {
            self.subMenuCollectionView.deselectItem(at: selectedItemIndexPath, animated: true)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return meals.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubMenuCollectionViewCell.identifier, for: indexPath) as? SubMenuCollectionViewCell {
            let meal = meals[indexPath.item]
            cell.configureCellWith(meal: meal)
            return cell
        }
        
        return SubMenuCollectionViewCell()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SubMenuHeaderView.identifier, for: indexPath) as? SubMenuHeaderView
        
        
        LocalFileManager.shared.fetchImage(imageURL: menu.headerImageURL) { (image) in
            DispatchQueue.main.async {
                guard let image = image else {
                    print("can not fetch header for menu \(self.menu.uid)")
                    self.headerView!.image = UIImage(named: "cafe")
                    return
                }

                self.headerView!.image = image
            }
            
        }
    
    
    
        headerView!.titleLabel.text = menu.menuTitle.capitalized
        headerView!.detailLabel.text = menu.menuDetail == nil ? "" : menu.menuDetail!
        
        
        return headerView!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: view.frame.width * 9.0/16.0)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        

        
        let width = subMenuCollectionView.frame.width
        
        let height = intrinsicCellHeight(at: indexPath.item)
        
        return CGSize(width: width - 2 * padding, height:  height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    
    
}

extension SubMenuViewController: UpdateDisplayDelegate {
    
    func updateDisplay() {
        viewCartButton.configureSubtitle(title: "$\(Cart.shared.cartSubtotal.amount.stringRepresentation)" )
    }
    
}
