//
//  4U.swift
//  MyNSB
//
//  Created by Jayath Gunawardena on 3/1/19.
//  Copyright © 2019 Jayath Gunawardena. All rights reserved.
//

import UIKit

import Alamofire
import AwaitKit

class FourUController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private var issues: [Issue] = []
    private var images: [UIImage] = []
    
    @IBOutlet weak var issuesView: UICollectionView!
    
    override func viewDidLoad() {
        self.issuesView.delegate = self
        self.issuesView.dataSource = self
        
        async {
            do {
                self.issues = try await(FourUAPI.get())
                self.images = try self.issues.map { issue in
                    try await(issue.image())
                }
                
                DispatchQueue.main.async {
                    self.issuesView.reloadData()
                }
            } catch let error as MyNSBError {
                MyNSBErrorController.error(self, error: error)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.issues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! IssueCell
        let issue = self.issues[indexPath.row]
        
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        cell.titleLabel.text = issue.name
        cell.descriptionLabel.text = issue.description
        cell.coverImage.image = self.images[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
