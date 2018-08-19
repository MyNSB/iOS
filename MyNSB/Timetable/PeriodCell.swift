//
//  PeriodCell.swift
//  MyNSB
//
//  Created by Hanyuan Li on 14/7/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit

class PeriodCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
