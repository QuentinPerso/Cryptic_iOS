//
//  PrimaryTransitionTargetViewController.swift
//  Pulley
//
//  Created by Brendan Lee on 7/8/16.
//  Copyright © 2016 52inc. All rights reserved.
//

import UIKit

class PrimaryTransitionTargetViewController: UIViewController {

    
    @IBOutlet weak var textView: GrowingTextView!
    
    
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
