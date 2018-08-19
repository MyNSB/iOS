//
//  EventCell.swift
//  MyNSB
//
//  Created by Hanyuan Li on 22/7/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
