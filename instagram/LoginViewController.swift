/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class LoginViewController: UIViewController {
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    @IBOutlet var passwordInput: UITextField!
    @IBOutlet var usernameInput: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

//       PFUser.logInWithUsernameInBackground("kono", password: "kono", block: { (user, err) -> Void in
//            self.presentFollowFeed()
//        })
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func login(sender: UIButton) {
        if let username = usernameInput.text as String? {
            if let password = passwordInput.text as String? {
                if password.characters.count > 0 && username.characters.count > 0 {
                    makeIndicator()
                    makeLoginRequest(username, password: password, signedUpUser: nil)
                } else {
                    displayMessage("username and password required")
                }
            }
            else {
                displayMessage("password is required")
            }
        } else {
            displayMessage("username is required")
        }
    }
    
    func makeLoginRequest(username: String, password: String, signedUpUser: PFUser?) {
        let currentUser = PFUser.currentUser()
        if currentUser != nil && currentUser == signedUpUser {
            presentFollowFeed()
        } else {
            if currentUser != nil { PFUser.logOut() }
            PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, err: NSError?) -> Void in
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
                if user != nil {
                    self.presentFollowFeed()
                    self.clearInput()
                } else {
                    self.displayMessage(err!.userInfo["error"] as! String)
                }
            }
        }
    }
    
    func clearInput() {
        self.passwordInput.text = nil
        self.usernameInput.text = nil
    }
    
    func presentFollowFeed() -> Void {
        performSegueWithIdentifier("presentFollowTableView", sender: self)
    }
    
    func makeIndicator() -> Void {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    
    func displayMessage(errorMessage: String) -> Void {
            let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
