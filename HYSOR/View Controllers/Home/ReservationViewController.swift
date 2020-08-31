//
//  ReservationViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-11.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class ReservationViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    
    private var viewWidth: CGFloat = 0
    
    let reservation: Reservation
    
    private let specialRequestLabel =  UILabel()
    private let noteLabel =  UILabel()
    
    init(reservation: Reservation) {
        self.reservation = reservation
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWidth = view.frame.width - 32
        view.backgroundColor = .white
//        reservation.note = "I dont want any thing thingthing scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)"
        setupNavigationBar()
        setupView()
        
    }
    


    
    private func setupView() {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .whiteSmoke
        
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            

        ])

        
        setupScrollViewSubviews()
    }
    
    private func setupScrollViewSubviews() {
        
        
        
        let restaurantNameLabel = UILabel()
        restaurantNameLabel.text = "Cafe Hollywood"
        restaurantNameLabel.numberOfLines = 0
        restaurantNameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        restaurantNameLabel.frame = CGRect(x: 16, y: 8, width: viewWidth, height: restaurantNameLabel.intrinsicHeight(width: viewWidth))
        
        // ------------------------------------------------------------------------------------------
        
        let statusIndicator = UIImageView()
        statusIndicator.image = UIImage(named: reservation.isConfirmed ? "completed" : "cancel")
        
        let statusLabel = UILabel()
        statusLabel.text = reservation.isConfirmed ? "Reservation Confirmed!" : "Reservation Canceled."
        statusLabel.numberOfLines = 0
        statusLabel.font = .systemFont(ofSize: 16, weight: .regular)
        let statusLabelHeight = statusLabel.intrinsicHeight(width: viewWidth - 36)
        
        statusIndicator.frame = CGRect(x: 16, y: restaurantNameLabel.frame.maxY + 16, width: statusLabelHeight - 4, height: statusLabelHeight - 4)
        statusLabel.frame = CGRect(x: statusIndicator.frame.maxX + 8, y: statusIndicator.frame.minY, width:  statusLabel.intrinsicContentSize.width, height: statusLabelHeight)
        
        
        // ------------------------------------------------------------------------------------------
        
        let paxImage = UIImageView(image: UIImage(named: "pax2"))
        let paxLabel = UILabel()
        paxLabel.text = "\(reservation.pax)"
        paxLabel.font = .systemFont(ofSize: 18, weight: .regular)
        
        paxImage.frame = CGRect(x: 16, y: statusIndicator.frame.maxY + 16, width: paxLabel.intrinsicContentSize.height, height: paxLabel.intrinsicContentSize.height)
        paxLabel.frame = CGRect(x: paxImage.frame.maxX + 8, y: paxImage.frame.minY, width: paxLabel.intrinsicContentSize.width, height: paxLabel.intrinsicContentSize.height)
        
        let calendarImage = UIImageView(image: UIImage(named: "calendar"))
        let dateLabel = UILabel()
        dateLabel.text = reservation.date
        dateLabel.font = .systemFont(ofSize: 18, weight: .regular)
        
        calendarImage.frame = CGRect(x: paxLabel.frame.maxX + 16, y: paxImage.frame.minY, width: paxImage.frame.width, height: paxImage.frame.height)
        dateLabel.frame = CGRect(x: calendarImage.frame.maxX + 8, y: calendarImage.frame.minY, width: dateLabel.intrinsicContentSize.width, height: dateLabel.intrinsicContentSize.height)
        
        
         // ------------------------------------------------------------------------------------------
        
        
        specialRequestLabel.text = "Sepcial Request:"
        specialRequestLabel.numberOfLines = 1
        specialRequestLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        specialRequestLabel.frame = CGRect(x: 16, y: paxImage.frame.maxY + 16, width: specialRequestLabel.intrinsicContentSize.width, height: reservation.note == nil ? 0 : specialRequestLabel.intrinsicContentSize.height)
        
//        noteLabel.layer.borderWidth = 1
//        noteLabel.layer.borderColor = UIColor.lightGray.cgColor
//        noteLabel.layer.cornerRadius = 8
        noteLabel.text = reservation.note
        noteLabel.numberOfLines = 0
        noteLabel.font = .systemFont(ofSize: 18, weight: .regular)
        noteLabel.frame = CGRect(x: 16, y: specialRequestLabel.frame.maxY + 8, width: viewWidth, height: noteLabel.intrinsicHeight(width: viewWidth))
        
        // ------------------------------------------------------------------------------------------
        
        let manageButton = BlackButton()
        manageButton.configureTitle(title: "Manage Reservation")
        manageButton.translatesAutoresizingMaskIntoConstraints = true
        manageButton.layer.cornerRadius = 4
        manageButton.addTarget(self, action: #selector(managedReservationButtonTapped), for: .touchUpInside)
        
        let requestButton = BlackButton()
        requestButton.configureTitle(title: "Edit Special Request")
        requestButton.translatesAutoresizingMaskIntoConstraints = true
        requestButton.layer.cornerRadius = 4
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
        
        requestButton.frame = CGRect(x: 16, y: noteLabel.frame.maxY + 16, width: requestButton.intrinsicWidth + 32, height: 32)
        manageButton.frame = CGRect(x: 16, y: requestButton.frame.maxY + 8, width: requestButton.intrinsicWidth + 32, height: 32)
        
         // ------------------------------------------------------------------------------------------
        
        let menuContainerView = makeContainerView(imageName: "menu", title: "Browse Menu")
        menuContainerView.frame = CGRect(x: 16, y: manageButton.frame.maxY + 16, width: (viewWidth - 8) / 2 , height: 64)
        
        let directionContainerView = makeContainerView(imageName: "gps", title: "Get Direction")
        directionContainerView.frame = CGRect(x: menuContainerView.frame.maxX + 16, y: menuContainerView.frame.minY, width: (viewWidth - 8) / 2 , height: 64)
        
         // ------------------------------------------------------------------------------------------
        
        
        
        scrollView.addSubview(restaurantNameLabel)
        scrollView.addSubview(statusLabel)
        scrollView.addSubview(statusIndicator)
        scrollView.addSubview(paxImage)
        scrollView.addSubview(paxLabel)
        scrollView.addSubview(calendarImage)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(specialRequestLabel)
        scrollView.addSubview(noteLabel)
        scrollView.addSubview(manageButton)
        scrollView.addSubview(requestButton)
        scrollView.addSubview(menuContainerView)
        scrollView.addSubview(directionContainerView)
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: 2400)
        
        
        
    }
    
    
    private func makeContainerView(imageName: String, title: String) -> UIView {
        
        let containerView = UIView()
        containerView.backgroundColor = scrollView.backgroundColor
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.darkGray.cgColor
        containerView.layer.cornerRadius = 8
        
        
        let imageview = UIImageView(image: UIImage(named: imageName))
        imageview.frame = CGRect(x: 8, y: 8, width: 48, height: 48)
        imageview.contentMode = .scaleAspectFit
        
        let titleView = UILabel()
        titleView.text = title
        titleView.frame = CGRect(x: imageview.frame.maxX + 8, y: imageview.frame.midY - titleView.intrinsicContentSize.height/2, width: titleView.intrinsicContentSize.width, height: titleView.intrinsicContentSize.height)
        
        containerView.addSubview(imageview)
        containerView.addSubview(titleView)
        
        return containerView
        
    }
    
    
    
       private func setupNavigationBar() {
    
           navigationItem.title = "Reservation"
           self.navigationController?.navigationBar.prefersLargeTitles = false
           navigationController?.navigationBar.tintColor = .black
           self.navigationController?.navigationBar.isTranslucent = true
           self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()

       }

    
    @objc
    private func managedReservationButtonTapped() {
        
        
    }
    
    @objc
    private func requestButtonTapped() {
        
        let instructionVC = InstructionsInputViewController()
        instructionVC.delegate = self
        instructionVC.textView.text = reservation.note ?? ""
        let nav = UINavigationController(rootViewController: instructionVC)
        present(nav, animated: true, completion: nil)
        
           
    }
    
    private func heightForText(_ text: String, of font: UIFont) -> CGFloat{

        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()

        return label.frame.height
    }
}


extension ReservationViewController: InstructionInputDelegate {
    
    //MARK: - INPUT DELEGATE
    
    func didInputInstructions(_ instructions: String) {
        
        if instructions != "" {
            
            reservation.note = instructions
            
            for subview in scrollView.subviews {
                subview.removeFromSuperview()
            }
            
            setupScrollViewSubviews()
        }
        
    }
    


}
