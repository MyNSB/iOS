//
//  CalendarController.swift
//  MyNSB
//
//  Created by Hanyuan Li on 20/7/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON

import RSDayFlow

class EventsController: UIViewController {
    // Current calendar configuration
    private var calendar = Calendar.current
    // A list of all the events, taken from the API
    private var events: [Event] = []
    // A list of all the events in a certain date, needed for the `eventView` containing
    // all events in the day when the user clicks on a day
    private var eventsInDate: [Event] = []
    // A flag to detect whether `stackView` is in display or not
    private var eventsShown = false

    // The event that's currently being selected, used when preparing to segue into a SingleEventController
    private var currentEvent: Event!

    @IBOutlet weak var calendarView: RSDFDatePickerView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentDayLabel: UILabel!
    @IBOutlet weak var eventView: UITableView!

    // Given a date `date`, returns that same date but at 00:00:00
    private func getDay(date: Date) -> Date {
        let currentComponents = self.calendar.dateComponents([.year, .month, .day], from: date)
        return self.calendar.date(from: currentComponents)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Make the selected date on the calendar today
        self.calendarView.select(self.getDay(date: Date()))

        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.calendarView.scroll(toToday: false)

        self.eventView.delegate = self
        self.eventView.dataSource = self

        self.stackView.alpha = 0.0
        self.stackConstraint.constant = self.stackView.frame.height
        self.view.layoutIfNeeded()
        self.eventsShown = false

        firstly {
            fetchEvents()
        }.done { events in
            self.events = events
            self.calendarView.reloadData()
        }.catch { error in
            MyNSBErrorController.error(self, error: MyNSBError.generic(error as NSError))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func fetchEvents() -> Promise<[Event]> {
        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/events/Get")
                    .validate()
                    .responseJSON()
        }.map { json, response in
            let body = JSON(json)["Message"]["Body"][0].arrayValue

            return body.map { eventJson in
                return Event(contents: eventJson)
            }.sorted { first, second in
                first.start < second.start
            }
        }
    }

    private func getEventDates() -> Set<Date> {
        var dates = Set<Date>()

        for event in events {
            var start = self.getDay(date: event.start)
            let end = self.getDay(date: event.end)

            while start <= end {
                dates.insert(start)
                start = self.calendar.date(byAdding: .day, value: 1, to: start)!
            }
        }

        return dates
    }

    private func getAllEvents(for date: Date) -> [Event] {
        return self.events.filter { event in
            let start = self.getDay(date: event.start)
            let end = self.getDay(date: event.end)
            return DateInterval(start: start, end: end).contains(date)
        }
    }

    private func hideStackView() {
        self.view.isUserInteractionEnabled = false
        self.stackConstraint.constant = self.stackView.frame.height

        UIView.animate(.promise, duration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.stackView.alpha = 0.0
        }).done { _ in
            self.view.isUserInteractionEnabled = true
            self.eventsShown = false
        }
    }

    private func showStackView() {
        self.view.isUserInteractionEnabled = false
        self.stackConstraint.constant = 0

        UIView.animate(.promise, duration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.stackView.alpha = 1.0
        }).done { _ in
            self.view.isUserInteractionEnabled = true
            self.eventsShown = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SingleEventController
        destination.event = self.currentEvent
    }
}

extension EventsController: RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource {
    func datePickerView(_ view: RSDFDatePickerView, didSelect date: Date) {
        self.eventsInDate = self.getAllEvents(for: date)

        if self.eventsInDate.count == 0 && self.eventsShown {
            self.hideStackView()
        } else if self.eventsInDate.count != 0 && !self.eventsShown {
            self.showStackView()
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d', 'yyyy"

        self.currentDayLabel.text = formatter.string(from: date)
        self.eventView.reloadData()
    }

    func datePickerView(_ view: RSDFDatePickerView, shouldMark date: Date) -> Bool {
        return self.getEventDates().contains(date)
    }

    func datePickerView(_ view: RSDFDatePickerView, markImageColorFor date: Date) -> UIColor {
        return UIColor(red: 83/255.0, green: 215/255.0, blue: 105/255.0, alpha: 1.0)
    }
}

extension EventsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventsInDate.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.eventView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        let currentEvent = self.eventsInDate[indexPath.row]

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        cell.monthLabel!.text = formatter.string(from: currentEvent.end)

        formatter.dateFormat = "d"
        cell.dayLabel!.text = formatter.string(from: currentEvent.end)

        cell.eventNameLabel!.text = currentEvent.name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentEvent = self.eventsInDate[indexPath.row]
        self.performSegue(withIdentifier: "clickEventSegue", sender: self)
    }
}
