//
//  ChatContainerVC.swift
//  CrypticGarden
//
//  Created by Quentin Beaudouin on 25/02/2018.
//  Copyright © 2018 Marks. All rights reserved.
//

import UIKit
import Firebase

class ChatContainerVC: UIViewController {

    var channelRef: DatabaseReference?
    var channel: CGMessage?
    var senderDisplayName:String?
    
    @IBOutlet weak var headerTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle.text = channel?.text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier ?? ""
        
        switch segueID {
            
        case "embedChatVC":
            let chatVC = segue.destination as! ChatViewController
            chatVC.senderDisplayName = senderDisplayName
            chatVC.channel = channel
            chatVC.channelRef = channelRef
        default:
            break
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) { self.navigationController?.popViewController(animated: true)
    }
    
}
