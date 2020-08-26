//
//  StretchyHeaderLayout.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-07-06.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import UIKit

class StretchyHeaderLayout: UICollectionViewFlowLayout {

    // modify the attributes of the header component
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        layoutAttributes?.forEach({ (attributes) in
            
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                
                guard let collectionView = collectionView else { return }
                
                let yTransition = collectionView.contentOffset.y
                
                if yTransition > 0 { return }
                
                let width = collectionView.frame.width
                
                let height = attributes.frame.height - yTransition
//                print("y \(yTransition)")
                
                attributes.frame = CGRect(x: 0, y: yTransition, width: width, height: height)
                
            }
            
            
        })
        
        
        return layoutAttributes
        
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        //so it calculates the offset everytime colletionview is scrolled
        return true
    }
    
}
