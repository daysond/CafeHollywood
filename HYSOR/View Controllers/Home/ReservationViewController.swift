//
//  ReservationViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-11.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit
import MapKit

class ReservationViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    
    private var viewWidth: CGFloat = 0
    
    private var menuLauncher: SlideInMenuLauncher?
    
    private  var scheduelerView: SchedulerView?
    private  var paxView: PaxView?
    
    private let paxLabel = UILabel()
    private let dateLabel = UILabel()
    let reservation: Reservation
    
    var infoText = "dinfo text here dsa jsadkldjlaskd jalsdjlasdlalslvjlds howei sugldjs hdslj ldfshv wir gfhdkls jflawd ;gds dfklcaspw[ gotidslk lasf"
    
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
        navigationController?.navigationBar.isHidden = false
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
        
        paxLabel.text = "\(reservation.pax)"
        paxLabel.font = .systemFont(ofSize: 18, weight: .regular)
        
        paxImage.frame = CGRect(x: 16, y: statusIndicator.frame.maxY + 16, width: paxLabel.intrinsicContentSize.height, height: paxLabel.intrinsicContentSize.height)
        paxLabel.frame = CGRect(x: paxImage.frame.maxX + 8, y: paxImage.frame.minY, width: paxLabel.intrinsicContentSize.width, height: paxLabel.intrinsicContentSize.height)
        
        let calendarImage = UIImageView(image: UIImage(named: "calendar"))

        dateLabel.text = reservation.date
        dateLabel.font = .systemFont(ofSize: 18, weight: .regular)
        
        calendarImage.frame = CGRect(x: paxLabel.frame.maxX + 16, y: paxImage.frame.minY, width: paxImage.frame.width, height: paxImage.frame.height)
        dateLabel.frame = CGRect(x: calendarImage.frame.maxX + 8, y: calendarImage.frame.minY, width: viewWidth - calendarImage.frame.maxX - 8, height: dateLabel.intrinsicContentSize.height)
        
        
        // ------------------------------------------------------------------------------------------
        let specialRequestLabel =  makeTitleLabel(text: "Sepcial Request:")
        specialRequestLabel.frame = CGRect(x: 16, y: paxImage.frame.maxY + 16, width: specialRequestLabel.intrinsicContentSize.width, height: reservation.note == nil ? 0 : specialRequestLabel.intrinsicContentSize.height)
        
        let noteLabel =  makeDetailLabel(text: reservation.note)
        noteLabel.frame = CGRect(x: 16, y: specialRequestLabel.frame.maxY + 8, width: viewWidth, height: noteLabel.intrinsicHeight(width: viewWidth))
        
        // ------------------------------------------------------------------------------------------
        
        let manageButton = BlackButton()
        manageButton.configureTitle(title: "Manage Reservation")
        manageButton.translatesAutoresizingMaskIntoConstraints = true
        manageButton.layer.cornerRadius = 4
        manageButton.addTarget(self, action: #selector(managedReservationButtonTapped), for: .touchUpInside)
        
        let requestButton = BlackButton()
        requestButton.configureTitle(title: reservation.note == nil ? "Add Special Request" : "Edit Special Request")
        requestButton.translatesAutoresizingMaskIntoConstraints = true
        requestButton.layer.cornerRadius = 4
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
        
        requestButton.frame = CGRect(x: 16, y: noteLabel.frame.maxY + 16, width: requestButton.intrinsicWidth + 32, height: 32)
        manageButton.frame = CGRect(x: 16, y: requestButton.frame.maxY + 8, width: requestButton.intrinsicWidth + 32, height: 32)
        
        // ------------------------------------------------------------------------------------------
        
        let menuContainerView = makeContainerView(imageName: "menu", title: "Browse Menu")
        menuContainerView.frame = CGRect(x: 16, y: manageButton.frame.maxY + 16, width: (viewWidth - 8) / 2 , height: 64)
        menuContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(browseMenuTapped)))
        
        let directionContainerView = makeContainerView(imageName: "gps", title: "Get Direction")
        directionContainerView.frame = CGRect(x: menuContainerView.frame.maxX + 16, y: menuContainerView.frame.minY, width: (viewWidth - 8) / 2 , height: 64)
        directionContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getDirectionTapped)))
        
        
        // ------------------------------------------------------------------------------------------
        let infoTitleLabel = makeTitleLabel(text: "Restaurant information")
        infoTitleLabel.frame = CGRect(x: 16, y: menuContainerView.frame.maxY + 16, width: infoTitleLabel.intrinsicContentSize.width, height: infoTitleLabel.intrinsicContentSize.height)
        
        let infoTextLabel = makeDetailLabel(text: infoText)
        infoTextLabel.frame = CGRect(x: 16, y: infoTitleLabel.frame.maxY + 8, width: viewWidth, height: infoTextLabel.intrinsicHeight(width: viewWidth))
        
        let phoneTitleLabel = makeTitleLabel(text: "Phone number")
        phoneTitleLabel.frame = CGRect(x: 16, y: infoTextLabel.frame.maxY + 16, width: phoneTitleLabel.intrinsicContentSize.width, height: phoneTitleLabel.intrinsicContentSize.height)
        
        let numberLabel = makeDetailLabel(text: "905-477-8877")
        numberLabel.textColor = .systemBlue
        numberLabel.frame = CGRect(x: 16, y: phoneTitleLabel.frame.maxY + 8, width: numberLabel.intrinsicContentSize.width, height: numberLabel.intrinsicHeight(width: viewWidth))
        numberLabel.isUserInteractionEnabled = true
        numberLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(makePhoneCall)))
        
        let addressTitleLabel = makeTitleLabel(text: "Address")
        addressTitleLabel.frame = CGRect(x: 16, y: numberLabel.frame.maxY + 16, width: addressTitleLabel.intrinsicContentSize.width, height: addressTitleLabel.intrinsicContentSize.height)
        
        let addressLabel = makeDetailLabel(text: "7240 Kennedy Rd, Markham, ON L3R 7P2")
        addressLabel.frame = CGRect(x: 16, y: addressTitleLabel.frame.maxY + 8, width: addressLabel.intrinsicContentSize.width, height: addressLabel.intrinsicHeight(width: viewWidth))
        
        let mapView = MKMapView(frame: CGRect(x: 16, y: addressLabel.frame.maxY + 16, width: viewWidth, height: 240))
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let location = CLLocationCoordinate2D(latitude: 43.832102, longitude: -79.306318)
        let region = MKCoordinateRegion(center: location, span: span)
        let anno = MKPointAnnotation()
        anno.coordinate = location
        anno.title = "Cafe Hollywood"
        mapView.addAnnotation(anno)
        mapView.delegate = self
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = true
        
        mapView.setRegion(region, animated: false)
        
        let cancelButton = BlackButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = true
        cancelButton.configureTitle(title: "Cancel Reservation")
        cancelButton.layer.cornerRadius = 4
        //        cancelButton.layer.borderWidth = 1
        //        cancelButton.layer.borderColor = UIColor.black.cgColor
        cancelButton.frame = CGRect(x: 16, y: mapView.frame.maxY + 16, width: viewWidth, height: Constants.kOrderButtonHeightConstant)
        
        
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
        scrollView.addSubview(infoTitleLabel)
        scrollView.addSubview(infoTextLabel)
        scrollView.addSubview(phoneTitleLabel)
        scrollView.addSubview(numberLabel)
        scrollView.addSubview(addressTitleLabel)
        scrollView.addSubview(addressLabel)
        scrollView.addSubview(mapView)
        scrollView.addSubview(cancelButton)
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: cancelButton.frame.maxY + 16 )
        
        
        
    }
    
    //MARK: - HELPERS
    
    
    private func makeContainerView(imageName: String, title: String) -> UIView {
        
        let containerView = UIView()
        containerView.backgroundColor = scrollView.backgroundColor
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.darkGray.cgColor
        containerView.layer.cornerRadius = 8
        containerView.isUserInteractionEnabled = true
        
        
        let imageview = UIImageView(image: UIImage(named: imageName))
        imageview.frame = CGRect(x: 12, y: 12, width: 40, height: 40)
        imageview.contentMode = .scaleAspectFit
        
        let titleView = UILabel()
        titleView.text = title
        titleView.frame = CGRect(x: imageview.frame.maxX + 8, y: imageview.frame.midY - titleView.intrinsicContentSize.height/2, width: titleView.intrinsicContentSize.width, height: titleView.intrinsicContentSize.height)
        
        containerView.addSubview(imageview)
        containerView.addSubview(titleView)
        
        return containerView
        
    }
    
    private func makeTitleLabel(text: String) -> UILabel {
        
        let label =  UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    private func makeDetailLabel(text: String?) -> UILabel {
        
        let label =  UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }
    
    
    private func setupNavigationBar() {
        
        navigationItem.title = "Reservation"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        
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
    
    private func launchMenu(view: UIView, height: CGFloat) {
        
        let blackView = UIView()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tapGes)
        blackView.isUserInteractionEnabled = true
        
        let menuLauncher = SlideInMenuLauncher(blackView: blackView, menuView: view, menuHeight: height)
        self.menuLauncher = menuLauncher
        menuLauncher.showMenu()
        
    }
    
    //MARK: - SELECTORS
    
    
    @objc
    private func managedReservationButtonTapped() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Modify Reservation", style: .default, handler: { (_) in
            let width = self.view.frame.width
            let paxView = PaxView(frame: CGRect(x: 0, y: 0, width: width, height: 120))
            let schedulerView = SchedulerView(frame: CGRect(x: 0, y: 120, width: width, height: 300))
            
            let containerView = UIView()
            containerView.backgroundColor = .white
            containerView.layer.cornerRadius = 8
            containerView.addSubview(paxView)
            containerView.addSubview(schedulerView)
            
            self.scheduelerView = schedulerView
            self.paxView = paxView
            paxView.selectedSize = self.reservation.pax
            
            schedulerView.donebutton.addTarget(self, action: #selector(self.updateReservation), for: .touchUpInside)
            
            self.launchMenu(view: containerView, height: 420)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel Reservation", style: .destructive, handler: { (_) in
            
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
          
        }))
     

        self.present(alert, animated: true)
        
        
    }
    
    @objc private func updateReservation() {
        
        let date = self.scheduelerView!.selectedDate
        let pax = self.paxView!.paxSize
        reservation.date = date
        reservation.pax = pax
        paxLabel.text = "\(pax)"
        dateLabel.text = date
        menuLauncher?.dismissMenu()
        
    }
    
    @objc
    private func requestButtonTapped() {
        
        let instructionVC = InstructionsInputViewController()
        instructionVC.delegate = self
        instructionVC.textView.text = reservation.note ?? ""
        let nav = UINavigationController(rootViewController: instructionVC)
        present(nav, animated: true, completion: nil)
        
    }
    
    @objc
    private func browseMenuTapped() {
        self.navigationController?.popViewController(animated: true)
        self.tabBarController?.selectedIndex = 1
         print("brose menu")
     }
    
    @objc
    private func getDirectionTapped() {
  
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { (_) in
            let url = URL(string:"https://www.google.ca/maps/place/Cafe+Hollywood/@43.8326544,-79.3001964,16.26z/data=!4m5!3m4!1s0x89d4d411ef739181:0xe9b41e1622136cbb!8m2!3d43.832114!4d-79.3062821")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { (_) in
            let url = URL(string:"https://maps.apple.com/?address=7240%20Kennedy%20Rd,%20Markham%20ON%20L3R%207P2,%20Canada&auid=738439207396303396&ll=43.832102,-79.306318&lsp=9902&q=Cafe%20Hollywood&_ext=ChgKBAgEEGIKBAgFEAMKBAgGEBQKBAgKEAASJikWjWsj7+lFQDH+mV26ANRTwDmUYpF/FetFQEGOfEKzNNNTwFAE")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            print("cancel")
        }))
     

        self.present(alert, animated: true)
        
        
     }
    
    @objc private func makePhoneCall() {
        
        guard let url = URL(string: "tel://9054778877"),
            UIApplication.shared.canOpenURL(url) else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    @objc private func dismissMenu() {
        
        menuLauncher?.dismissMenu()
        
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

extension ReservationViewController: MKMapViewDelegate {
    
    //    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //
    //        let annotation = mapView.dequeueReusableAnnotationView(withIdentifier: "anno")
    //        annotation?.canShowCallout = false
    //
    //
    //
    //    }
    
    
}
