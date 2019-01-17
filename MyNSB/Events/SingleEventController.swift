//
//  SingleEventController.swift
//  MyNSB
//
//  Created by Hanyuan Li on 22/7/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit

import Alamofire
import AlamofireImage
import AwaitKit

extension Date {
    static func formatStringForEvents(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        
        return formatter.string(from: start) + " - " + formatter.string(from: end)
    }
}

class SingleEventController: UIViewController {
    private var alertController = UIAlertController()

    var event: Event?

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventShortDesc: UILabel!
    @IBOutlet weak var eventLongDesc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.title = event!.name

        self.eventName.text = event!.name
        self.eventDate.text = Date.formatStringForEvents(start: event!.start, end: event!.end)
        self.eventShortDesc.text = event!.shortDescription
        self.eventLongDesc.text = event!.longDescription

        if let image = ImageCache.cache.object(forKey: self.event!.imageURL as NSString) {
            self.eventImage.image = image
        } else {
            async {
                do {
                    let image = try await(self.event!.image())
                    ImageCache.cache.setObject(image, forKey: self.event!.imageURL as NSString)
                    self.eventImage.image = image
                } catch let error as MyNSBError {
                    MyNSBErrorController.error(self, error: error)
                }
            }
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
}
