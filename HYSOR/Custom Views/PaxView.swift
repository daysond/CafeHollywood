//
//  PaxView.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-11.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class PaxView: UIView {
    
    private let paxCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        return cv
    }()
    
    private var paxSizes = [Int]()
    
    var paxSize: Int = 2
    var selectedSize = 2
    //    private let doneButton = BlackButton()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        l.text = "Party Size"
        l.numberOfLines = 1
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("pax pax init")
        setupSize()
        setupView()
        
        
    }
    
    private func setupSize() {
        for i in 1...24 {
            paxSizes.append(i)
        }
    }
    
    private func setupView() {
        
        layer.cornerRadius = 8
        
        paxCollectionView.delegate = self
        paxCollectionView.dataSource = self
        paxCollectionView.register(PaxSizeCollectionViewCell.self, forCellWithReuseIdentifier: PaxSizeCollectionViewCell.identifier)
        paxCollectionView.alwaysBounceVertical = true
        paxCollectionView.showsHorizontalScrollIndicator = false
        paxCollectionView.alwaysBounceVertical = false
        paxCollectionView.allowsMultipleSelection = false
        let indexPath = IndexPath(item: 1, section: 0)
        paxCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
        addSubview(paxCollectionView)
        
        addSubview(titleLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        paxCollectionView.collectionViewLayout = layout
        
        //        doneButton.configureTitle(title: "Done")
        //        doneButton.layer.cornerRadius = 8
        //        addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            
            paxCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            paxCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            paxCollectionView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            paxCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            
        ])
        
    }
    
    
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

extension PaxView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paxSizes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaxSizeCollectionViewCell.identifier, for: indexPath) as? PaxSizeCollectionViewCell {
            let size = paxSizes[indexPath.item]
            cell.configureCellWith(size: size)
            
            if indexPath.item == selectedSize - 1 {
                cell.contentView.backgroundColor = .lightGray
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let size = paxSizes[indexPath.item]
        selectedSize = size
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .lightGray
        paxSize = size
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let size = paxSizes[indexPath.item]
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .black
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 48, height:  48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}
