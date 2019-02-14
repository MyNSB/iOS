//
//  CollectionViewCell.swift
//  MyNSB
//
//  Created by Jayath Gunawardena on 3/1/19.
//  Copyright © 2019 Jayath Gunawardena. All rights reserved.
//

import UIKit

class IssueCell: UICollectionViewCell {
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = UIScreen.main.bounds.size.width - 20
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.contentView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.contentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.contentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
