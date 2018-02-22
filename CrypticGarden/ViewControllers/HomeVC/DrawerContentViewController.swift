//
//  DrawerPreviewContentViewController.swift
//  Pulley
//
//  Created by Brendan Lee on 7/6/16.
//  Copyright © 2016 52inc. All rights reserved.
//

import UIKit
import GooglePlaces
import Alamofire


class DrawerContentViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var gripperView: UIView!
    @IBOutlet var topSeparatorView: UIView!
    @IBOutlet var bottomSeperatorView: UIView!
    
    @IBOutlet var gripperTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var placeHolderView: UIView!
    
    var currentLocation:CGLocation? { didSet { setCurrentLocation() } }
    
    var autoCompletes = [GMSAutocompletePrediction]()
    var autoCompleteRequest:DataRequest?
    var autocompleteStarted = false
    
    var isInSearchMode = false { didSet { setSearchMode() } }
    
    var messages = [CGMessage]()
    
    // We adjust our 'header' based on the bottom safe area using this constraint
    @IBOutlet var headerSectionHeightConstraint: NSLayoutConstraint!
    
    fileprivate var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            loadViewIfNeeded()
            
            // We'll configure our UI to respect the safe area. In our small demo app, we just want to adjust the contentInset for the tableview.
            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gripperView.layer.cornerRadius = 2.5
        
        autofillSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // You must wait until viewWillAppear -or- later in the view controller lifecycle in order to get a reference to Pulley via self.parent for customization.
    
        // UIFeedbackGenerator is only available iOS 10+. Since Pulley works back to iOS 9, the .feedbackGenerator property is "Any" and managed internally as a feedback generator.
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            (parent as? PulleyViewController)?.feedbackGenerator = feedbackGenerator
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setSearchMode() {
        
        UIView.animate(withDuration: 0.1) {
            self.placeHolderView.alpha = self.isInSearchMode ? 0 : self.messages.count == 0 ? 1 : 0
            self.tableView.alpha = self.isInSearchMode ? 1 : self.messages.count == 0 ? 0 : 1
        }

        UIView.transition(with: tableView, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        }) { (ended) in
            //
        }
        
        if !isInSearchMode, let loc = currentLocation {
            messages = loc.messages ?? []
            searchBar.text = loc.googleName            
        }
    }
    
    func setCurrentLocation() {
        
        if let loc = currentLocation {
            messages = loc.messages ?? []
            searchBar.text = loc.googleName
            isInSearchMode = false
            
        }
        else {
            messages = []
            searchBar.text = ""
            isInSearchMode = true
        }
        
        
    }
    
}

//************************************
// MARK: - Navigation
//************************************

extension DrawerContentViewController {
    
