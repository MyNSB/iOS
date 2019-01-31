//
//  EventDayCell.swift
//  MyNSB
//
//  Created by Hanyuan Li on 24/1/19.
//  Copyright © 2019 Qwerp-Derp. All rights reserved.
//

import UIKit

import RSDayFlow

class CalendarCell: RSDFDatePickerDayCell {
    override func dayLabelFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 18.0)!
    }
    
    override func selectedDayLabelFont() -> UIFont {
        return UIFont(name: "Lato-Bold", size: 18.0)!
    }
    
    override func todayLabelFont() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 19.0)!
    }
    
    override func selectedTodayLabelFont() -> UIFont {
        return UIFont(name: "Lato-Bold", size: 18.0)!
    }
    
    override func selfBackgroundColor() -> UIColor {
        return UIColor(red: 40/255.0, green: 41/255.0, blue: 87/255.0, alpha: 1.0)
    }
}
