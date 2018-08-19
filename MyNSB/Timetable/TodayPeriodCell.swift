//
//  TodayPeriodCell.swift
//  MyNSB
//
//  Created by Hanyuan Li on 19/7/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit

class TodayPeriodCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
