//
//  TrendingSearchView.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 25/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit

class TrendingSearchView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    
    var buttonClickedAction:((String?)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = "TRENDING".localized
        
//        for but in buttons {
//            but.alpha = 0
//            but.addTarget(self, action: #selector(self.trendyButtonClicked(_:)), for: .touchUpInside)
//        }

        
    }
    
    func setFaded(_ faded:Bool) {
        for but in buttons {
            but.isUserInteractionEnabled = !faded
        }
        UIView.animate(withDuration: 0.25) {  self.alpha = faded ? 0.6 : 1 }
    }
    
    func trendyButtonClicked(_ sender: UIButton) {

        buttonClickedAction?(sender.title(for: .normal))
        
    }
    

}