    @IBAction func newMessageButtonClicked(_ sender: Any) {
        
        if let newMessageNC = UIStoryboard(name: "NewMessage", bundle: nil).instantiateInitialViewController() as? UINavigationController {
            if let newMessageVC = newMessageNC.viewControllers[0] as? NewMessageVC {
                newMessageVC.locationToAdd = currentLocation
                newMessageVC.messageAddedAction = { [weak self] locationAdded, message in
                    
                    if locationAdded != self?.currentLocation {
                        APIConnector.getLocation(locationID: locationAdded.googlePlaceId, completion: { [weak self] (location) in
                            if location == nil { return }
                            if let parent = self?.parent as? PulleyViewController, let mapVC = parent.primaryContentViewController as? PrimaryContentViewController {
                                parent.setDrawerPosition(position: .collapsed, animated: true)
                                mapVC.mapView.filteredPlaces = [location!]
                                mapVC.mapView.mapView.centerOn(location!.coordinate, zoomLevel: 12, animated: true)
                                mapVC.selectAnnotation(location: location!)
                            }
                        })
                    }
                    else {
                        if self?.currentLocation?.messages != nil { self?.currentLocation?.messages?.insert(message, at: 0) }
                        else { self?.currentLocation?.messages = [message]}
                        self?.setCurrentLocation()
                        
                        
                    }
                    
                }
                present(newMessageNC, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func showNewMessageVC() {
        
    }
    
    func autoCompleteSearch(_ text:String) {
        
        //searchCompleter.queryFragment = text //apple auto complete (can't filter to adress only) OR
        
        googleAutoComplete(text) // need api key and sacrifice 60Mb OR
        
        //marksAutoComplete(string: text, previousResult: [MKSAutocompleteResult]()) //basic and efficient, you'll see
        
        
    }
    
    func googleAutoComplete(_ text:String) {
        
//        var autocompletes = [(name:String, value:[MKSAutocompleteResult])]()
        
        
        googleAddressAndTransitComplete(text) { [weak self] (addressesAutocomp) in
            
//            if addressesAutocomp.count > 0 {
//                autocompletes.append((name : "LOOK_AROUND".localized, value: addressesAutocomp))
//            }
//            self.autocompleteView.autocompletes = autocompletes
            
            self?.tableView.reloadData()
        }
        
        
    }
    
    func googleAddressAndTransitComplete(_ text:String, completion:@escaping ([MKSAutocompleteResult])->()) {
        
        var addressesAutocomp = [MKSAutocompleteResult]()
        let userCoord = LocationManager.shared.lastKnownCoord
        let bounds = userCoord == nil ? nil : GMSCoordinateBounds(coordinate: userCoord!, coordinate: userCoord!)
        
        //---------- GOOGLE AUTOCOMPLETE
        
        let filter = GMSAutocompleteFilter()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        GMSPlacesClient().autocompleteQuery(text, bounds: bounds, filter: filter, callback: {[weak self] (results, error) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = error {
                print("Autocomplete error ", error)
                return
            }
            if let results = results {
                for result in results {
                    let autoComp = MKSAutocompleteResult()
                    autoComp.autoString = result.attributedFullText.string
                    
                    autoComp.type = .address
                    addressesAutocomp.append(autoComp)
                    
                }
            }
            
            completion(addressesAutocomp)
            
            if results != nil {
                self?.autoCompletes = results!
            }
            
            
        })
        
    }
}




//************************************
// MARK: - Google places
//************************************

extension DrawerContentViewController {
    
    
    func getMapCenterCoordinate() -> CLLocationCoordinate2D {
        
        if let parent = self.parent as? PulleyViewController, let mapVC = parent.primaryContentViewController as? PrimaryContentViewController {
            parent.setDrawerPosition(position: .collapsed, animated: true)
            return mapVC.mapView.mapView.centerCoordinate
            
        }
        return CLLocationCoordinate2D()
    }
    
    func autofillSearchBar() {
        
        
        GMSPlacesClient().currentPlace(callback: {[weak self] (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList, let likelihood = placeLikelihoodList.likelihoods.first {
                
                let place = likelihood.place
                self?.searchBar.text = place.name
                let loc = CGLocation()
                loc.googleAddress = place.formattedAddress
                loc.googleName = place.name
                loc.coordinate = place.coordinate
                loc.googlePlaceId = place.placeID
                
                APIConnector.getLocation(locationID: place.placeID, completion: { [weak self] (location) in
                    if location == nil { return }
                    if let parent = self?.parent as? PulleyViewController, let mapVC = parent.primaryContentViewController as? PrimaryContentViewController {
                        mapVC.selectAnnotation(location: location!)
                    }
                })
                
                self?.currentLocation = loc
                
                
                
                
            }
        })
    }
}

//************************************
// MARK: - SearchBar
//************************************

extension DrawerContentViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if let drawerVC = parent as? PulleyViewController {
            drawerVC.setDrawerPosition(position: .open, animated: true)
        }
        
        isInSearchMode = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        autoCompleteRequest?.cancel()
        
        if !searchBar.isFirstResponder {
            autocompleteStarted = false
            resetSearch()
        }
        else {
            if searchText == "" {
                autocompleteStarted = false
                resetSearch()
            }
            else {
                autocompleteStarted = true
                autoCompleteSearch(searchText)
            }
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        //searchRequest?.cancel()
        
        enterSearch()
        
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        exitSearch()
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        commitSearch()
    }
    
    
    func enterSearch() {
        //setSearchResultHidden(true, animated: true)
        //resultView.setFaded(true)
//        APIConnector.googleLocalSearch(center: getMapCenterCoordinate()) { (_) in
//            //
//        }
        
    }
    
    func exitSearch() {
        //resultView.setFaded(false)
        isInSearchMode = false
    }
    
    func resetSearch() {
        autoCompletes = []
    }
    
    func commitSearch(autoComp:GMSAutocompletePrediction? = nil) {
        
        var autoComplete = autoComp
        if autoComp == nil, autoCompletes.count >= 1 {
            autoComplete = autoCompletes[0]
        }
        
        guard let placeId = autoComplete?.placeID else { return }
        
        searchBar.resignFirstResponder()
        searchBar.text = autoComp?.attributedPrimaryText.string
        
        GMSPlacesClient().lookUpPlaceID(placeId) { [weak self] (place, error) in
            
            if place == nil { return }
            var loc = CGLocation()
            
            loc.googleName = place!.name
            self?.searchBar.text = place!.name
            loc.googleAddress = place!.formattedAddress
            loc.coordinate = place!.coordinate
            loc.googlePlaceId = place!.placeID
            
            APIConnector.getLocation(locationID: place!.placeID, completion: { [weak self] (location) in
                if location != nil {
                    loc = location!
                }
                self?.currentLocation = loc
                if let parent = self?.parent as? PulleyViewController, let mapVC = parent.primaryContentViewController as? PrimaryContentViewController {
                    parent.setDrawerPosition(position: .collapsed, animated: true)
                    mapVC.mapView.filteredPlaces = [loc]
                    mapVC.mapView.mapView.centerOn(loc.coordinate, zoomLevel: 12, animated: true)
                    mapVC.selectAnnotation(location: loc)
                    
                }
                
                
            })
        }
        
        
        
    }
    
    
}

//************************************
// MARK: - TableView DataSource
//************************************

extension DrawerContentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isInSearchMode ? autoCompletes.count : messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isInSearchMode {
            let cell = tableView.dequeueReusableCell(withIdentifier: AutoCompCell.identifier, for: indexPath) as! AutoCompCell
            
            if autoCompletes.count > indexPath.row {
                let result = autoCompletes[indexPath.row]
                
                cell.mainLabel.text = result.attributedPrimaryText.string
                cell.subLabel.text  = result.attributedSecondaryText?.string
            }
            
            
            
            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
            
            if messages.count > indexPath.row {
                let message = messages[indexPath.row]
                
                cell.messageLabel.text = message.text
                cell.tagLabel.text  = message.tag
            }
            
            
            
            return cell
            
        }
        
    }

}

//************************************
// MARK: - TableView Delegate
//************************************

extension DrawerContentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isInSearchMode ? 81.0 : 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isInSearchMode {
            if autoCompletes.count > indexPath.row {
                let result = autoCompletes[indexPath.row]
                commitSearch(autoComp: result)
            }
        }
        
//        if let drawer = self.parent as? PulleyViewController {
//            let primaryContent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PrimaryTransitionTargetViewController")
//
//            drawer.setDrawerPosition(position: .collapsed, animated: true)
//
//            drawer.setPrimaryContentViewController(controller: primaryContent, animated: false)
//        }
    }
}

