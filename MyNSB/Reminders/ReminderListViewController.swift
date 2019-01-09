//
//  ReminderListViewController.swift
//  test
//
//  Created by Plisp on 1/1/19.
//  Copyright © 2019 Plisp. All rights reserved.
//

import UIKit

class ReminderListViewController: UITableViewController {
    var reminderList: [Reminder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ReminderListViewController.refreshList), name: NSNotification.Name(rawValue: "reminderListShouldRefresh"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshList()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)
        let reminder = reminderList[(indexPath as NSIndexPath).row] as Reminder
        cell.textLabel?.text = reminder.title as String
        if (reminder.overdue) {
            cell.detailTextLabel?.textColor = UIColor.orange
        } else {
            cell.detailTextLabel?.textColor = UIColor.black
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "'Scheduled for' h:mm a 'on' MMM dd"
        cell.detailTextLabel?.text = dateFormatter.string(from: reminder.due as Date)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let viewTitle = NSLocalizedString("View", comment: "view/edit")
        let viewAction = UIContextualAction(style: .normal, title: viewTitle) { (action, view, completion) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReminderScheduleID") as! ReminderScheduleController
            vc.viewingReminder = self.reminderList[(indexPath as NSIndexPath).row]
            self.navigationController!.pushViewController(vc, animated: true)
            completion(true)
        }
        viewAction.backgroundColor = .green
        
        let completeTitle = NSLocalizedString("Complete", comment: "delete selected reminder")
        let completeAction = UIContextualAction(style: .destructive, title: completeTitle) { (action, view, completion) in
            let item = self.reminderList.remove(at: (indexPath as NSIndexPath).row)
            ReminderList.sharedInstance.removeItem(item)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.navigationItem.rightBarButtonItem!.isEnabled = true // less than 64 reminders now
            completion(true)
        }
        completeAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [viewAction, completeAction])
        return configuration
    }
    
    // disable default edit action
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    @objc func refreshList() {
        self.reminderList = ReminderList.sharedInstance.getReminders()
        if (reminderList.count >= 64) { // apple allows 64 local notifications at maximum
            print("too many items!")
            self.navigationItem.rightBarButtonItem!.isEnabled = false
        }
        tableView.reloadData()
    }
}
