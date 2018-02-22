//
//  SearchVC.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 25/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import GooglePlaces

class SearchVC: UIViewController {
    
    @IBOutlet weak var searchBarViewHConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var switchMapButton: UIButton!
    
    @IBOutlet weak var mapButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapButtonTrailConstraint: NSLayoutConstraint!
    
    var autocompleteView: AutocompleteView!
    
    @IBOutlet weak var resultView: SearchResultView!

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
        
        searchBarViewHConstraint.constant = 50 + UIApplication.shared.statusBarFrame.size.height
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        autocompleteView = Bundle.main.loadNibNamed("AutocompleteView", owner: self, options: nil)?[0] as! AutocompleteView
        self.view.addSubview(autocompleteView)
        
        
        searchBar.placeholder = "SEARCH_P_O_TAG".localized
        
        setupSearchBar()
        
        setupKeyboard()
        
        setupViews()
        
        searchCompleter.delegate = self
        
        switchMapButton.layer.cornerRadius = 15
        switchMapButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        switchMapButton.layer.borderWidth = 1
        
        
        
        LocationManager.shared.startUpdatingLocation(oneShot: true) { (coord, error) in
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        callAPILocations()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        autocompleteView.frame = resultView.frame
        view.bringSubview(toFront: resultView)
        view.bringSubview(toFront: autocompleteView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBAction func mapButtonClicked(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        resultView.setMapMode(sender.isSelected)
        
        
    }
    
    @IBAction func newMessageButtonClicked(_ sender: Any) {
        
        if let newMessageNC = UIStoryboard(name: "NewMessage", bundle: nil).instantiateInitialViewController() {
            self.present(newMessageNC, animated: true, completion: nil)
        }
        
    }
    
}

//************************************
// MARK: - Actions and Navigation
//************************************

extension SearchVC {
    
    func setSearchResultHidden(_ hidden:Bool, animated:Bool) {
        
        resultView.setHidden(hidden)
        
        mapButtonTrailConstraint.constant = hidden ? -mapButtonWidthConstraint.constant : 4
        
        UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.view.layoutIfNeeded()
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
// MARK: - API Calls
//************************************

extension SearchVC {
    
    func callAPILocations() {
        
        _ = APIConnector.getLocations(viewport: self.resultView.mapResultView.mapView.viewportVisibleAnnot(), completion: { (locations, cancelled) in
            
            if locations == nil { return }
            self.resultView.places = locations!
            
        })
        
    }
    
    
}

//************************************
// MARK: - Initial conf
//************************************

extension SearchVC {
    
    func setupSearchBar(){
        
        searchBar.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1)
        
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
        
        switchMapButton.setTitle("MAP".localized, for: .normal)
        switchMapButton.setTitle("LIST".localized, for: .selected)
        
        autocompleteView.autocompletes = []
        autocompleteView.didSelectSuggestion = { autoSuggestion in
            
            if autoSuggestion.type == .tag {
                self.commitSearch(searchString: autoSuggestion.autoString)
            }
            else if autoSuggestion.type == .address {
                self.searchPlacesAroundSuggestion(string: autoSuggestion.autoString)
            }
            
        }
        
        //setSearchResultHidden(true, animated: false)
        resultView.clickFadedView = { [weak self] in self?.searchBar.resignFirstResponder() }
        resultView.clickPlaceAction = { [weak self] place in self?.showPlaceDetailVC(place: place)}
        resultView.mapResultView.mapReadyAction = {
            
            self.callAPILocations()
            
        }
        
    }
    
}


//************************************
// MARK: - Keyboard Handling
//************************************

extension SearchVC {
    
    func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillChange(notification:NSNotification) {
        
        let frameEnd = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue

        let convRect = self.view.convert(frameEnd!, from: nil)
        let yOffset = self.view.bounds.size.height - convRect.origin.y
        
        autocompleteView.tableView.contentInset.bottom = max(yOffset, 0) // -50 cause of tabBar
        
    }
    
}

//************************************
// MARK: - Search Bar delegate
//************************************

extension SearchVC : UISearchBarDelegate{
    
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
        resultView.setFaded(true)
        
    }
    
    func exitSearch() {
        resultView.setFaded(false)
    }
    
    func resetSearch() {
        autocompleteView.autocompletes = []
    }
    
}

//************************************
// MARK: - MKLocal Search Completer Delegate
//************************************

extension SearchVC: MKLocalSearchCompleterDelegate {
    
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

extension SearchVC {

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
    
    
    
    
    func searchPlacesAroundSuggestion(string:String) {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = string
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let coord = response?.mapItems[0].placemark.coordinate {
                self.commitSearch(searchString: string, aroundCoord: coord)
            }
        }
    }
    


    
    func commitSearch(searchString:String?, aroundCoord coord:CLLocationCoordinate2D? = nil) {

        if coord != nil {
            resultView.mapResultView.mapView.centerOn(coord!, zoomLevel: 13, animated: false)
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

