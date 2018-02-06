//
//  AutocompleteView.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 25/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit

class AutocompleteView: UIView, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView:UITableView!
    
    var didSelectSuggestion:((MKSAutocompleteResult)->())?
    
    var autocompletes = [(name:String, value:[MKSAutocompleteResult])]() {
        
        didSet {
            if autocompletes.count == 0, tableView.alpha == 1  {
                UIView.animate(withDuration: 0.15, animations: {
                    self.tableView.alpha = 0
                })
                self.tableView.isUserInteractionEnabled = false
            }
            else if autocompletes.count > 0, tableView.alpha == 0  {
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
        
        tableView.register(UINib(nibName: AutocompleteCell.identifier, bundle: nil), forCellReuseIdentifier: AutocompleteCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let hit = super.hitTest(point, with: event)
        
        if hit == self { return nil }

        return hit
    }
    
    //************************************
    // MARK: - Table view Data Source
    //************************************
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return autocompletes.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if autocompletes.count == 0 { return 0 }
        
        
        return autocompletes[section].value.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.identifier, for: indexPath) as! AutocompleteCell
        
        let result = autocompletes[indexPath.section].value[indexPath.row]
        
        cell.label.text = result.autoString
        
        if result.type      == .tag     { cell.typeImage.image = #imageLiteral(resourceName: "sugghashTag") }
        else if result.type == .address { cell.typeImage.image = #imageLiteral(resourceName: "suggAddress") }
        else if result.type == .notMKSPlace { cell.typeImage.image = #imageLiteral(resourceName: "suggestSearch") }
        else if result.type == .place   { cell.typeImage.image = #imageLiteral(resourceName: "suggPlace") }
        else if result.type == .curator { cell.typeImage.image = #imageLiteral(resourceName: "suggCurator") }

        return cell
        
        
        
    }
    
    //************************************
    // MARK: - Table view Delegate
    //************************************
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        didSelectSuggestion?(autocompletes[indexPath.section].value[indexPath.row])
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return autocompletes[section].name
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1)
       
        //header.textLabel?.font = UIFont.mksFont(family: .mtSerra, size: 15, weight: .regular)
//        header.textLabel?.frame = header.frame
//        header.textLabel?.textAlignment = .center
    }

}


// MARK: - -------------  CELL ----------------

class AutocompleteCell: UITableViewCell {
    
    static let identifier = "AutocompleteCell"
    
    @IBOutlet weak var typeImage: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
}
