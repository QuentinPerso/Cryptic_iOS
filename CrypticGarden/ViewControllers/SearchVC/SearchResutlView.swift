//
//  SearchResutlView.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 25/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit

class SearchResultView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var messageLabel:UILabel!
    
    @IBOutlet weak var postButton:UIButton!
    
    @IBOutlet weak var mapResultView:SearchResultMapView!
    
    var clickPlaceAction:((CGLocation)->())?
    
    var clickFadedView:(()->())?
    
    private var fadeView = UIView()
    
    var places = [CGLocation]() {
        
        didSet {
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint(), animated: false)
            mapResultView.filteredPlaces = places
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: LocationTableCell.identifier, bundle: nil), forCellReuseIdentifier: LocationTableCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setMapMode(false)
        
        mapResultView.clickPlaceAction = { [weak self] place in  self?.clickPlaceAction?(place)}
        
        fadeView.backgroundColor = .black
        fadeView.alpha = 0
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(self.tapFadeView))
        fadeView.addGestureRecognizer(tapGest)
        addSubview(fadeView)
    }
    
    @objc func tapFadeView() {
        clickFadedView?()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let hit = super.hitTest(point, with: event)
        
        if hit == self { return nil }
        
        return hit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fadeView.frame = self.bounds
    }
    
    func setFaded(_ faded:Bool) {
        
        fadeView.isUserInteractionEnabled = faded
        
        UIView.animate(withDuration: 0.25) {
            self.fadeView.alpha = faded ? 0.5 : 0
        }
    }
    
    func setMapMode(_ mapMode:Bool){
        
        UIView.animate(withDuration: 0.2) { 
            self.mapResultView.alpha = mapMode ? 1:0
        }
        
    }
    
    func setHidden(_ hidden:Bool, animated:Bool = true) {
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = hidden ? 0 : 1
//            self.tableView.alpha = hidden ? 0 : 1
//            self.mapResultView.alpha = hidden ? 0 : 1
        })
        self.tableView.isUserInteractionEnabled = !hidden
        self.mapResultView.isUserInteractionEnabled = !hidden
    }
    
    //************************************
    // MARK: - Table view Data Source
    //************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return places.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableCell.identifier, for: indexPath) as! LocationTableCell
        
        let place = places[indexPath.row]
        
        
        cell.adressLabel.text = place.googleAddress
        cell.tagsLabel.text = place.mainTags?.joined(separator: ", ")
        
        cell.messagesNumberLabel.text = "\(place.messages?.count ?? 0)"
        
        return cell
        
    }
    
    func tapCell(tapGesture:UITapGestureRecognizer){
        
        let index = (tapGesture.view?.tag)!
        
        clickPlaceAction?(places[index])
  
    }

    //************************************
    // MARK: - Table view Delegate
    //************************************

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        clickPlaceAction?(places[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 93
    }
    
}
