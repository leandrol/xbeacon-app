//
//  ViewController.swift
//  xBeacon
//
//  Copyright © 2016 BaDaSS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {
    // Constants
    var rootRef = FIRDatabase.database().reference()
    // Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textFieldLoginEmail.delegate = self
        textFieldLoginPassword.delegate = self
        errorLabel.hidden = true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Actions
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func loginDidTouch(sender: AnyObject) {
        FIRAuth.auth()?.signInWithEmail(textFieldLoginEmail.text!, password: textFieldLoginPassword.text!) { (user, error) in
            
            if error == nil {
                
                // Go to main screen
                self.performSegueWithIdentifier("Login", sender: self)
                
            }
            else {
                self.errorLabel.text = "* Invalid username or password *"
                self.errorLabel.hidden = false
            }
        }
    }
    
    // Return key going to next field or if on password, return key logs user in.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.textFieldLoginEmail {
            self.textFieldLoginPassword.becomeFirstResponder()
        } else if textField == self.textFieldLoginPassword {
            self.textFieldLoginPassword.resignFirstResponder()
            self.loginDidTouch(self)
        }
        
        return true
    }
    
    // Creating a new user to Firebase
    @IBAction func signUpDidTouch(sender: AnyObject) {
        
        
        //Setup major minor for this user
        let majorminorRef = self.rootRef.child("majorminor")
        
        //setup profile for user
        let profileRef = self.rootRef.child("profile")

        
        //Generate random ints from 0->65533 (Max value for major minor is 65535)
        let tempMajor = Int(arc4random_uniform(65533)+1)
        let tempMinor = Int(arc4random_uniform(65533)+1)
        
        
        let alert = UIAlertController(title: "Register",
                                      message: "Register for an xBeacon account.",
                                      preferredStyle: .Alert)
        
        // Save the new user and assign unique major and minor values to them.
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default) { (action: UIAlertAction) -> Void in
                                        let emailField = alert.textFields![0]
                                        let passwordField = alert.textFields![1]
                                        var userID = ""
                                        FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!) { (user, error) in
                                            if error == nil {
                                                
                                                FIRAuth.auth()!.addAuthStateDidChangeListener() { (auth, user) in
                                                    if let user = user {
                                                        userID = user.uid;
                                                        print("User is signed in with uid:", user.uid)
                                                        
                                                        //Setup profile with Major and Minor
                                                        profileRef.child(userID).child("Major").setValue(tempMajor)
                                                        profileRef.child(userID).child("Minor").setValue(tempMinor)
                                                        
                                                        //Initialize contact info for each profile
                                                        profileRef.child(userID).child("Name").setValue("")
                                                        profileRef.child(userID).child("E-mail").setValue(user.email!)
                                                        profileRef.child(userID).child("Phone").setValue("")
                                                        
                                                        //User id stored in db as "MajorValue MinorValue"
                                                        //When another device is found, uses values to make key as above and get user id (which is immutable)
                                                        //From there access another db containing information on profile of user via uid
                                                        majorminorRef.child(String(tempMajor) + " " + String(tempMinor)).setValue(userID)
                                                        

                                                        
                                                        
                                                    } else {
                                                        print("No user is signed in.")
                                                    }
                                                }
                                                
                                                
                                                
                                                
                                                FIRAuth.auth()?.signInWithEmail(emailField.text!, password: passwordField.text! ) { (user, error) in
                                                }
                                                
                                                self.performSegueWithIdentifier("Login", sender: self)

                                            }
                                        }
                                        
                                        
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textEmail) -> Void in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textPassword) -> Void in
            textPassword.secureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
                              animated: true,
                              completion: nil)
    }


}

