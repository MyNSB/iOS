//
//  TimetableController.swift
//  MyNSB
//
//  Created by Hanyuan Li on 16/1/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import UserNotifications

import Alamofire
import AwaitKit
import PromiseKit
import SwiftyJSON

class TimetableController: UIViewController {
    // A list of periods within the timetable, separated by day - each `Period` class contains
    // all the information needed to represent a period (e.g. classroom, teacher name, subject name)
    private var timetable: Timetable?
    
    // The day that the user is currently on, from 0 to 9 (0 being Week A Monday, 9 being Week B Friday)
    private var userSelectedDay = 0
    // The date today, expressed from 0 to 9 (see above)
    private var today: Int? = nil
    
    private var calendar = Calendar.current
    
    // Flag to check if this is the first time since the app opening that the user
    // has accessed the timetable, for automatic updating optimisation
    private static var firstAccess = true
    
    // MARK: Properties
    
    @IBOutlet weak var currentWeek: UISegmentedControl!
    @IBOutlet weak var currentDay: UILabel!
    @IBOutlet weak var previousDay: UIButton!
    @IBOutlet weak var nextDay: UIButton!
    @IBOutlet weak var periods: UITableView!

    // Flags
    
    /// Checks if the app should display countdowns in `PeriodCell`s.
    ///
    /// - Returns: A boolean that describes if the user is on the weekday page for today.
    func shouldDisplayCountdown() -> Bool {
        return self.userSelectedDay == self.today
    }
    
    /// Checks if the app should update the timetable (if the app is connected to the Internet,
    /// if the user wants automatic updates and if this is the first time the user opens the
    /// timetable section of the app)
    ///
    /// - Returns: A boolean that describes whether the timetable should be updated or not
    func shouldUpdateTimetable() -> Bool {
        return Connection.isConnected &&
            UserDefaults.standard.bool(forKey: "automaticUpdatesFlag") &&
            TimetableController.firstAccess
    }

    private func loadDay() -> Promise<(Int?, Int)> {
        return async {
            let week = try await(TimetableAPI.week()) == "A" ? 0 : 5
            let day = self.calendar.component(.weekday, from: Date()) - 2
            
            if day == -1 || day == 5 {
                return (nil, (week + 5) % 10)
            } else {
                return (week + day, week + day)
            }
        }
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

    private func initTimetable() {
        if self.shouldUpdateTimetable() {
            async {
                do {
                    self.timetable = try await(Timetable.fetch())
                    self.timetable!.save()
                    
                    (self.today, self.userSelectedDay) = try await(self.loadDay())
                    self.launchNotifications()
                    
                    DispatchQueue.main.async {
                        self.moveViewToSelectedDay()
                    }
                } catch let error as MyNSBError {
                    MyNSBErrorController.error(self, error: error)
                }
            }
        } else if Timetable.isOffline() {
            self.timetable = Timetable.fetchOffline()
            self.moveViewToSelectedDay()
        } else {
            MyNSBErrorController.error(self, error: MyNSBError.connection)
        }
    }
    
    // Given a date `date`, returns that same date but at 00:00:00
    private func getDay(date: Date) -> Date {
        let currentComponents = self.calendar.dateComponents([.year, .month, .day], from: date)
        return self.calendar.date(from: currentComponents)!
    }
    
    private func launchNotifications() {
        let today = self.getDay(date: Date())
        var weekday = Calendar.current.component(.weekday, from: today) - 2
        if weekday == 5 { weekday = -2 }
        let monday = today.addingTimeInterval(TimeInterval(weekday * 24 * 60 * 60))
        
        let centre = UNUserNotificationCenter.current()
        
        centre.getPendingNotificationRequests { _ in
            let notifs: [String] = UserDefaults.standard.stringArray(forKey: "timetableNotifs") ?? []
            centre.removePendingNotificationRequests(withIdentifiers: notifs)
            
            var newNotifs: [String] = []
            for day in 0..<10 {
                for period in self.timetable!.get(day: day) {
                    let adjustedDay = day >= 5 ? day + 2 : day
                    
                    let currentDay = self.calendar.dateComponents([.year, .month, .day], from: monday.addingTimeInterval(TimeInterval(adjustedDay * 24 * 60 * 60)))
                    var periodComponents = self.calendar.dateComponents([.year, .month, .day], from: period.start)
                    
                    periodComponents.year = currentDay.year
                    periodComponents.month = currentDay.month
                    periodComponents.day = currentDay.day
                    
                    let content = UNMutableNotificationContent()
                    content.title = period.subject.longName
                    content.body = "Room: \(period.room ?? "None")"
                    content.sound = UNNotificationSound.default()
                    
                    let id = UUID().uuidString
                    let trigger = UNCalendarNotificationTrigger(dateMatching: periodComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                    print(request)
                    newNotifs.append(id)
                    centre.add(request)
                }
            }
            
            UserDefaults.standard.set(newNotifs, forKey: "timetableNotifs")
        }
    }
}

// Methods exposed to public
extension TimetableController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.previousDay.tintColor = self.view.tintColor
        self.nextDay.tintColor = self.view.tintColor
        
        self.periods.delegate = self
        self.periods.dataSource = self
        
        self.initTimetable()
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
    
    @IBAction func updateTimetable(_ sender: Any) {
        async {
            do {
                self.timetable = try await(Timetable.fetch())
            } catch let error as MyNSBError {
                MyNSBErrorController.error(self, error: error)
            }
        }
    }
}

// Extension on TimetableController for UITableViewController overloads
extension TimetableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timetable?.get(day: self.userSelectedDay).count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let period = self.timetable!.get(day: self.userSelectedDay)[indexPath.row]

        let cell = self.periods.dequeueReusableCell(withIdentifier: "periodCell", for: indexPath) as! PeriodCell
        cell.controller = self
        cell.update(period: period)

        return cell
    }
}
