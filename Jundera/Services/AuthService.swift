//
//  AuthService.swift
//  Balapoint
//
//  Created by David S on 11/14/17.
//  Copyright © 2017 David S. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AuthService {
    /// SIGN IN
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
        
    }
    /// SIGN UP
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
       
        let usersDB = Database.database().reference()
        var taken = false
        usersDB.child("users").queryOrdered(byChild:"username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                taken = true
                print("Username is not available.")
                usernameAlert()
            }
            if !taken {
                print("Username is available")
                Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in
                    if error != nil {
                        onError(error!.localizedDescription)
                        print("Failed to create user:", error!)
                        return
                    }
                    
                    guard let result = user else {
                        return
                    }
                    let uid = result.user.uid
                    
                    let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("profile_image").child(uid)
                    
                    storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            return
                        }
                        storageRef.downloadURL(completion: { (url, error) in
                            if let profileImageUrl = url?.absoluteString {
                                self.setUserInfomation(profileImageUrl: profileImageUrl, username: username, email: email, uid: uid, onSuccess: onSuccess)
                            }
                        })
                    })
                })
            }
        })
    }
    
    // SET USER INFO
    static func setUserInfomation(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["username": username.lowercased(), "username_lowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl])
        onSuccess()
    }
    
    // UPDATE USER INFO
    static func updateUserInfor(username: String, email: String, bio: String, website: String, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        Api.Userr.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                let uid = Api.Userr.CURRENT_USER?.uid
                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("profile_image").child(uid!)
                
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        return
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if let profileImageUrl = url?.absoluteString {
                            self.updateDatabase(profileImageUrl: profileImageUrl, username: username, email: email, bio: bio, website: website, onSuccess: onSuccess, onError: onError)
                        }
                    })
                })
            }
        })
        
    }
    // UPDATE DATABASE WITH USER INFO
    static func updateDatabase(profileImageUrl: String, username: String, email: String, bio: String, website: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        let dict = ["username": username, "username_lowercase": username.lowercased(), "email": email, "bio": bio, "website": website,
                    "profileImageUrl": profileImageUrl]
        Api.Userr.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
            
        })
    }
    
    // LOG OUT
    static func logout(onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSuccess()
            
        } catch let logoutError {
            onError(logoutError.localizedDescription)
        }
    }
    
    // Alert for username existing
    static func usernameAlert() {
        let alertController = UIAlertController(title: "Sorry", message: "This username has already been taken. Please try another.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: { (alert) in
            print("alert")
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(alertAction)
        alertController.presentInOwnWindow(animated: true, completion: {
        })
    }
}


