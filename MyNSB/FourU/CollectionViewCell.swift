//
//  CollectionViewCell.swift
//  MyNSB
//
//  Created by Jayath Gunawardena on 17/12/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var fourUImage: UIImageView!
    @IBOutlet var fourUTitle: UILabel!
    
    func displayContent(image: UIImage, title: String) {
        fourUImage.image = image
        fourUTitle.text = title
    }
}
