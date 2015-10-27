//
//  DetailViewController.swift
//  FootballFlix
//
//  Created by John Tunisi on 10/21/15.
//  Copyright © 2015 John Tunisi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var videoDescription: UITextView!

    var detailItem: Dictionary<String, AnyObject>? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        if let detail = self.detailItem {
            if let snippet = detail["snippet"] as? Dictionary<String,AnyObject> {
                if let title = self.videoTitle {
                    title.text = snippet["title"] as? String
                }
                if let descript = self.videoDescription {
                    descript.text = snippet["description"] as? String
                }
                
                self.videoImage?.image = UIImage(named:"YouTubeIcon")
                if let images = snippet["thumbnails"] as? Dictionary<String,AnyObject> {
                    if let firstImage = images["medium"] as? Dictionary<String,String> {
                        if let imageUrl = firstImage["url"]  {
                            self.videoImage?.loadImageFromURL(NSURL(string:imageUrl), placeholderImage: self.videoImage?.image, cachingKey: imageUrl)
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

