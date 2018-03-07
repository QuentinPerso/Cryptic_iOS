//
//  PrimaryTransitionTargetViewController.swift
//  Pulley
//
//  Created by Brendan Lee on 7/8/16.
//  Copyright © 2016 52inc. All rights reserved.
//

import UIKit
import Firebase

class UserProfileVC: UIViewController {

    @IBOutlet weak var connectButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let bTitle = (Auth.auth().currentUser?.uid == nil) ? "Connect" : "Disconnect"
        connectButton.setTitle(bTitle, for: .normal)
    }
    
    @IBAction func connectButtonClicked(_ sender: UIButton) {
        
        if Auth.auth().currentUser?.uid != nil {
            try! Auth.auth().signOut()
            connectButton.setTitle("Connect", for: .normal)
        }
        else {
            firebasePhoneConnect()
        }
        
        
    }
    
    @IBAction func goBackButtonPressed(sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
        
//        if let drawer = self.parent as? PulleyViewController {
//            let primaryContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PrimaryContentViewController")
//
//            drawer.setPrimaryContentViewController(controller: primaryContent, animated: true)
//        }
    }
    
    @IBAction func clearDBClicked(_ sender: Any) {
        APIConnector.dropDataBase { (success) in
            
        }
    }
}
