//
//  WebViewController.swift
//  MovieReviewReader
//
//  Created by Pet Minuta on 22/02/2017.
//  Copyright © 2017 Luka Sonjic. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    private var url: String?
    
    convenience init(url: String) {
        self.init()
        self.url = url
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = self.url {
            let url1 = URL(string: url)
            let urlRequest = URLRequest(url: url1!)
            webView.loadRequest(urlRequest)
        }
    }

}
