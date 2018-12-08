//
// Created by Hanyuan Li on 2/9/18.
// Copyright (c) 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

extension String {
    func containsDigit() -> Bool {
        return self.rangeOfCharacter(from: .decimalDigits) != nil
    }
}

class Subject: NSObject, NSCoding {
    let group: String
    let shortName: String
    let longName: String
    
    /// Given a subject's code (e.g. "10RC4", "7VAR"), returns that subject's short
    /// name ("RC" and "VAR" in the two examples above)
    ///
    /// - Parameter code: a raw subject code (e.g. "11MM2")
    /// - Returns: the subject's short name
    private static func matchShortName(code: String) -> String {
        let extensionSubjects = ["EX1", "EX2", "MX1", "MX2"]
        
        let unfilteredName = regex.stringByReplacingMatches(in: code, range: NSRange(location: 0, length: code.count), withTemplate: "$2$3")
        
        if extensionSubjects.contains(unfilteredName) || !unfilteredName.containsDigit() {
            return unfilteredName
        } else {
        } else if unfilteredName.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            let index = unfilteredName.index(unfilteredName.endIndex, offsetBy: -1)
            return String(unfilteredName[..<index])
        } else {
            return unfilteredName
        }
    }
    
    /// Returns the contents of subject_list.json
    ///
    /// - Returns: a JSON object filled with data from subject_list.json
    private static func contentsOfSubjectsFile() -> JSON {
        let path = Bundle.main.path(forResource: "subject_list", ofType: "json")!
        let string = try! String(contentsOfFile: path)
        return JSON(parseJSON: string)
    }

    /// Finds the full name of the subject based on a shortened version of it.
    ///
    /// - Parameter name: The name of a shortened version of a subject, for example `10RC4`.
    private static func find(name: String) -> (String, String) {
        if name == "Recess" || name == "Lunch" {
            return (name, name)
        }

        let json = Subject.contentsOfSubjectsFile().dictionaryValue
        
        for (group, subjects) in json {
            let subjectJSON = subjects.dictionaryValue
            
            if let matchedKey = subjectJSON.keys.firstIndex(of: matchedName) {
                return (group, subjectJSON[matchedKey].value.stringValue)
            }
        }

        return ("Default", name)
    }

    init(name: String) {
        self.shortName = name
        (self.group, self.longName) = Subject.find(name: name)
    }

    required init(coder aDecoder: NSCoder) {
        self.group = aDecoder.decodeObject(forKey: "group") as! String
        self.shortName = aDecoder.decodeObject(forKey: "shortName") as! String
        self.longName = aDecoder.decodeObject(forKey: "longName") as! String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.group, forKey: "group")
        aCoder.encode(self.shortName, forKey: "shortName")
        aCoder.encode(self.longName, forKey: "longName")
    }

    static func textColourIsWhite(colour: UIColor) -> Bool {
        let localColour = CIColor(color: colour)
        let luminance = 0.299 * localColour.red + 0.587 * localColour.green + 0.114 * localColour.blue

        return (luminance <= 0.5)
    }
}
