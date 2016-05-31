//
//  User.swift
//  xBeacon
//
//  Created by Leandro on 5/30/16.
//  Copyright © 2016 BaDaSS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class User {
    var name: String?
    var phone: String?
    var email: String?
    var image: UIImage?
    
    var uid: String?
    
    let rootRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://project-8882172146800754293.appspot.com/profile-pics")
    
    init(major: String?, minor: String?) {
        self.rootRef.child("majorminor").observeSingleEventOfType(.Value, withBlock: { (info) in
            self.uid = info.value![major! + " " + minor!] as? String
            print(self.uid)
            
            self.rootRef.child("profile").child(self.uid!).observeSingleEventOfType(.Value, withBlock: { (info) in
                self.name = info.value!["Name"] as? String
                self.phone = info.value!["Phone"] as? String
                self.email = info.value!["E-mail"] as? String
                
                
                self.storageRef.child(self.uid!).dataWithMaxSize(INT64_MAX, completion: { (data, error) in
                    if let error = error {
                        print("error downloading user image")
                        print(error.localizedDescription)
                    } else {
                        self.image = UIImage.init(data: data!)
                    }
                })
            })
        })
        
    }
    
    
}
