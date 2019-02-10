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

class FourUController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var issues: [Issue] = []
    private var images: [UIImage] = []
    
    private var currentURL: URL?
    
    @IBOutlet weak var issuesView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        self.issuesView.delegate = self
        self.issuesView.dataSource = self
        
        self.flowLayout.itemSize = UICollectionViewFlowLayoutAutomaticSize
        self.flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        
        let group = DispatchGroup()
        
        async {
            do {
                self.issues = try await(FourUAPI.get())
                
                for issue in self.issues {
                    group.enter()
                    let image = try await(issue.image())
                    self.images.append(image)
                    group.leave()
                }
                
                group.notify(queue: .main) {
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
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        cell.titleLabel.text = issue.name
        cell.descriptionLabel.text = issue.description
        cell.coverImage.image = self.images[indexPath.row]
        print(cell.coverImage.frame.size.width)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let url = self.currentURL else {
            return
        }
        
        if segue.identifier == "showIssue" {
            let destination = segue.destination as! WebController
            destination.website = url
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let issue = self.issues[indexPath.row]
        
        self.currentURL = URL(string: issue.link)
        self.performSegue(withIdentifier: "showIssue", sender: self)
    }
}
