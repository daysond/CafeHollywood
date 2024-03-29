//
//  CustomOption.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-08-10.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import Foundation

class CustomOption {
    
    let mainImageNmae: String
    let mainTitle: String
    var subTitle: String
    let optionType: CustomOptionType
    
    init(mainImageNmae: String, mainTitle:String, subTitle: String, optionType: CustomOptionType) {
        self.mainImageNmae = mainImageNmae
        self.mainTitle = mainTitle
        self.subTitle = subTitle
        self.optionType = optionType
    }
    
}

enum CustomOptionType {
    
    case utensil
    case scheduler
    case payment
    case note
    case pax
    case gift
    
}