//************************************
// MARK: - Pulley Drawer ViewController Delegate
//************************************

extension DrawerContentViewController: PulleyDrawerViewControllerDelegate {

    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 68.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    // This function is called by Pulley anytime the size, drawer position, etc. changes. It's best to customize your VC UI based on the bottomSafeArea here (if needed).
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        // We want to know about the safe area to customize our UI. Our UI customization logic is in the didSet for this variable.
        drawerBottomSafeArea = bottomSafeArea
        
        /*
         Some explanation for what is happening here:
         1. Our drawer UI needs some customization to look 'correct' on devices like the iPhone X, with a bottom safe area inset.
         2. We only need this when it's in the 'collapsed' position, so we'll add some safe area when it's collapsed and remove it when it's not.
         3. These changes are captured in an animation block (when necessary) by Pulley, so these changes will be animated along-side the drawer automatically.
         */
        if drawer.drawerPosition == .collapsed {
            headerSectionHeightConstraint.constant = 68.0 + drawerBottomSafeArea
        }
        else {
            headerSectionHeightConstraint.constant = 68.0
        }
        
        // Handle tableview scrolling / searchbar editing
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .leftSide
        
        if drawer.drawerPosition != .open {
            searchBar.resignFirstResponder()
        }
        
        if drawer.currentDisplayMode == .leftSide {
            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            bottomSeperatorView.isHidden = drawer.drawerPosition == .collapsed
        }
        else {
            topSeparatorView.isHidden = false
            bottomSeperatorView.isHidden = true
        }
    }
    
    /// This function is called when the current drawer display mode changes. Make UI customizations here.
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        
        print("Drawer: \(drawer.currentDisplayMode)")
        gripperTopConstraint.isActive = drawer.currentDisplayMode == .bottomDrawer
    }
}


