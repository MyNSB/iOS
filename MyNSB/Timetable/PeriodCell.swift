//
//  PeriodCell.swift
//  MyNSB
//
//  Created by Hanyuan Li on 19/7/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit

class PeriodCell: UITableViewCell {
    private var period: Period?
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    var controller: TimetableController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func calculateCountdown(start: Date) -> String {
        if Date() < start {
            let secondsUntilStart = Int(DateInterval(start: Date(), end: start).duration)
            
            if secondsUntilStart >= 3600 {
                return "\(secondsUntilStart / 3600)h"
            } else if secondsUntilStart < 3600 && secondsUntilStart > 60 {
                return "\(secondsUntilStart / 60)m"
            } else {
                return "<1m"
            }
        } else {
            return "Now"
        }
    }
    
    private func adjustCountdownLabel(background: UIColor) {
        if !controller!.todayIsWeekend && controller!.isUserOnToday() && Date() < self.period!.end {
            self.countdownLabel.isHidden = false
            self.countdownLabel.text = self.calculateCountdown(start: self.period!.start)
            self.countdownLabel.textColor = background
            
            if background == UIColor.white {
                self.countdownLabel.backgroundColor = UIColor.lightGray
            } else {
                self.countdownLabel.backgroundColor = UIColor.white
            }
        } else {
            self.countdownLabel.isHidden = true
        }
    }
    
    private func adjustInfoLabels(textColour: UIColor) {
        if self.period!.subject.group == "Recess" || self.period!.subject.group == "Lunch" {
            self.stackView.isHidden = true
        } else {
            self.stackView.isHidden = false
            self.roomLabel.text = self.period!.room!
            self.roomLabel.textColor = textColour
            self.teacherLabel.text = self.period!.teacher!
            self.teacherLabel.textColor = textColour
        }
    }
    
    func update(period: Period) {
        self.period = period
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let archived = UserDefaults.standard.data(forKey: "timetableColours")!
        let colours = NSKeyedUnarchiver.unarchiveObject(with: archived) as! [String: UIColor]
        let currentColour = colours[self.period!.subject.group]!
        let adjustedTextColour = Subject.textColourIsWhite(colour: currentColour) ? UIColor.white : UIColor.black
        
        self.backgroundColor = currentColour
        
        self.timeLabel.text = formatter.string(from: period.start)
        self.timeLabel.textColor = adjustedTextColour
        self.subjectLabel.text = period.subject.longName
        self.subjectLabel.textColor = adjustedTextColour
        
        self.adjustCountdownLabel(background: currentColour)
        self.adjustInfoLabels(textColour: adjustedTextColour)
    }
}
