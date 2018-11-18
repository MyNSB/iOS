//
//  TimetableColoursController.swift
//  MyNSB
//
//  Created by Hanyuan Li on 2/9/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import iOS_Color_Picker

class TimetableColoursController: UITableViewController {
    private var colours = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.data(forKey: "timetableColours")!) as! [String: UIColor]
    private var currentSubject = "Default"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.colours.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timetableColourCell", for: indexPath)
        let subjectName = Constants.Timetable.subjects[indexPath.row]
        let colour = self.colours[subjectName]
        
        cell.textLabel?.text = subjectName
        cell.textLabel?.textColor = Subject.textColourIsWhite(colour: colour!) ? UIColor.white : UIColor.black
        cell.backgroundColor = colour

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subjectName = Constants.Timetable.subjects[indexPath.row]
        self.currentSubject = subjectName
        
        let colourPicker = FCColorPickerViewController()
        colourPicker.backgroundColor = UIColor.white
        colourPicker.color = self.colours[subjectName]
        colourPicker.delegate = self
        
        self.present(colourPicker, animated: true, completion: nil)
    }

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

}

extension TimetableColoursController: FCColorPickerViewControllerDelegate {
    func colorPickerViewController(_ colorPicker: FCColorPickerViewController, didSelect color: UIColor) {
        self.colours[self.currentSubject] = color
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self.colours), forKey: "timetableColours")
        
        self.dismiss(animated: true, completion: nil)
        self.tableView.reloadData()
    }
    
    func colorPickerViewControllerDidCancel(_ colorPicker: FCColorPickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
