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
    private var alertController = UIAlertController()

    private var calendar = Calendar.current
    private var events = [Event]()
    private var eventDates = Set<Date>()
    private var eventsInDate = [Event]()

    private var selectedDate: Date!
    private var currentEvent: Event!

    @IBOutlet weak var calendarView: RSDFDatePickerView!
    @IBOutlet weak var currentDayLabel: UILabel!
    @IBOutlet weak var eventView: UITableView!
    
    private func initAlertController(error: Error) {
        self.alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
        }

        self.alertController.addAction(confirmAction)
        self.present(self.alertController, animated: true, completion: nil)
    }

    private func getDay(date: Date) -> Date {
        let currentComponents = self.calendar.dateComponents([.year, .month, .day], from: date)
        return self.calendar.date(from: currentComponents)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.currentDayLabel.layer.borderWidth = 1
        self.currentDayLabel.layer.borderColor = UIColor.lightGray.cgColor

        self.selectedDate = self.getDay(date: Date())
        self.calendarView.select(self.selectedDate)

        self.calendarView.delegate = self
        self.calendarView.dataSource = self

        self.eventView.delegate = self
        self.eventView.dataSource = self

        firstly {
            fetchEvents()
        }.done { events in
            self.events = events
            self.eventDates = self.getEventDates()
            self.calendarView.reloadData()
        }.catch { error in
            self.initAlertController(error: error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func parseDate(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        return formatter.date(from: string)!
    }

    private func fetchEvents() -> Promise<[Event]> {
        return firstly {
            Alamofire.request("http://35.189.50.185:8080/api/v1/events/Get")
                    .validate()
                    .responseJSON()
        }.map { json, response in
            let body = JSON(json)["Message"]["Body"][0].arrayValue

            return body.map { eventJson in
                let name = eventJson["EventName"].stringValue
                let start = self.parseDate(from: eventJson["EventStart"].stringValue)
                let end = self.parseDate(from: eventJson["EventEnd"].stringValue)
                let location = eventJson["EventLocation"].stringValue
                let organiser = eventJson["EventOrganiser"].stringValue
                let shortDescription = eventJson["EventShortDesc"].stringValue
                let longDescription = eventJson["EventLongDesc"].stringValue
                let picture = eventJson["EventPictureURL"].stringValue

                return Event(
                        name: name,
                        start: start,
                        end: end,
                        location: location,
                        organiser: organiser,
                        shortDescription: shortDescription,
                        longDescription: longDescription,
                        imageURL: picture
                )
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SingleEventController
        destination.event = self.currentEvent
    }
}

extension EventsController: RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource {
    func datePickerView(_ view: RSDFDatePickerView, didSelect date: Date) {
        self.eventsInDate = self.getAllEvents(for: date)

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d', 'yyyy"

        self.currentDayLabel.text = formatter.string(from: date)
        self.eventView.reloadData()
    }

    func datePickerView(_ view: RSDFDatePickerView, shouldMark date: Date) -> Bool {
        return self.eventDates.contains(date)
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
