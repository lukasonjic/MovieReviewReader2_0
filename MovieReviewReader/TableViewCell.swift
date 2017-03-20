//
//  TableViewCell.swift
//  MovieReviewReader
//
//  Created by Pet Minuta on 17/02/2017.
//  Copyright © 2017 Luka Sonjic. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var commentedLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        movieNameLabel.text = "ReviewTitle"
        movieImageView.image = UIImage(named: "mock")
        commentedLabel.isHidden = true
        commentedLabel.text = "Commented"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        commentedLabel.isHidden = true
    }
    
    func setup(imageURL: String, reviewTitle: String, commented: Bool){
        movieNameLabel.text = reviewTitle
        getImage(imageURL: imageURL)
        commentedLabel.isHidden = !commented
    }
    
    func getImage(imageURL: String) {
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
    
}
