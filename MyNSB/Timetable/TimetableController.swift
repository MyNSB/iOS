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
    private var today: Int? = 0
    // A list of bell times, separated by day - each `Timespan` class denotes the start
    // and end of each period
    private var bellTimes: [[Timespan]]? = nil
    // A list of periods within the timetable, separated by day - each `Period` class contains
    // all the information needed to represent a period (e.g. classroom, teacher name, subject name)
    private var timetable: [[Period]]? = nil
    
    // Mark: Properties
    
    @IBOutlet weak var currentWeek: UISegmentedControl!
    @IBOutlet weak var currentDay: UILabel!
    @IBOutlet weak var previousDay: UIButton!
    @IBOutlet weak var nextDay: UIButton!
    @IBOutlet weak var periods: UITableView!

    // Checks if user is on today's respective page
    private func userOnToday() -> Bool {
        return self.userSelectedDay == self.today
    }

    // Fetch the current week (A or B) from the API
    private func fetchWeek() -> Promise<String> {
        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/week/Get")
                .validate()
                .responseJSON()
        }.map { json, response in
            return JSON(json)["Message"]["Body"].stringValue
        }
    }

    // Given the current week, convert the current day into a valid integer from
    // 0 to 9, which is then assigned to `self.today`
    private func fetchDay(week: String) -> Guarantee<Int> {
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
                // We don't want any date to contain times since we don't have classes
                // today, so self.today is nil
                self.today = nil
                // The displayed day is set to the following Monday by rotating the week
                displayDay = (weekInt + 5) % 10
            } else {
                // Today is a weekday - since Monday starts at 2, we need to subtract 2
                // and add back on the weekday
                self.today = weekInt + weekday - 2
                // We want to display today
                displayDay = self.today!
            }

            // Return the displayed day as completion value in Guarantee
            completion(displayDay)
        }
    }

    private func toTimespan(name: String, value: String) -> Timespan {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"

        let timeStrings = value.split(separator: "-")
        let timeframes = timeStrings.map { string -> Date in
            let date = formatter.date(from: string.trimmingCharacters(in: .whitespaces))
            let time = calendar.dateComponents([.hour, .minute, .second], from: date!)
            return calendar.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of: Date())!
        }

        return Timespan(name: name, start: timeframes[0], end: timeframes[1])
    }

    private func fetchBellTimes() -> Promise<[[Timespan]]> {
        let weekdaysList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/belltimes/Get")
                    .validate()
                    .responseJSON()
        }.map { json, response in
            var bellTimes: [[Timespan]] = []

            for weekday in 0..<5 {
                let weekdayBellTimes = JSON(json)["Message"]["Body"][0][weekdaysList[weekday]]

                bellTimes.append(weekdayBellTimes.dictionaryValue.map { key, value in
                    self.toTimespan(name: key, value: value.stringValue)
                }.sorted { first, second in
                    first.start < second.start
                })
            }

            return bellTimes
        }
    }

    private func fetchPeriods(bellTimes: [[Timespan]]) -> Promise<[[Period]]> {
        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/timetable/Get")
                .validate()
                .responseJSON()
        }.map { json, response in
            var periods: [[Period]] = []

            for day in 0..<10 {
                let localDayPeriods = JSON(json)["Message"]["Body"][0].arrayValue.filter { item in
                    return item["day"].intValue == day + 1
                }

                let weekday = day % 5

                periods.append(bellTimes[weekday].map { timespan in
                    if timespan.name == "Recess" {
                        return Recess(start: timespan.start, end: timespan.end)
                    } else if timespan.name == "Lunch" {
                        return Lunch(start: timespan.start, end: timespan.end)
                    } else {
                        let periodJsonNilable = localDayPeriods.first { period in
                            return period["period"].stringValue == timespan.name
                        }

                        guard let periodJson = periodJsonNilable else {
                            return nil
                        }

                        let className = periodJson["class"].stringValue
                        let teacher = periodJson["teacher"].stringValue
                        let room = periodJson["room"].stringValue

                        return Period(subject: Subject(name: className), teacher: teacher, room: room, start: timespan.start, end: timespan.end)
                    }
                }.filter {
                    $0 != nil
                }.map {
                    $0!
                })
            }

            return periods
        }
    }

    private func initTimetable() {
        self.fetchBellTimes().then { (bellTimes: [[Timespan]]) -> Promise<[[Period]]> in
            self.bellTimes = bellTimes
            return self.fetchPeriods(bellTimes: bellTimes)
        }.done { periods in
            self.timetable = periods
            self.periods.reloadData()
        }.catch { error in
            MyNSBErrorController.error(self, error: error)
        }
    }

    private func displayDay() {
        let weekdaysList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        let weekday = self.userSelectedDay % 5
        let week = (self.userSelectedDay - weekday) / 5

        self.currentWeek.selectedSegmentIndex = week
        self.currentDay.text = weekdaysList[weekday]

        if self.bellTimes == nil && self.timetable == nil {
            initTimetable()
        } else {
            print(self.timetable)
            self.periods.reloadData()
        }
    }

    @objc private func downloadTimetable(_ sender: UIBarButtonItem) {
        let defaults = UserDefaults.standard
        defaults.set(self.bellTimes, forKey: "bellTimes")
        defaults.set(self.timetable, forKey: "timetable")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let downloadButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.downloadTimetable(_:)))
        self.navigationItem.setRightBarButton(downloadButton, animated: false)

        self.previousDay.tintColor = self.view.tintColor
        self.nextDay.tintColor = self.view.tintColor
        
        self.periods.delegate = self
        self.periods.dataSource = self

        if Connection.isConnected {
            self.fetchWeek().then { week in
                return self.fetchDay(week: week)
            }.done { day in
                self.userSelectedDay = day
                self.displayDay()
            }.catch { error in
                MyNSBErrorController.error(self, error: error)
            }
        } else {
            if UserDefaults.standard.object(forKey: "bellTimes") == nil {
                MyNSBErrorController.error(self, error: NSError(domain: "", code: 503))
            }

            let defaults = UserDefaults.standard
            self.bellTimes = defaults.object(forKey: "bellTimes") as! [[Timespan]]?
            self.timetable = defaults.object(forKey: "timetable") as! [[Period]]?
            self.displayDay()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.displayDay()
    }
    
    @IBAction func clickPreviousDay(_ sender: Any) {
        self.userSelectedDay = (self.userSelectedDay + 9) % 10
        self.displayDay()
    }
    
    @IBAction func clickNextDay(_ sender: Any) {
        self.userSelectedDay = (self.userSelectedDay + 1) % 10
        self.displayDay()
    }
}

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
        cell.contentView.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)

        let archived = UserDefaults.standard.data(forKey: "timetableColours")!
        let colours = NSKeyedUnarchiver.unarchiveObject(with: archived) as! [String: UIColor]
        let currentColour = colours[period.subject.group]!
        let adjustedTextColour = Subject.textColourIsWhite(colour: currentColour) ? UIColor.white : UIColor.black

        cell.backgroundColor = currentColour

        cell.timeLabel.text = formatter.string(from: period.start)
        cell.timeLabel.textColor = adjustedTextColour
        cell.subjectLabel.text = period.subject.longName
        cell.subjectLabel.textColor = adjustedTextColour

        if userOnToday() && Date() < period.end {
            cell.countdownLabel.backgroundColor = currentColour == UIColor.white ? self.view.tintColor : UIColor.white
            cell.countdownLabel.layer.cornerRadius = 3
            cell.countdownLabel.text = self.calculateCountdown(start: period.start)
            cell.countdownLabel.textColor = currentColour
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
