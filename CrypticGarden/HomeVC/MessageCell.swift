//
//  PlaceTableCell.swift
//  CrypticGarden
//
//  Created by admin on 18/01/2018.
//  Copyright © 2018 Marks. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    static let identifier = "MessageCell"
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //***** rounded corner == need remove bg
//        self.backgroundColor = UIColor.clear
//        self.backgroundView = UIView()
        
    }
    
    
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
//
//        UIView.animate(withDuration: 0.15) {
//            self.alpha = highlighted ? 0.6 : 1
//        }
//
//    }
    
    
}
