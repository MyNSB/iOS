//
//  RemindersSource.swift
//  MyNSB
//
//  Created by Plisp on 28/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit

class ReminderSource: NSObject, UITableViewDataSource {
    /* stubs */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
        return cell
    }
}
