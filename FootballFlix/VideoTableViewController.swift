//
//  VideoTableViewController.swift
//  FootballFlix
//
//  Created by John Tunisi on 10/25/15.
//  Copyright © 2015 John Tunisi. All rights reserved.
//


class VideoTableViewController: UITableViewController {
    
    var objects = [AnyObject]()
    var channelId: String? = nil
    
    var detailItem: Dictionary<String, AnyObject>? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let id = detail["id"] as? Dictionary<String,AnyObject> {
                if let localChannelId = id["channelId"] as? String {
                    channelId = localChannelId
                }
                loadVideos(channelId!)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pullToRefreshActivated(sender: UIRefreshControl) {
        self.loadVideos(channelId!);
        sender.endRefreshing();
    }
    
    func loadVideos(channelId: String) {
        let url = NSURL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(channelId)&key=AIzaSyCRONSh1St96OARUlZSJiWfi6EAhaFEPZw")
        let session = NSURLSession.sharedSession()
        let task = session.downloadTaskWithURL(url!) {
            (loc:NSURL?, response:NSURLResponse?, error:NSError?) in
            if error != nil {
                print(error)
                return
            }
            
            let d = NSData(contentsOfURL: loc!)!
            print("got data")
            let datastring = NSString(data: d, encoding: NSUTF8StringEncoding)
            print(datastring)
            
            let parsedObject: AnyObject?
            do {
                parsedObject = try NSJSONSerialization.JSONObjectWithData(d,
                    options: NSJSONReadingOptions.AllowFragments)
            } catch let error as NSError {
                print(error)
                return
            } catch {
                fatalError()
            }
            
            if let topLevelObj = parsedObject as? Dictionary<String,AnyObject> {
                if let items = topLevelObj["items"] as? Array<Dictionary<String,AnyObject>> {
                    for i in items {
                        self.objects.append(i)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        (UIApplication.sharedApplication().delegate as! AppDelegate).decrementNetworkActivity()
                        self.tableView.reloadData()
                        
                    }
                }
            }
        }
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).incrementNetworkActivity()
        task.resume()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! Dictionary<String, AnyObject>
                let controller = segue.destinationViewController as! DetailViewController
                controller.detailItem = object
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath)
        
        if let object = objects[indexPath.row] as? Dictionary<String, AnyObject> {
            if let snippet = object["snippet"] as? Dictionary<String, AnyObject> {
                
                // setup text.
                cell.textLabel!.text = snippet["title"] as? String
                cell.detailTextLabel!.text = snippet["description"] as? String
                
                // fetch image
                cell.imageView?.image = UIImage(named:"YouTubeIcon")
                if let images = snippet["thumbnails"] as? Dictionary<String, AnyObject> {
                    if let firstImage = images["default"] as? Dictionary<String, String> {
                        if let imageUrl = firstImage["url"]  {
                            cell.imageView?.loadImageFromURL(NSURL(string:imageUrl), placeholderImage: cell.imageView?.image, cachingKey: imageUrl)
                        }
                    }
                }
            }
        }
        return cell
    }
}
