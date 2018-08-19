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
    private var alertController = UIAlertController()
    private var localDay = 0
    private var today = 0
    private var periodInfo: [Period] = []

    // Mark: Properties
    
    @IBOutlet weak var currentWeek: UISegmentedControl!
    @IBOutlet weak var currentDay: UILabel!
    @IBOutlet weak var previousDay: UIButton!
    @IBOutlet weak var nextDay: UIButton!
    @IBOutlet weak var periods: UITableView!

    private func initAlertController(error: Error) {
        self.alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
        }

        self.alertController.addAction(confirmAction)
        self.present(self.alertController, animated: true, completion: nil)
    }

    private func userOnToday() -> Bool {
        return self.localDay == self.today
    }
    
    private func fetchWeek() -> Promise<String> {
        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/week/Get")
                .validate()
                .responseJSON()
        }.map { json, response in
            return JSON(json)["Body"].stringValue
        }
    }

    private func fetchDay(week: String) -> Guarantee<Int> {
        return Guarantee<Int> { completion in
            let temp_day = week == "A" ? 0 : 5
            var weekday = Calendar.current.component(.weekday, from: Date())

            if weekday == 1 || weekday == 7 {
                weekday = 2
            }

            self.today = temp_day + weekday - 2
            completion(self.today)
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
            return calendar.date(bySettingHour: time.hour!, minute: time.minute!, second: time.day!, of: Date())!
        }

        return Timespan(name: name, start: timeframes[0], end: timeframes[1])
    }

    private func fetchBellTimes() -> Promise<[Timespan]> {
        let weekdaysList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/belltimes/Get")
                    .validate()
                    .responseJSON()
        }.map { json, response in
            let weekday = self.localDay % 5
            let weekdayBellTimes = JSON(json)["Message"]["Body"][0][weekdaysList[weekday]]
            print(weekdayBellTimes.dictionaryValue)
            
            return weekdayBellTimes.dictionaryValue.map { key, value in
                self.toTimespan(name: key, value: value.stringValue)
            }.sorted { first, second in
                first.start < second.start
            }
        }
    }

    private func fetchPeriods(bellTimes: [Timespan]) -> Promise<[Period]> {
        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/timetable/Get")
                .validate()
                .responseJSON()
        }.map { json, response in
            let localDayPeriods = JSON(json)["Message"]["Body"][0].arrayValue.filter { item in
                return item["day"].intValue == self.localDay + 1
            }

            return bellTimes.map { timespan in
                if timespan.name == "Recess" {
                    return Recess(start: timespan.start, end: timespan.end)
                } else if timespan.name == "Lunch" {
                    return Lunch(start: timespan.start, end: timespan.end)
                } else {
                    let periodJson = localDayPeriods.first { period in
                        period["name"].stringValue == timespan.name
                    }!

                    let className = periodJson["class"].stringValue
                    let teacher = periodJson["teacher"].stringValue
                    let room = periodJson["room"].stringValue

                    return Period(name: className, teacher: teacher, room: room, start: timespan.start, end: timespan.end)
                }
            }
        }
    }

    private func displayDay(day: Int) {
        self.localDay = day

        let weekdaysList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        let weekday = localDay % 5
        let week = (localDay - weekday) / 5

        self.currentWeek.selectedSegmentIndex = week
        self.currentDay.text = weekdaysList[weekday]

        firstly {
            self.fetchBellTimes()
        }.then { bellTimes in
            return self.fetchPeriods(bellTimes: bellTimes)
        }.done { periods in
            self.periodInfo = periods
            self.periods.reloadData()
        }.catch { error in
            self.initAlertController(error: error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.previousDay.tintColor = self.view.tintColor
        self.nextDay.tintColor = self.view.tintColor
        
        self.periods.delegate = self
        self.periods.dataSource = self
        
        firstly {
            fetchWeek()
        }.then { week in
            return self.fetchDay(week: week)
        }.done { day in
            self.displayDay(day: day)
        }.catch { error in
            self.initAlertController(error: error)
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
        let weekday = self.localDay / 5
        self.localDay = weekday + (self.currentWeek.selectedSegmentIndex * 5)
    }
    
    @IBAction func clickPreviousDay(_ sender: Any) {
        self.displayDay(day: (self.localDay + 9) % 10)
    }
    
    @IBAction func clickNextDay(_ sender: Any) {
        self.displayDay(day: (self.localDay + 1) % 10)
    }
}

extension TimetableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.periodInfo.count
    }

    private func calculateCountdown(time: Date) -> String {
        let interval = DateInterval(start: time, end: Date()).duration

        if interval >= 3600 {
            return "\(interval / 3600)h"
        } else if interval < 3600 && interval > 60 {
            return "\(interval / 60)m"
        } else {
            return "<1m"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let period = periodInfo[indexPath.row]
        let start = period.start
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        if userOnToday() && start < Date() {
            let cell = self.periods.dequeueReusableCell(withIdentifier: "todayPeriodCell", for: indexPath) as! TodayPeriodCell

            cell.timeLabel.text = formatter.string(from: start)
            cell.subjectLabel.text = period.name

            cell.countdownLabel.layer.cornerRadius = 3
            cell.countdownLabel.text = self.calculateCountdown(time: period.start)

            if period.name == "Recess" || period.name == "Lunch" {
                cell.stackView.isHidden = true
            } else {
                cell.roomLabel.text = period.room!
                cell.teacherLabel.text = period.teacher!
            }

            return cell
        } else {
            let cell = self.periods.dequeueReusableCell(withIdentifier: "periodCell", for: indexPath) as! PeriodCell

            cell.timeLabel.text = formatter.string(from: start)
            cell.subjectLabel.text = period.name

            if period.name == "Recess" || period.name == "Lunch" {
                cell.stackView.isHidden = true
            } else {
                cell.roomLabel.text = period.room!
                cell.teacherLabel.text = period.teacher!
            }

            return cell
        }
    }
}
