//
//  AutocompleteView.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 25/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit
import GooglePlaces

class AutocompleteView: UIView {

    @IBOutlet weak var tableView:UITableView!
    
    var didSelectSuggestion:((GMSAutocompletePrediction)->())?
    
    var autoCompletes = [GMSAutocompletePrediction]() {
    //var autocompletes = [(name:String, value:[MKSAutocompleteResult])]() {
        
        didSet {
            if autoCompletes.count == 0, tableView.alpha == 1  {
                UIView.animate(withDuration: 0.15, animations: {
                    self.tableView.alpha = 0
                })
                self.tableView.isUserInteractionEnabled = false
            }
            else if autoCompletes.count > 0, tableView.alpha == 0  {
                UIView.animate(withDuration: 0.15, animations: {
                    self.tableView.alpha = 1
                })
                self.tableView.isUserInteractionEnabled = true
            }
            self.tableView.reloadData()
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: AutoCompCell.identifier, bundle: nil), forCellReuseIdentifier: AutoCompCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let hit = super.hitTest(point, with: event)
        
        if hit == self { return nil }

        return hit
    }

}

//************************************
// MARK: - TableView DataSource
//************************************

extension AutocompleteView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompletes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
            let cell = tableView.dequeueReusableCell(withIdentifier: AutoCompCell.identifier, for: indexPath) as! AutoCompCell
            
            if autoCompletes.count > indexPath.row {
                let result = autoCompletes[indexPath.row]
                
                cell.mainLabel.text = result.attributedPrimaryText.string
                cell.subLabel.text  = result.attributedSecondaryText?.string
            }
            
            
            
            return cell
    }
    
}

//************************************
// MARK: - TableView Delegate
//************************************

extension AutocompleteView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if autoCompletes.count > indexPath.row {
            let result = autoCompletes[indexPath.row]
            didSelectSuggestion?(result)
        }
    }
}

