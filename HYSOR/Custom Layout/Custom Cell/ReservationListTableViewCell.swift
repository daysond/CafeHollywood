//
//  ReservationListTableViewCell.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-09-03.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class ReservationListTableViewCell: UITableViewCell {

    private let statusIndicator : UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
        
    }()
    
    private let paxImageView: UIImageView = {
       let iv = UIImageView(image: UIImage(named: "pax2"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let calendarImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "calendar"))
         iv.translatesAutoresizingMaskIntoConstraints = false
         iv.contentMode = .scaleAspectFit
         return iv
     }()
    
    private let paxLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
        
    }()
    
    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
        
    }()
    
    static var identifier: String {
        return String(describing: self)
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        paxLabel.font = .systemFont(ofSize: 18, weight: .regular)
        dateLabel.font = .systemFont(ofSize: 18, weight: .regular)
        
        let containerview = UIView()
        containerview.backgroundColor = .offWhite
        containerview.translatesAutoresizingMaskIntoConstraints = false
        containerview.clipsToBounds = true
        containerview.layer.cornerRadius = 8
        containerview.layer.borderWidth = 2
        containerview.layer.borderColor = UIColor.darkGray.cgColor
        
        contentView.addSubview(containerview)
        
        containerview.addSubview(statusIndicator)
        containerview.addSubview(statusLabel)
        containerview.addSubview(paxLabel)
        containerview.addSubview(paxImageView)
        containerview.addSubview(dateLabel)
        containerview.addSubview(calendarImage)
        
        let size: CGFloat = 18
        
        NSLayoutConstraint.activate([
        
            containerview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            paxLabel.topAnchor.constraint(equalTo: containerview.topAnchor, constant: 8),
            paxLabel.leadingAnchor.constraint(equalTo: paxImageView.trailingAnchor, constant: 16),
            
            paxImageView.leadingAnchor.constraint(equalTo: containerview.leadingAnchor, constant: 16),
            paxImageView.widthAnchor.constraint(equalToConstant: size),
            paxImageView.heightAnchor.constraint(equalToConstant: size),
            paxImageView.centerYAnchor.constraint(equalTo: paxLabel.centerYAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: paxImageView.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: paxLabel.leadingAnchor),
            
            calendarImage.leadingAnchor.constraint(equalTo: paxImageView.leadingAnchor),
            calendarImage.widthAnchor.constraint(equalTo: paxImageView.heightAnchor),
            calendarImage.heightAnchor.constraint(equalTo: paxImageView.widthAnchor),
            calendarImage.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: paxLabel.leadingAnchor),
            
            statusIndicator.leadingAnchor.constraint(equalTo: paxImageView.leadingAnchor),
            statusIndicator.widthAnchor.constraint(equalTo: paxImageView.heightAnchor),
            statusIndicator.heightAnchor.constraint(equalTo: paxImageView.widthAnchor),
            statusIndicator.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            

        ])
        
        
    }
    
    func configureCellWith(_ reservation: Reservation) {
        
        statusIndicator.image = UIImage(named: reservation.status == .confirmed ? "completed" : "cancel")
        statusLabel.text = reservation.status == .confirmed ? "Reservation Confirmed!" : "Reservation Canceled."
        paxLabel.text = "\(reservation.pax)"
        dateLabel.text = reservation.date
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
