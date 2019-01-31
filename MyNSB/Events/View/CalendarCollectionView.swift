//
//  CalendarCollectionView.swift
//  MyNSB
//
//  Created by Hanyuan Li on 24/1/19.
//  Copyright © 2019 Qwerp-Derp. All rights reserved.
//

import UIKit

import RSDayFlow

class CalendarCollectionView: RSDFDatePickerCollectionView {
    override func selfBackgroundColor() -> UIColor {
        return UIColor(red: 40/255.0, green: 41/255.0, blue: 87/255.0, alpha: 1.0)
    }
    
    override func cellForItem(at indexPath: IndexPath) -> CalendarCell? {
        return super.cellForItem(at: indexPath) as? CalendarCell
    }
}
