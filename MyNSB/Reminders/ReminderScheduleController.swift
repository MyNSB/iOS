//
//  ReminderScheduleController.swift
//  test
//
//  Created by Plisp on 28/12/18.
//  Copyright © 2018 Plisp. All rights reserved.
//

import UIKit
import UserNotifications
import NotificationCenter

class ReminderScheduleController: UIViewController {
    var viewingReminder: Reminder?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var bodyField: UITextField!
    @IBOutlet weak var deadlinePicker: UIDatePicker!
    
    @IBAction func savePressed(_ sender: UIButton) {
        // if not viewing a previously created reminder
        if viewingReminder != nil {
            viewingReminder = Reminder(title: titleField.text!, body: bodyField?.text, due: deadlinePicker.date, repeats: false, UUID: viewingReminder!.UUID)
            // update the reminder with corresponding UUID (on disk)
            ReminderList.setItem(viewingReminder!)
            ReminderList.scheduleItem(viewingReminder!)
        } else {
            viewingReminder = Reminder(title: titleField.text!, body: bodyField?.text, due: deadlinePicker.date, repeats: false, UUID: UUID().uuidString)
            ReminderList.addItem(viewingReminder!)
            ReminderList.scheduleItem(viewingReminder!)
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewingReminder != nil {
            print("editing existing reminder called \(viewingReminder!.title)")
            titleField.text = viewingReminder!.title
            bodyField.text = viewingReminder!.body ?? ""
            deadlinePicker.date = viewingReminder!.due
        }
    }
}
