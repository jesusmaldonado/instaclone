//
//  FollowTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Jesus Maldonado on 12/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
class FollowTableViewController: UITableViewController {

    
    //TODO
    //Change back to dictionary format
    //Make follows query include key from.username
    //Based on whether the users dictionary already includes a user with the object id given
    
    @IBAction func logOut(sender: UIButton) {
        PFUser.logOutInBackground()
        let navVC = self.parentViewController as! UINavigationController
        navVC.popViewControllerAnimated(true)
    }
    var users = [PFObject: Bool]()
    var currentUser = PFUser.currentUser() as PFUser!
    var userCount = 0
    var refresher: UIRefreshControl!
    
    func refresh() {
        fetchUserQuery(userCount)
        self.refresher.endRefreshing()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserQuery(userCount)

        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.keys.count
    }

    func fetchUserQuery(skip: Int) {
        let query = PFQuery(className: "_User")
        query.skip = skip
        if let username = currentUser.username as String? {
            query.whereKey("username", notContainedIn: ["", username])
            query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, err: NSError?) -> Void in
                if let results = results as [PFObject]? {
                    self.userCount += results.count
                    for result in results {
                        self.users[result] = false
                    }
                    PFObject.pinAllInBackground(results)
                    self.fetchFollowsQuery(results)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchFollowsQuery(usersToQuery: [PFObject]) {
        let query = PFQuery(className: "Follow")
        
        query.whereKey("from", equalTo: PFUser.currentUser()!)
        query.includeKey("to")
        query.findObjectsInBackgroundWithBlock { (follows, err) -> Void in
            let follows = follows as [PFObject]?
            if err == nil && follows!.count != 0 {
                for follow in follows! {
                    self.handleUserFollow(follow)
                }
            } else { print(err) }
            self.tableView.reloadData()
        }
    }
    
    func handleUserFollow(follow: PFObject) -> Void {
        let userBeingFollowed = follow.objectForKey("to") as? PFUser
        self.users[userBeingFollowed!] = true
        follow.pinInBackgroundWithBlock({ (res, e) -> Void in })
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userFollow", forIndexPath: indexPath)
        let row = indexPath.row
        let userArray = Array(self.users.keys)
        if userArray.count > 0 {
            let user = userArray[row] as? PFUser
            cell.textLabel!.text = user?.username
            let followSwitch:UISwitch = UISwitch()
            cell.accessoryView = followSwitch
            let switchState = users[user!]
            followSwitch.setOn(switchState!, animated: true)
            followSwitch.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)

        }
        return cell
    }
    
    func makeOrDestroyFollow(username: String, followSwitch: UISwitch, makeFollow: Bool) -> Void {
        var userToFollow:PFObject?
        
        for (potentialUserToFollow, _) in users {
            if let storeUsername = potentialUserToFollow["username"] {
                let stringUsername = storeUsername as! String
                if stringUsername == username { userToFollow = potentialUserToFollow }
            }
        }
        if let userToFollow = userToFollow as PFObject? {
            let follow:PFObject = PFObject(className: "Follow")
            follow.setObject(userToFollow, forKey:"to")
            let currentUser = PFUser.currentUser()!
            follow.setObject(currentUser, forKey: "from")
            if makeFollow {
                follow.saveInBackgroundWithBlock({ (success, err) -> Void in
                    if success {
                        self.users[userToFollow] = true
                        follow.pinInBackground()
                    } else {
                        followSwitch.setOn(false, animated: true)
                    }
                })
            } else {
                let query = PFQuery(className: "Follow")
                query.fromLocalDatastore()
                query.whereKey("to", equalTo: userToFollow)
                query.whereKey("from", equalTo: PFUser.currentUser()!)
                query.findObjectsInBackgroundWithBlock({ (results, err) -> Void in
                    if err == nil {
                        self.users[userToFollow] = false
                        PFObject.deleteAllInBackground(results)
                    } else {
                        followSwitch.setOn(true, animated: true)
                    }
                })
            }
        }
    }
    
    
    func switchChanged(followSwitch: UISwitch) -> Void {
        
        let cell = followSwitch.superview as! UITableViewCell
        if let username = cell.textLabel!.text as String? {
            makeOrDestroyFollow(username, followSwitch: followSwitch, makeFollow: followSwitch.on)
        }
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
