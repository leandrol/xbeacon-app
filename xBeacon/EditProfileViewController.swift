//
//  EditProfileViewController.swift
//  xBeacon
//
//  Created by Leandro on 5/27/16.
//  Copyright © 2016 BaDaSS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class EditProfileViewController: UIViewController {
    
    //Constants
    var rootRef = FIRDatabase.database().reference()
    
    //Outlets
    @IBOutlet var nameField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet var emailField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Retrieve profile info from Firebase and set the text fields to the appropriate value
        if let user = FIRAuth.auth()?.currentUser {
            
            self.rootRef.child("profile").child(user.uid).observeSingleEventOfType(.Value, withBlock: { (info) in
            
                let name = info.value!["Name"] as! String
                let phone = info.value!["Phone"] as! String
                let email = info.value!["E-mail"] as! String
            
                self.nameField.text = name
                self.phoneField.text = phone
                self.emailField.text = email
            
            }) { (error) in
                print(error.localizedDescription)
                print("Could not import contact info")
            }
        } else {
            print("userid is nil, unable to import contact info")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Actions
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        
        print("Saving Profile...")
        
        // Update the profile info simultaneously and check for errors
        let updatedInfo = ["Name" : self.nameField.text!,
                           "Phone" : self.phoneField.text!,
                           "E-mail" : self.emailField.text!]
        if let user = FIRAuth.auth()?.currentUser {
            rootRef.child("profile").child(user.uid).updateChildValues(updatedInfo, withCompletionBlock: { (error, ref) in
                if error == nil {
                    print("save success")
                    self.performSegueWithIdentifier("SaveProfile", sender: self)
                } else {
                    print("error saving")
                }
            })
        } else {
            print("failed to save profile")
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
