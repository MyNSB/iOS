//
//  ReminderViewController.swift
//  MyNSB
//
//  Created by Plisp on 6/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit

class ReminderController : UIViewController {
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: view.bounds)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        view.addSubview(tableView)
    }
}
