//
//  FeedViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Jesus Maldonado on 1/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UITableViewController {
    
    var photos = [PFObject: NSData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentFollowingUsers()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCurrentFollowingUsers() -> Void {
        let query = PFQuery(className: "Follow")
        
        query.whereKey("from", equalTo: PFUser.currentUser()!)
        query.includeKey("to")
        query.findObjectsInBackgroundWithBlock(handleFollow)
    }

    func handleFollow(follows: [PFObject]?, err: NSError?) -> Void {
        if err != nil {
            
        } else {
            if let retrievedFollows = follows as [PFObject]? {
                firePhotoQuery(retrievedFollows)
            }
        }
    }
    
    func firePhotoQuery(retrievedFollows: [PFObject]) -> Void {
        let users = retrievedFollows.map {
            (var follow) -> PFUser in
            return follow["to"] as! PFUser
        }
        let query = PFQuery(className: "Photo")
        
        query.whereKey("user", containedIn: users)
        query.includeKey("user")
        query.findObjectsInBackgroundWithBlock(handlePhotoRetrieval)
    }
    
    func handlePhotoRetrieval(photos: [PFObject]?, err: NSError?) -> Void {
        if err != nil {
            
        } else {
            if let retrievedPhotos = photos as [PFObject]? {
                for photo in retrievedPhotos {
                    if self.photos[photo] == nil {
                        retrieveImage(photo)
                    }
                }
            }
        }
    }
    // MARK: - Table view data source

    func retrieveImage(photo: PFObject) -> Void {
        let file = photo["imageFile"] as? PFFile
        print(photo)
        file?.getDataInBackgroundWithBlock({ (data, err) -> Void in
            if err == nil {
                self.photos[photo] = data
                self.tableView.reloadData()
            }
        })
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.photos.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let instagramCell = tableView.dequeueReusableCellWithIdentifier("InstagramCell", forIndexPath: indexPath) as! Cell
        let row = indexPath.row
        let photos = Array(self.photos.keys)
        let photo = photos[row]
        let imageFile = self.photos[photo]! as NSData
        let username = photo["user"]["username"] as! String
        let caption = photo["caption"] as! String

        instagramCell.postedImage.image = UIImage(data: imageFile)
        instagramCell.username.text = username
        instagramCell.caption.text = caption
        
        // Configure the cell...

        return instagramCell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
