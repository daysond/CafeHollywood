//
//  ReservationViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-11.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class ReservationViewController: UIViewController {
    
    internal let optionsTableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .singleLine
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .white
        tb.allowsSelection = false
        tb.register(CheckoutOptionsTableViewCell.self, forCellReuseIdentifier: CheckoutOptionsTableViewCell.identifier)
        return tb
    }()

    internal var menuLauncher: SlideInMenuLauncher?
    
    internal var options: [CustomOption] = []
    
    internal weak var scheduelerView: SchedulerView?
    
     internal let confirmButton = BlackButton()
    
    internal let kCellHeightConstant: CGFloat = 80.0
    internal let kChangeButtonWidth: CGFloat = 88.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupOptions()
    }
    

     private func setupOptions() {
         
         let pax = CustomOption(mainImageNmae: "pax", mainTitle: "PARTY SIZE", subTitle: "2", subImageName: nil, optionType: .pax)
         let reservationTime = CustomOption(mainImageNmae: "clock", mainTitle: "BOOKING TIME", subTitle: "Now", subImageName: nil, optionType: .scheduler)
         let note = CustomOption(mainImageNmae: "notes", mainTitle: "NOTE", subTitle: "", subImageName: nil, optionType: .note)
         
         options = [pax, reservationTime, note]
    
     }
    
    private func setupView() {
        
        setupTableView()
        setupNavigationBar()
        view.backgroundColor = .white
        view.addSubview(confirmButton)
        confirmButton.configureTitle(title: "Confirm Reservation")
        confirmButton.addTarget(self, action: #selector(confirmReservation), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            optionsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionsTableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor),
            
            confirmButton.heightAnchor.constraint(equalToConstant: Constants.kOrderButtonHeightConstant),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            confirmButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -0),
        ])
        
        
        
    }
    
       private func setupNavigationBar() {
    
           navigationItem.title = "Summary"
           self.navigationController?.navigationBar.prefersLargeTitles = true
           navigationController?.navigationBar.tintColor = .black
           self.navigationController?.navigationBar.isTranslucent = true
           self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()

       }
    
    private func setupTableView() {
        
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        //        optionsTableView.contentInsetAdjustmentBehavior = .never
        view.addSubview(optionsTableView)

    }
    
    @objc
    private func confirmReservation() {
        
        
    }
    
    private func heightForCellLabel(text: String) -> CGFloat{
        
        let cell = CheckoutOptionsTableViewCell()
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: optionsTableView.frame.width - kChangeButtonWidth, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = cell.rowSubLabel.font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height - 18
    }
}

extension ReservationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CheckoutOptionsTableViewCell.identifier, for: indexPath) as? CheckoutOptionsTableViewCell {
            cell.indexPath = indexPath
            cell.delegate = self
            cell.configureCell(with: options[indexPath.row])
            return cell
            
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kCellHeightConstant + heightForCellLabel(text: options[indexPath.row].subTitle)
    }
    
    
    
}

extension ReservationViewController: CheckoutOptionCellDelegate, InstructionInputDelegate {


    func didTapChangeButton(at indexPath: IndexPath) {

        let option = options[indexPath.row]

        switch option.optionType {
            
        case .pax:
            option.subTitle =  option.subTitle == "Yes please!" ? "No thanks!" : "Yes please!"

        case .scheduler:
            handleScheduler()

        case .note:
            let instructionVC = InstructionsInputViewController()
            instructionVC.delegate = self
            instructionVC.textView.text = option.subTitle
            let nav = UINavigationController(rootViewController: instructionVC)
            present(nav, animated: true, completion: nil)
        default:
            return
        }

    }
    
    private func handleScheduler() {
        let schedulerView = SchedulerView()
        self.scheduelerView = schedulerView
        schedulerView.donebutton.addTarget(self, action: #selector(schedulerViewDismiss), for: .touchUpInside)
        launchMenu(view: schedulerView, height: 300)
        
    }
    
    @objc func schedulerViewDismiss() {
        let date = self.scheduelerView?.selectedDate ?? "Now"
        updateOptionOfType(.scheduler, with: date)
        menuLauncher?.dismissMenu()
    }

    @objc func dismissMenu() {
        menuLauncher?.dismissMenu()
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
    
    private func updateOptionOfType(_ type: CustomOptionType, with text: String) {
        
        for (index,option) in options.enumerated() {
            if option.optionType == type {
                option.subTitle = text
                optionsTableView.beginUpdates()
                optionsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                optionsTableView.endUpdates()
                break
            }
        }
    }
    
    //MARK: - INPUT DELEGATE
    
    func didInputInstructions(_ instructions: String) {
        
        updateOptionOfType(.note, with: instructions)

    }
    


}
