//
//  SettingsController.swift
//  MyNSB
//
//  Created by Hanyuan Li on 17/6/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import AwaitKit

class SettingsController: UITableViewController {
    @IBOutlet weak var automaticUpdatesSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticUpdatesSwitch.isOn = UserDefaults.standard.bool(forKey: "automaticUpdatesFlag")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 0) {
            return 2
        } else {
            return 1
        }
    }
    
    private func logout() -> Promise<Void> {
        return async {
            try await(MyNSBRequest.post(path: "/user/logout"))
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            async {
                do {
                    try await(self.logout())
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "logoutSegue", sender: self)
                        self.navigationController!.navigationBar.isHidden = true
                    }
                } catch let error as MyNSBError {
                    MyNSBErrorController.error(self, error: error)
                }
            }
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func toggleAutomaticUpdates(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "automaticUpdatesFlag")
    }
}
