//
//  ProfileViewController.swift
//  xBeacon
//
//  Created by Stanley Phu on 6/1/16.
//  Copyright © 2016 BaDaSS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    var currentUser: User?
    var linkedinString: String = ""
    
    //Outlets
    @IBOutlet var nameField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var profilePicButton: UIButton!
    @IBOutlet weak var linkedinButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let user = currentUser {

            nameField.text = user.name

            phoneField.text = user.phone

            emailField.text = user.email

            linkedinString = user.linkedin!
print("a")
            linkedinButton.setTitle(("Connect with " + user.name! + ""), forState: .Normal)
            print("b")
            profilePicButton.setImage(user.image, forState: .Normal)


        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func linkedinButtonClicked(sender: AnyObject) {
        let linkedinDeepURLSplitArray = linkedinString.componentsSeparatedByString("linkedin.com/")
        let url = NSURL(string: "linkedin://" + linkedinDeepURLSplitArray[linkedinDeepURLSplitArray.count-1])!
        
        if (UIApplication.sharedApplication().canOpenURL(url)) {
            UIApplication.sharedApplication().openURL(url)
        }
        else{
            let title = "LinkedIn App not Installed"
            let message = "It seems that the LinkedIn app is not installed. For connections to work, please download the LinkedIn app."
            let cancelButtonTitle = "OK"
            
            let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction.init(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction);
            self.presentViewController(alertController, animated: true, completion: nil)
        
        }
        
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
