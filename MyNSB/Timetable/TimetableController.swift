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
    private var todayIsWeekend = false
    // A list of bell times, separated by day - each `Timespan` class denotes the start
    // and end of each period
    private var bellTimes: [[Timespan]]?
    // A list of periods within the timetable, separated by day - each `Period` class contains
    // all the information needed to represent a period (e.g. classroom, teacher name, subject name)
    private var timetable: [[Period]]?
    
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
    private func isUserOnToday() -> Bool {
        return self.userSelectedDay == self.today
    }
    
    /// Checks if the user has their timetable stored locally.
    ///
    /// - Returns: A boolean that indicates whether the user has their timetable stored.
    private func isTimetableStored() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: "bellTimes") != nil && defaults.object(forKey: "timetable") != nil
    }

    // Private functions used internally
    
    // API calls & Promises
    
    /// Fetches a week from the API, either "A" or "B".
    ///
    /// - Returns: A string that indicates the current week - "A" or "B".
    private func fetchWeek() -> Promise<String> {
        return firstly {
            // Get request to week/Get
            Alamofire.request("http://35.189.50.185:8080/api/v1/week/Get")
                .validate()     // Check that request has a valid code
                .responseJSON() // Coerces the response into a JSON format
        }.map { json, response in
            // Response is either "A" or "B"
            let body = JSON(json)["Message"]["Body"]
            return body.stringValue
        }
    }
    
    /// Fetches the day that today corresponds with in the fortnight. Week A Monday is 0,
    /// Week B Friday is 9.
    ///
    /// - Parameter week: The current week, either "A" or "B"
    /// - Returns: A value from 0-9 detailing what day it is in the fortnight
    private func fetchDayGivenWeek(week: String) -> Guarantee<Int> {
        return Guarantee<Int> { completion in
            // Current week: since week A Monday is represented as 0, week B Monday is
            // represented as 5. This integer helps separate the possibility for the
            // current day into two separate weeks
            let weekInt = week == "A" ? 0 : 5
            // Fetch today's date as an integer - Sunday is 1, Saturday is 7
            let weekday = Calendar.current.component(.weekday, from: Date())
            // Returns the day that's going to be displayed, different from `self.today`
            var displayDay = 0

            // If today is on a weekend:
            if weekday == 1 || weekday == 7 {
                self.todayIsWeekend = true
                // The displayed day is set to the following Monday by rotating the week
                displayDay = (weekInt + 5) % 10
            } else {
                // Today is a weekday - since Monday starts at 2, we need to subtract 2
                // and add back on the weekday
                self.today = weekInt + weekday - 2
                // We want to display today
                displayDay = self.today
            }

            // Return the displayed day as completion value in Guarantee
            completion(displayDay)
        }
    }

    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    private func fetchBellTimes() -> Promise<[[Timespan]]> {
        let weekdaysList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/belltimes/Get")
                    .validate()
                    .responseJSON()
        }.map { json, _ in
            var bellTimes: [[Timespan]] = []

            for weekday in 0..<5 {
                let body = JSON(json)["Message"]["Body"][0]
                let weekdayBellTimes = body[weekdaysList[weekday]]

                bellTimes.append(weekdayBellTimes.dictionaryValue.map { key, value in
                    Timespan(name: key, time: value.stringValue)
                }.sorted { first, second in
                    first.start < second.start
                })
            }

            return bellTimes + bellTimes
        }
    }

    private func fetchPeriods(bellTimes: [[Timespan]]) -> Promise<[[Period]]> {
        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/timetable/Get")
                .validate()
                .responseJSON()
        }.map { json, _ in
            let body = JSON(json)["Message"]["Body"][0].arrayValue
            var periods: [[Period]] = []

            for day in 0..<10 {
                let bellTimesForDay = bellTimes[day]
                let periodsForDay = body.filter { item in
                    return item["day"].intValue == day + 1
                }
                
                let unfilteredPeriods = bellTimesForDay.map { (timespan: Timespan) -> Period? in
                    let periodJSON = periodsForDay.first { period in
                        period["period"].stringValue == timespan.name
                    }
                    
                    return timespan.toPeriod(contents: periodJSON)
                }
                
                let filteredPeriods = unfilteredPeriods.compactMap { $0 }
                periods.append(filteredPeriods)
            }

            return periods
        }
    }

    private func loadTimetableData() -> Promise<[[Period]]> {
        return firstly {
            self.fetchBellTimes()
        }.then { (bellTimes: [[Timespan]]) -> Promise<[[Period]]> in
            self.bellTimes = bellTimes
            return self.fetchPeriods(bellTimes: bellTimes)
        }
    }

    private func fetchDay() -> Promise<Int> {
        return firstly {
            self.fetchWeek()
        }.then { week in
            return self.fetchDayGivenWeek(week: week)
        }
    }

    // Saving offline timetable

    private func saveTimetable() {
        let defaults = UserDefaults.standard

        if let bellTimes = self.bellTimes {
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: bellTimes), forKey: "bellTimes")
        }

        if let timetable = self.timetable {
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: timetable), forKey: "timetable")
        }
    }

    private func fetchOfflineTimetable() {
        let defaults = UserDefaults.standard
        self.bellTimes = NSKeyedUnarchiver.unarchiveObject(with: defaults.object(forKey: "bellTimes") as! Data) as! [[Timespan]]?
        self.timetable = NSKeyedUnarchiver.unarchiveObject(with: defaults.object(forKey: "timetable") as! Data) as! [[Period]]?
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
            firstly {
                self.loadTimetableData()
            }.then { (periods: [[Period]]) -> Promise<Int> in
                self.timetable = periods
                return self.fetchDay()
            }.done { day in
                self.saveTimetable()
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

        return timetable[self.userSelectedDay].count
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let period = self.timetable![self.userSelectedDay][indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let cell = self.periods.dequeueReusableCell(withIdentifier: "periodCell", for: indexPath) as! PeriodCell

        let archived = UserDefaults.standard.data(forKey: "timetableColours")!
        let colours = NSKeyedUnarchiver.unarchiveObject(with: archived) as! [String: UIColor]
        let currentColour = colours[period.subject.group]!
        let adjustedTextColour = Subject.textColourIsWhite(colour: currentColour) ? UIColor.white : UIColor.black

        cell.backgroundColor = currentColour

        cell.timeLabel.text = formatter.string(from: period.start)
        cell.timeLabel.textColor = adjustedTextColour
        cell.subjectLabel.text = period.subject.longName
        cell.subjectLabel.textColor = adjustedTextColour

        if !self.todayIsWeekend && self.isUserOnToday() && Date() < period.end {
            cell.countdownLabel.isHidden = false
            cell.countdownLabel.text = self.calculateCountdown(start: period.start)
            cell.countdownLabel.textColor = currentColour

            if currentColour == UIColor.white {
                cell.countdownLabel.backgroundColor = UIColor.lightGray
            } else {
                cell.countdownLabel.backgroundColor = UIColor.white
            }
        } else {
            cell.countdownLabel.isHidden = true
        }

        if period.subject.group == "Recess" || period.subject.group == "Lunch" {
            cell.stackView.isHidden = true
        } else {
            cell.stackView.isHidden = false
            cell.roomLabel.text = period.room!
            cell.roomLabel.textColor = adjustedTextColour
            cell.teacherLabel.text = period.teacher!
            cell.teacherLabel.textColor = adjustedTextColour
        }

        return cell
    }
}
