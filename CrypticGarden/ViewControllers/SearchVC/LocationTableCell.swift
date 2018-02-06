//
//  PlaceTableCell.swift
//  CrypticGarden
//
//  Created by admin on 18/01/2018.
//  Copyright © 2018 Marks. All rights reserved.
//

import UIKit

class LocationTableCell: UITableViewCell {
    
    static let identifier = "LocationTableCell"
    
    @IBOutlet weak var placeContainerView: UIView!
    
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var messagesNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //***** rounded corner == need remove bg
        self.backgroundColor = UIColor.clear
        self.backgroundView = UIView()
        
        
        
        
    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.15) {
            self.alpha = highlighted ? 0.6 : 1
        }
        
        
    }
    
    
}
