//
//  TimetableController.swift
//  MyNSB
//
//  Created by Hanyuan Li on 16/1/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON

class TimetableController: UIViewController {
    // The day that the user is currently on, from 0 to 9 (0 being Week A Monday, 9 being Week B Friday)
    private var userSelectedDay = 0
    // The date today, expressed from 0 to 9 (see above)
    private var today = 0
    // Flag for whether today is a weekend or not
    var todayIsWeekend = false
    // A list of periods within the timetable, separated by day - each `Period` class contains
    // all the information needed to represent a period (e.g. classroom, teacher name, subject name)
    private var timetable: Timetable?
    
    // Mark: Properties
    
    @IBOutlet weak var currentWeek: UISegmentedControl!
    @IBOutlet weak var currentDay: UILabel!
    @IBOutlet weak var previousDay: UIButton!
    @IBOutlet weak var nextDay: UIButton!
    @IBOutlet weak var periods: UITableView!

    // Flags
    
    /// Checks if a user's on the weekday page for today. For example, if it
    /// is currently a Wednesday in Week A, this function returns `true` if
    /// the user is currently on Wednesday, Week A in the timetable.
    ///
    /// - Returns: A boolean that describes if the user is on the weekday page for today.
    func isUserOnToday() -> Bool {
        return self.userSelectedDay == self.today
    }
    
    /// Checks if the user has their timetable stored locally.
    ///
    /// - Returns: A boolean that indicates whether the user has their timetable stored.
    func isTimetableStored() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: "timetable") != nil
    }
    
    // API calls & Promises
    
    /// Fetches the day that today corresponds with in the fortnight. Week A Monday is 0,
    /// Week B Friday is 9.
    ///
    /// - Parameter week: The current week, either "A" or "B"
    /// - Returns: A value from 0-9 detailing what day it is in the fortnight
    private func fetchDayGivenWeek(week: String, day: Int) -> Int {
        // Current week: since week A Monday is represented as 0, week B Monday is
        // represented as 5. This integer helps separate the possibility for the
        // current day into two separate weeks
        let weekInt = week == "A" ? 0 : 5
        // Returns the day that's going to be displayed, different from `self.today`
        var displayDay = 0
        
        // If today is on a weekend:
        if self.todayIsWeekend {
            // The displayed day is set to the following Monday by rotating the week
            displayDay = (weekInt + 5) % 10
        }
        
        // Return the displayed day
        return displayDay
    }

    private func loadTimetableData() -> Promise<Timetable> {
        return firstly {
            TimetableAPI.bellTimes()
        }.then { bellTimes in
            return TimetableAPI.timetable(bellTimes: bellTimes)
        }
    }

    private func fetchDay() -> Promise<Int> {
        return firstly {
            TimetableAPI.week()
        }.map { week in
            let day = Calendar.current.component(.weekday, from: Date())
            
            if day == 1 || day == 7 {
                self.todayIsWeekend = true
            }
            
            return self.fetchDayGivenWeek(week: week, day: day)
        }
    }

    // Saving offline timetable

    private func saveTimetable() {
        let defaults = UserDefaults.standard

        if let timetable = self.timetable {
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: timetable), forKey: "timetable")
        }
    }

    private func fetchOfflineTimetable() {
        let defaults = UserDefaults.standard
        self.timetable = NSKeyedUnarchiver.unarchiveObject(with: defaults.object(forKey: "timetable") as! Data) as! Timetable?
    }
    
    // Moving the view to the selected day

    private func moveViewToSelectedDay() {
        let weekdaysList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        let weekday = self.userSelectedDay % 5
        let week = (self.userSelectedDay - weekday) / 5

        self.currentWeek.selectedSegmentIndex = week
        self.currentDay.text = weekdaysList[weekday]

        self.periods.reloadData()
    }
    
    // Loading the timetable overall

    private func loadTimetable() {
        let connected = Connection.isConnected

        if connected && UserDefaults.standard.bool(forKey: "automaticUpdatesFlag") {
            let timetable: Promise<Timetable> = self.loadTimetableData()
            let day: Promise<Int> = self.fetchDay()
            
            when(fulfilled: timetable, day).done { (timetable, day) in
                self.timetable = timetable
                self.saveTimetable()
                
                self.today = day
                self.userSelectedDay = day
                self.moveViewToSelectedDay()
            }.catch { error in
                MyNSBErrorController.error(self, error: MyNSBError.generic(error as NSError))
            }
        } else if self.isTimetableStored() {
            self.fetchOfflineTimetable()
            self.moveViewToSelectedDay()
        } else {
            MyNSBErrorController.error(self, error: MyNSBError.connection)
        }
    }
}

// Methods exposed to public
extension TimetableController {
    @objc private func updateTimetable() {
        firstly {
            self.loadTimetableData()
        }.done { periods in
            self.timetable = periods
        }.catch { error in
            MyNSBErrorController.error(self, error: MyNSBError.generic(error as NSError))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let updateTimetableButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(self.updateTimetable))
        self.navigationItem.rightBarButtonItem = updateTimetableButton
        
        self.previousDay.tintColor = self.view.tintColor
        self.nextDay.tintColor = self.view.tintColor
        
        self.periods.delegate = self
        self.periods.dataSource = self
        
        self.loadTimetable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: Actions
    
    @IBAction func toggleWeek(_ sender: Any) {
        let weekday = self.userSelectedDay % 5
        self.userSelectedDay = (self.currentWeek.selectedSegmentIndex * 5) + weekday
        self.moveViewToSelectedDay()
    }
    
    @IBAction func clickPreviousDay(_ sender: Any) {
        self.userSelectedDay = (self.userSelectedDay + 9) % 10
        self.moveViewToSelectedDay()
    }
    
    @IBAction func clickNextDay(_ sender: Any) {
        self.userSelectedDay = (self.userSelectedDay + 1) % 10
        self.moveViewToSelectedDay()
    }
}

// Extension on TimetableController for UITableViewController overloads
extension TimetableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let timetable = self.timetable else {
            return 0
        }

        return timetable.get(day: self.userSelectedDay).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let period = self.timetable!.get(day: self.userSelectedDay)[indexPath.row]

        let cell = self.periods.dequeueReusableCell(withIdentifier: "periodCell", for: indexPath) as! PeriodCell
        cell.controller = self
        cell.update(period: period)

        return cell
    }
}
