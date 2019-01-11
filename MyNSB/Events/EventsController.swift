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
    // A list of all the events, taken from the API
    private var events: Events?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Make the selected date on the calendar today
        self.calendarView.select(Events.getDay(date: Date()))

        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.calendarView.scroll(toToday: true)

        self.eventView.delegate = self
        self.eventView.dataSource = self

        self.stackView.alpha = 0.0
        self.stackConstraint.constant = self.stackView.frame.height
        self.view.layoutIfNeeded()
        self.eventsShown = false

        firstly {
            EventsAPI.events()
        }.done { events in
            self.events = Events(events: events)
            self.calendarView.reloadData()
        }.catch { error in
            MyNSBErrorController.error(self, error: MyNSBError.generic(error as NSError))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if (segue.identifier == "clickEventSegue") {
            let destination = segue.destination as! SingleEventController
            destination.event = self.currentEvent
        }
    }
}

extension EventsController: RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource {
    func datePickerView(_ view: RSDFDatePickerView, didSelect date: Date) {
        self.eventsInDate = self.events?.filter(for: date) ?? []

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
        return self.events?.dates().contains(date) ?? false
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
        self.eventView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "clickEventSegue", sender: self)
    }
}
