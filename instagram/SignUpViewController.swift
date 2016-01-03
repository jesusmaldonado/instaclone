//
//  SignUpViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Jesus Maldonado on 12/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet var passwordInput: UITextField!
    @IBOutlet var usernameInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUp(sender: UIButton) {
        if let username = usernameInput.text as String? {
            if let password = passwordInput.text as String? {
                if password.characters.count > 0 && username.characters.count > 0 {
                    makeIndicator()
                    makeSignUpRequest(username, password: password)
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

    func makeSignUpRequest(username: String, password: String) -> Void {
        let user = PFUser()
        user.username = username
        user.password = password
        user.signUpInBackgroundWithBlock { (succeeded: Bool, err: NSError?) -> Void in
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            if err == nil {
                let navVC = self.parentViewController as! UINavigationController
                let loginVC = navVC.viewControllers[navVC.viewControllers.count - 2] as! LoginViewController
                loginVC.makeLoginRequest(username, password: password, signedUpUser: user)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.displayMessage(err!.userInfo["error"] as! String)
            }
        }
    }
    
    func displayMessage(errorMessage: String) -> Void {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
        let signUpController = self.presentingViewController!.presentedViewController! as UIViewController
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler:nil))
        signUpController.presentViewController(alert, animated: true, completion: nil)
            
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
