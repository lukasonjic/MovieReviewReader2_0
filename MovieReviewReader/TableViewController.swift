//
//  TableViewController.swift
//  MovieReviewReader
//
//  Created by Pet Minuta on 17/02/2017.
//  Copyright © 2017 Luka Sonjic. All rights reserved.
//

import UIKit
import SwiftyJSON
import Dispatch
import CoreData


class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var request: URLRequest?
    let URLString = "https://api.nytimes.com/svc/movies/v2/reviews/search.json?api-key=5822744dc0f64a15be6bf1e0ace6a0d3"
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Review> = {
        let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "movieTitle", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DatabaseController.getContext(), sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib.init(nibName: "TableViewCell", bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: "TableViewCell")

        let url = URL(string: URLString)
        request = URLRequest(url: url!)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.handleAppActivation()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationItem.title = "Movie Review Reader"
        tableView.rowHeight = UITableViewAutomaticDimension
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppActivation),
            name: NSNotification.Name.UIApplicationWillEnterForeground,
            object: nil
        )
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let reviews = fetchedResultsController.fetchedObjects {
            return reviews.count
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let review = fetchedResultsController.object(at: indexPath)
        if let url = review.imageURL {
            if let movieTitle = review.movieTitle {
                if review.comment != nil {
                    if review.comment?.comment != "" {
                        cell.setup(imageURL: url, reviewTitle: movieTitle, commented: true)
                    }
                } else {
                    cell.setup(imageURL: url, reviewTitle: movieTitle, commented: false)
                }
            }
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let review = fetchedResultsController.object(at: indexPath)
        let reviewViewController = ReviewViewController(review: review)
        navigationController?.pushViewController(reviewViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    
    private func execTask(request: URLRequest, taskCallback: @escaping (Bool,
        AnyObject?) -> ()) {
    
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let data = data {
                let json = JSON(data: data, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                if let number = Int(json["num_results"].stringValue){
                    for i in 0..<number {
                        let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
                        var addReview: Bool = true
                        do {
                            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
                            for result in searchResults {
                                if let title = result.movieTitle {
                                    if title == json["results"][i]["display_title"].stringValue {
                                        addReview = false
                                    }
                                }
                            }
                        } catch {
                            print("Error")
                        }
                        
                        if addReview == true {
                            let review: Review = NSEntityDescription.insertNewObject(forEntityName: "Review", into: DatabaseController.getContext()) as! Review
                            review.imageURL = json["results"][i]["multimedia"]["src"].stringValue
                            review.linkText = json["results"][i]["link"]["suggested_link_text"].stringValue
                            review.linkURL = json["results"][i]["link"]["url"].stringValue
                            review.movieTitle = json["results"][i]["display_title"].stringValue
                            review.reviewDate = json["results"][i]["publication_date"].stringValue
                            review.reviewer = json["results"][i]["byline"].stringValue
                            review.reviewTitle = json["results"][i]["headline"].stringValue
                            review.comment = nil
                            review.summary = json["results"][i]["summary_short"].stringValue
                            
                            DatabaseController.saveContext()
                        }
                        
                    }
                    
                }
                
                
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    taskCallback(true, json as AnyObject?)
                } else {
                    taskCallback(false, json as AnyObject?)
                }
            }
        })
        task.resume()
    }

    @objc func handleAppActivation() {
        DispatchQueue.global(qos: .background).sync {
            if let request = self.request {
                
                execTask(request: request) { [weak self](ok, obj) in
                    DispatchQueue.main.sync {
                        self?.tableView.reloadData()
                    }
                }
            }
            
        }
        
    }
}

