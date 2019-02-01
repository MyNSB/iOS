//
//  CalendarView.swift
//  MyNSB
//
//  Created by Hanyuan Li on 24/1/19.
//  Copyright © 2019 Qwerp-Derp. All rights reserved.
//

import UIKit

import RSDayFlow

class CalendarView: RSDFDatePickerView {
    override func dayCellClass() -> AnyClass {
        return CalendarCell.self
    }
    
    override func monthHeaderClass() -> AnyClass {
        return CalendarMonthHeader.self
    }
    
    override func collectionViewClass() -> AnyClass {
        return CalendarCollectionView.self
    }
}
