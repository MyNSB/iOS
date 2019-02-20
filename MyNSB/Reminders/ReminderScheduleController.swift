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

import AwaitKit

class ReminderScheduleController: UIViewController {
    var viewingReminder: Reminder?
    var changed = false
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var bodyField: UITextField!
    @IBOutlet weak var deadlinePicker: UIDatePicker!
    
    @IBAction func savePressed(_ sender: UIButton) {
        let newID = viewingReminder?.id ?? UUID().uuidString
        let newReminder = Reminder(title: titleField.text!, body: bodyField?.text, due: deadlinePicker.date, tags: [], id: newID)

        // if the old reminder has been edited, delete the old reminder
        if viewingReminder != nil {
            ReminderList.sharedInstance.removeItem(viewingReminder!)
        }
        // update the reminder
        ReminderList.sharedInstance.addItem(newReminder)
        ReminderList.sharedInstance.scheduleItem(newReminder)
        // pop back to list view
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
