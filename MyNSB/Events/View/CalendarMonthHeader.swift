//
//  CalendarMonthHeader.swift
//  MyNSB
//
//  Created by Hanyuan Li on 24/1/19.
//  Copyright © 2019 Qwerp-Derp. All rights reserved.
//

import UIKit

import RSDayFlow

class CalendarMonthHeader: RSDFDatePickerMonthHeader {
    override func monthLabelFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 16.0)!
    }
    
    override func monthLabelTextColor() -> UIColor {
        return UIColor.white
    }
}
