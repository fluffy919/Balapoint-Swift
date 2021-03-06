//
//  UserSettingsTableViewController.swift
//  Balapoint
//
//  Created by David S on 8/19/18.
//  Copyright © 2018 David S. All rights reserved.

//  Allows user to view settings.

import UIKit
import Firebase

protocol UserSettingTableViewControllerDelegate {
    func updateUserSettings()
}

class UserSettingsTableViewController: UITableViewController {
    
     var delegate: UserSettingTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Futura", size: 18)!]
        setBackButton()
    }
    
//    @IBAction func goToTermsPage(_ sender: Any) {
//        if let url = URL(string: "https://www.balapoint.com/terms.html") {
//            UIApplication.shared.open(url, options: [:])
//        }
//    }
    
    @IBAction func goToPrivacyPage(_ sender: Any) {
        if let url = URL(string: "https://app.termly.io/document/privacy-policy/e0616598-966c-4640-82f6-442bfc25f28b") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    // Logout
    @IBAction func logoutBtn_TouchUpInside(_ sender: Any) {
        AuthService.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errorMessage) in
            print("ERROR: \(String(describing: errorMessage))")
        }
    }
    
    // Delete Account
    @IBAction func deleteAccount_TouchUpInside(_ sender: Any) {
        let controller = UIAlertController(title:"Are you sure?", message: "Deleting your account will delete your posts and information.", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Yes, I'm sure.", style: .destructive, handler: { (_) in
            let user = Auth.auth().currentUser

            user?.delete { error in
                if let error = error {
                    print("There was an error deleting this user: \(error)")
                } else {
                    Auth.auth().currentUser?.delete()
                    print("Successfully deleted account")
                    let storyboard = UIStoryboard(name: "Start", bundle: nil)
                    let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
                    self.present(signInVC, animated: true, completion: nil)
                }
            }
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 
//    }
}
