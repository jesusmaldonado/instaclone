//
//  UploadViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Jesus Maldonado on 12/31/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UploadViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var importOrUploadButton: UIButton!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var captionInput: UITextField!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var imageUploaded = false
    
    @IBAction func importOrUpload(button: UIButton) {
        let title = button.titleLabel?.text
        if title == "Import" {
            pickImage()
     
        } else if title == "Upload" {
            uploadPicture()
        }
    }
    
    func pickImage() -> Void {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func uploadPicture() -> Void {
        var caption: String
        if captionInput.text == nil {
            caption = ""
        } else {
            caption = captionInput.text!
        }
        if imageUploaded == true {
            let newImage = PFObject(className: "Photo")
            newImage.setObject(PFUser.currentUser()!, forKey: "user")
            let imageData = UIImagePNGRepresentation(imageView.image!)
            let imageFile = PFFile(name: "lol.png", data: imageData!)
            newImage.setValue(caption, forKey: "caption")
            newImage.setObject(imageFile!, forKey: "imageFile")
            makeIndicator()
            newImage.saveInBackgroundWithBlock(uploadComplete)
        } else {
            displayMessage("Image is required")
        }
    }
    
    func uploadComplete(succeeded: Bool, err: NSError?) -> Void {
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        if succeeded {
            clearImage()
            displayMessage("Successful Upload")
        } else {
            displayMessage(err!.userInfo["error"] as! String)
        }
    }
    
    func clearImage() -> Void {
        let path:String! = NSBundle.mainBundle().pathForResource("upload", ofType: ".png") as
        String!
        imageView.image = UIImage(contentsOfFile: path)
        captionInput.text = nil
        imageUploaded = false
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        importOrUploadButton.titleLabel?.text = "Upload"
        self.dismissViewControllerAnimated(true, completion: nil)
        imageUploaded = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
