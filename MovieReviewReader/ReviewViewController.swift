//
//  ReviewViewController.swift
//  MovieReviewReader
//
//  Created by Pet Minuta on 21/02/2017.
//  Copyright © 2017 Luka Sonjic. All rights reserved.
//

import UIKit
import CoreData

class ReviewViewController: UIViewController {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var reviewAuthorLabel: UILabel!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var saveEditButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBAction func openWebView(_ sender: UIButton) {
        if let url = self.review?.linkURL {
            let webViewController = WebViewController(url: url)
            navigationController?.pushViewController(webViewController, animated: true)
            }
    }
    
    var isCommentEdited = false
    
    @IBAction func saveOrEdit(_ sender: UIButton) {
        if sender.titleLabel?.text == "Save" {
            if commentTextView.text != "" {
                if commentTextView.text != review?.comment?.comment {
                    saveComment(newComment: commentTextView.text)
                    commentTextView.isEditable = false
                    sender.setTitle("Edit", for: .normal)
                    removeButton.isHidden = false
                }
                
            }
        } else if sender.titleLabel?.text == "Edit" {
            sender.setTitle("Save", for: .normal)
            commentTextView.isEditable = true
        }
    }
    
    @IBAction func removeComment(_ sender: UIButton) {
        commentTextView.text = ""
        sender.isHidden = true
        saveEditButton.setTitle("Save", for: .normal)
        if let comment = review?.comment {
            DatabaseController.getContext().delete(comment)
            DatabaseController.saveContext()
        }
        commentTextView.isEditable = true
        
    }
    
    
    private var review: Review?
    private var image: UIImage?
    
    convenience init(review: Review) {
        self.init()
        self.review = review
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)

        if let imageURL = review?.imageURL {
            getImage(imageURL: imageURL)
        }
        self.movieTitleLabel.text = self.review?.movieTitle
        self.reviewDateLabel.text = self.review?.reviewDate
        self.reviewAuthorLabel.text = self.review?.reviewer
        self.summaryLabel.text = self.review?.summary
        self.navigationItem.title = self.review?.movieTitle
        removeButton.setTitle("Remove", for: .normal)
        if self.review?.comment != nil {
            commentTextView.text = review?.comment?.comment
            saveEditButton.setTitle("Edit", for: .normal)
            commentTextView.isEditable = false
        } else {
            saveEditButton.setTitle("Save", for: .normal)
            removeButton.isHidden = true
            commentTextView.isEditable = true
        }
        
        self.linkButton.setTitle(self.review?.linkText, for: .normal)
        self.linkButton.isHidden = true
        self.linkButton.titleLabel?.numberOfLines = 0
        self.linkButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.linkButton.titleLabel?.lineBreakMode = .byClipping
        
        
        self.setAlpha(value: 0)
        self.setFrame(x: UIScreen.main.bounds.width)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.setAlpha(value: 1)
            self.setFrame(x: 0)
        }, completion: { _ in
            self.linkButton.isHidden = false
        })
        
    }
    
    private func setFrame(x: CGFloat) {
        self.movieTitleLabel.frame.origin.x = x
        self.reviewDateLabel.frame.origin.x = x
        self.reviewAuthorLabel.frame.origin.x = x
    }
    
    private func setAlpha(value: CGFloat) {
        self.movieTitleLabel.alpha = value
        self.reviewDateLabel.alpha = value
        self.reviewAuthorLabel.alpha = value
    }
    
    func getImage(imageURL: String){
        DispatchQueue.global().async {
            if let url = URL(string: imageURL){
                if let data = try? Data(contentsOf: url){
                    DispatchQueue.main.sync {
                        if let image = UIImage(data: data) {
                            self.movieImageView.image = image
                        }
                    }
                }
            }
        }
    }
    func dismissKeyboard() {
        commentTextView.resignFirstResponder()
    }
    
    func saveComment(newComment: String) {
        if let comment = review?.comment {
            comment.comment = newComment
        } else {
            let comment: Comment = NSEntityDescription.insertNewObject(forEntityName: "Comment", into: DatabaseController.getContext()) as! Comment
            comment.comment = newComment
            comment.review = self.review
            
        }
        DatabaseController.saveContext()
        
    }
}
