//
//  NewMessageVC.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 25/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import GooglePlaces

class NewMessageVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    var autocompleteView: AutocompleteView!
    
    var locationToAdd:CGLocation!

//    var searchBarShouldBeginEditing = true
    
    var searchRequest:DataRequest?
    
    var autoCompleteRequest:DataRequest? //marks autocomplete
    
    let searchCompleter = MKLocalSearchCompleter() //apple auto complete (with delegate)
    
    //let placesClient =  //google autocomplete
    
    var autocompleteStarted = false

    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        autocompleteView = Bundle.main.loadNibNamed("AutocompleteView", owner: self, options: nil)?[0] as! AutocompleteView
        self.view.addSubview(autocompleteView)
        
        setupSearchBar()
        
        setupKeyboard()
        
        setupViews()
        
        searchCompleter.delegate = self

        LocationManager.shared.startUpdatingLocation(oneShot: true) { (coord, error) in
            self.autofillSearchBar()
            
        }
        
    }
    
    func autofillSearchBar() {
        
        GMSPlacesClient().currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList, let likelihood = placeLikelihoodList.likelihoods.first {
                
                let place = likelihood.place
                self.searchBar.placeholder = place.name
                let loc = CGLocation()
                loc.googleAddress = place.formattedAddress
                loc.coordinate = place.coordinate
                loc.googlePlaceId = place.placeID
                self.locationToAdd = loc
                
                
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        if navigationController != nil, navigationController?.viewControllers[0] != self  {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func clearDBClicked(_ sender: Any) {
        APIConnector.dropDataBase { (success) in
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var autocompleteRect = CGRect()
        autocompleteRect.origin.y = searchBar.frame.origin.y + searchBar.frame.size.height
        autocompleteRect.size.width = self.view.frame.size.width
        autocompleteRect.size.height = self.view.frame.size.height - autocompleteRect.origin.y
        autocompleteView.frame = autocompleteRect

        view.bringSubview(toFront: autocompleteView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBAction func postButtonClicked(_ sender: Any) {
        
        let message = CGMessage()
        message.text = messageTextView.text
        message.tag = tagTextField.text
        
        self.dismiss(animated: true, completion: nil)
        
        APIConnector.postMessage(message, toLocation: locationToAdd) { (success) in
            print("new mess")
        }
        
    }
    
    
}

//************************************
// MARK: - Actions and Navigation
//************************************

extension NewMessageVC {
    
    func setSearchResultHidden(_ hidden:Bool, animated:Bool) {
        
       // resultView.setHidden(hidden)
        
        UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
        }, completion: nil)
    
//        UIView.animate(withDuration: animated ? 0.2 : 0) {
//            self.view.layoutIfNeeded()
//        }
        
        
    }
    
    func showPlaceDetailVC(place:CGLocation){
        
//        let detailVC = UIStoryboard(name: "PlaceDetails", bundle: nil).instantiateInitialViewController() as! PlaceDetailVC
//
//        detailVC.place = place
//
//
//        self.navigationController?.show(detailVC, sender: nil)
        
    }
    
    
}

//************************************
// MARK: - Initial conf
//************************************

extension NewMessageVC {
    
    func setupSearchBar(){
        
        //searchBar.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1)
        
        self.searchBar.delegate = self
        
        searchBar.backgroundImage = UIImage()
        
        
//        if let textField = self.searchBar.value(forKey: "searchField") as? UITextField {
//            //Magnifying glass
//            if let glassIconView = textField.leftView as? UIImageView {
//                glassIconView.image = #imageLiteral(resourceName: "search")
//                glassIconView.tintColor = UIColor.white
//            }
//
//            let buttonAttribute = [NSForegroundColorAttributeName : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
//                                   NSFontAttributeName : UIFont(name: "Montserrat-Light", size: 13)!] as [String : Any]
//
//            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(buttonAttribute, for: .normal)
//
//            textField.textColor = UIColor.white
//            textField.tintColor = UIColor.white
//
//            textField.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)// #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1508989726)
//            textField.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1508989726).cgColor
//            textField.layer.cornerRadius = 2
//            textField.clipsToBounds = true
//
//
//            searchBar.setImage(#imageLiteral(resourceName: "crossSearch"), for: UISearchBarIcon.clear, state: .normal)
//            searchBar.setImage(#imageLiteral(resourceName: "crossSearch"), for: UISearchBarIcon.clear, state: .highlighted)
//
//        }
        
        
        
    }
    
    func setupViews() {
        
        autocompleteView.autocompletes = []
        autocompleteView.didSelectSuggestion = { autoSuggestion in
            self.searchGooglePlaceDetail(autocomp: autoSuggestion)
            
            
            
        }
        
        //setSearchResultHidden(true, animated: false)
        //resultView.clickFadedView = { [weak self] in self?.searchBar.resignFirstResponder() }

        
    }
    
}


//************************************
// MARK: - Keyboard Handling
//************************************

extension NewMessageVC {
    
    func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillChange(notification:NSNotification) {
        
        let frameEnd = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue

        let convRect = self.view.convert(frameEnd!, from: nil)
        let yOffset = self.view.bounds.size.height - convRect.origin.y
        
        autocompleteView.tableView.contentInset.bottom = max(yOffset, 0) // -50 cause of tabBar
        messageTextView.contentInset.bottom = max(yOffset, 0)
    }
    
}

//************************************
// MARK: - Search Bar delegate
//************************************

extension NewMessageVC : UISearchBarDelegate{
    
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
        
        searchRequest?.cancel()
        
        enterSearch()
        
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        exitSearch()
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        commitSearch(searchString: searchBar.text)
    }
    
    
    func enterSearch() {
        //setSearchResultHidden(true, animated: true)
        //resultView.setFaded(true)
        
    }
    
    func exitSearch() {
        //resultView.setFaded(false)
    }
    
    func resetSearch() {
        autocompleteView.autocompletes = []
    }
    
}

//************************************
// MARK: - MKLocal Search Completer Delegate
//************************************

extension NewMessageVC: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
//        //TODO: do something when current city == nil
//        var autocompletes = [MKSAutocompleteResult]()
//        for result in completer.results {
//
//            var alreadyIn = false
//            for alreadyInResutl in autocompletes {
//                if alreadyInResutl.autoString == result.title {
//                    alreadyIn = true
//                    break
//                }
//            }
//            if alreadyIn { continue }
//
//            let autoComp = MKSAutocompleteResult()
//            autoComp.autoString = result.title + result.subtitle
//            autoComp.type = .address
//            autocompletes.append(autoComp)
//        }
        
//        self.marksAutoComplete(string: searchCompleter.queryFragment, previousResult: autocompletes)
        
        
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

//************************************
// MARK: - Search methods
//************************************

extension NewMessageVC {

    func autoCompleteSearch(_ text:String) {
        
        //searchCompleter.queryFragment = text //apple auto complete (can't filter to adress only) OR
        
        googleAutoComplete(text) // need api key and sacrifice 60Mb OR
        
        //marksAutoComplete(string: text, previousResult: [MKSAutocompleteResult]()) //basic and efficient, you'll see
        
        
    }
    
    func googleAutoComplete(_ text:String) {

        var autocompletes = [(name:String, value:[MKSAutocompleteResult])]()
        
        
        googleAddressAndTransitComplete(text) { (addressesAutocomp) in
            
            if addressesAutocomp.count > 0 {
                autocompletes.append((name : "LOOK_AROUND".localized, value: addressesAutocomp))
            }
            
            self.autocompleteView.autocompletes = autocompletes
            
        }
        
        
    }
    
    func googleAddressAndTransitComplete(_ text:String, completion:@escaping ([MKSAutocompleteResult])->()) {
        
        var addressesAutocomp = [MKSAutocompleteResult]()
        let userCoord = LocationManager.shared.lastKnownCoord
        let bounds = userCoord == nil ? nil : GMSCoordinateBounds(coordinate: userCoord!, coordinate: userCoord!)
        
        //---------- GOOGLE AUTOCOMPLETE
    
        let filter = GMSAutocompleteFilter()

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        GMSPlacesClient().autocompleteQuery(text, bounds: bounds, filter: filter, callback: {(results, error) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil {
                return
            }
            if let results = results {
                for result in results {
                    let autoComp = MKSAutocompleteResult()
                    autoComp.autoString = result.attributedFullText.string
                    autoComp.googlePlaceId = result.placeID
                    autoComp.type = .address
                    addressesAutocomp.append(autoComp)
                    
                }
            }
            completion(addressesAutocomp)
            
        })
        
    }
    //ChIJAQBcJONt5kcRXzii9oCDbcQ -> minute buzz GGiD
    //ChIJ_4-amHVu5kcRf8IrZpgcorM -> parrot GGiD
    //ChIJYUCKonVu5kcRoUBXJc_Ic0U -> 174 quai de Jemmapes GGiD
    
    
//    func googlePlacesComplete(_ text:String, completion:@escaping ([MKSAutocompleteResult])->()) {
//
//        var addressesAutocomp = [MKSAutocompleteResult]()
//        guard let userCoord = LocationManager.shared.lastKnownCoord else { return }
//        var bounds = GMSCoordinateBounds(coordinate: userCoord, coordinate: userCoord)
//        if let cityVp = currentCity?.viewport {
//            bounds = GMSCoordinateBounds(coordinate: cityVp.northEast, coordinate: cityVp.southWest)
//        }
//
//        //---------- GOOGLE PLACES
//
//        let filter = GMSAutocompleteFilter()
//        filter.type = .establishment
//
//        placesClient.autocompleteQuery(text, bounds: bounds, filter: filter, callback: {(results, error) -> Void in
//
//
//            if let error = error {
//                NSLog("Autocomplete error %@", error.localizedDescription)
//                return
//            }
//            if let results = results {
//                for result in results {
//                    let autoComp = MKSAutocompleteResult()
//                    autoComp.autoString = result.attributedFullText.string
//                    autoComp.type = .notMKSPlace
//                    autoComp.objectID = result.placeID
//                    addressesAutocomp.append(autoComp)
//
//                }
//            }
//            completion(addressesAutocomp)
//
//        })
//
//    }
    
    
    
    
    func searchGooglePlaceDetail(autocomp:MKSAutocompleteResult) {
        
        searchBar.resignFirstResponder()
        searchBar.text = autocomp.autoString
        autocompleteView.autocompletes = []
        
        GMSPlacesClient().lookUpPlaceID(autocomp.googlePlaceId) { (place, error) in
            
            if place == nil { return }
            let loc = CGLocation()
            loc.googleAddress = place!.formattedAddress
            loc.coordinate = place!.coordinate
            loc.googlePlaceId = place!.placeID
            self.locationToAdd = loc
            
        }
    }
    


    
    func commitSearch(searchString:String?, aroundCoord coord:CLLocationCoordinate2D? = nil) {

        if coord != nil {
            //resultView.mapResultView.mapView.centerOn(coord!, zoomLevel: 13, animated: false)
        }
        
        searchBar.resignFirstResponder()
        guard let searchString = searchString else { return }
        
        searchBar.text = searchString
        
//        searchRequest = APIConnector.searchPlaces(searchString: searchString, aroundCoord: coord, cityK: cityId!) { (resultPlaces, canceled) in
//
//            if canceled { return }
//
//            var places = [MKSPlace]()
//            if resultPlaces != nil { places = resultPlaces! }
//
//            self.resultView.places = places
//            self.setSearchResultHidden(false, animated: true)
//
//            //log analitycs
//            let idsArray = places.map({ (place) -> String in
//                return place.uniqueId
//            })
//
//            let properties = ["search" : searchString,
//                              "result type" : "places",
//                              "result number" : places.count,
//                              "ids array" : idsArray.joined(separator: ",")] as [String : Any]
//            LogManager.appSeeSearchEvent(event: "search", properties: properties as [String : AnyObject])
//
//        }
    }
    
    
}

