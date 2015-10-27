//
//  videoPlayerViewController.swift
//  FootballFlix
//
//  Created by John Tunisi on 10/27/15.
//  Copyright © 2015 John Tunisi. All rights reserved.
//

import youtube_ios_player_helper

class videoPlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: YTPlayerView!
    
    var videoId:String?
    
    override func viewDidLoad() {
        playerView.loadWithVideoId(videoId)
    }
}