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
import Firebase

class NewMessageVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var bottomBarBotConstraint: NSLayoutConstraint!
    var bottomBarInitialSize:CGFloat = 0.0
    
    var autocompleteView: AutocompleteView!
    
    var locationToAdd:CGLocation!
    
    var messageAddedAction:((_ location:CGLocation, _ message:CGMessage)->())?
    
    var searchRequest:DataRequest?
    
    var autoCompleteRequest:DataRequest? //marks autocomplete

    var autocompleteStarted = false
    
    // FireBase Chat Channels
    private var channelRefHandle: DatabaseHandle?
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    

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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var autocompleteRect = CGRect()
        let topPoint = searchBar.convert(searchBar.frame.origin, to: self.view)
        autocompleteRect.origin.y = topPoint.y //+ searchBar.frame.size.height
        autocompleteRect.size.width = self.view.frame.size.width
        autocompleteRect.size.height = self.view.frame.size.height - autocompleteRect.origin.y
        autocompleteView.frame = autocompleteRect

        view.bringSubview(toFront: autocompleteView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    
    
    
}

//************************************
// MARK: - Actions and Navigation
//************************************

extension NewMessageVC {
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        if navigationController != nil, navigationController?.viewControllers[0] != self  {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func postButtonClicked(_ sender: Any) {
        
        var alertMessage:String?
        
        if messageTextView.text == nil || messageTextView.text == ""  {
            alertMessage = "You didn't enter any message ! 🤔"
        }
        else if tagTextField.text == nil  || tagTextField.text == "" {
            alertMessage = "Tags aren't optional ! 😈"
        }
        
        if let mess = alertMessage {
            let alertController = UIAlertController(title: "Alert !", message: mess, preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
            return
        }

        let tag = tagTextField.text
        
        //**********
        //create Firebase entry for the message
        let newChannelRef = channelRef.childByAutoId()
        let channelItem = [
            "name": tag
        ]
        newChannelRef.setValue(channelItem)
        //***********
        
        let message = CGMessage()
        message.text = messageTextView.text
        message.tag = tag
        message.firebaseDBchannelID = newChannelRef.key

        
        self.dismiss(animated: true, completion: nil)
        
        APIConnector.postMessage(message, toLocation: locationToAdd) { [weak self] (success) in
            if self != nil, success {
                self?.messageAddedAction?(self!.locationToAdd, message)
            }
        }
        
    }
    
}

//************************************
// MARK: - Initial conf
//************************************

extension NewMessageVC {
    
    func setupSearchBar(){
        
        if locationToAdd != nil {
            searchBar.text = locationToAdd.googleName
        }
        
        searchBar.delegate = self
        
        searchBar.backgroundImage = UIImage()
        
    }
    
    func setupViews() {
        
        messageTextView.delegate = self
        autocompleteView.autoCompletes = []
        autocompleteView.didSelectSuggestion = { [weak self] autoSuggestion in
            self?.searchGooglePlaceDetail(autocomp: autoSuggestion)
        }
        
    }
    
}


//************************************
// MARK: - Keyboard Handling
//************************************

extension NewMessageVC {
    
    func setupKeyboard() {
        
        bottomBarInitialSize = bottomBarBotConstraint.constant
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillChange(notification:NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        //let frameStart = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animTime = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSValue) as? Double
        let curve = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        
        let convRect = self.view.convert(frameEnd, from: nil)
        var yOffset = self.view.bounds.size.height - convRect.origin.y
        
        let show = frameEnd.height > 100
        
        if #available(iOS 11.0, *) {
            let bottomInset = view.safeAreaInsets.bottom
            if show { yOffset -= bottomInset }
        }
        
        bottomBarBotConstraint.constant = yOffset + bottomBarInitialSize
        autocompleteView.tableView.contentInset.bottom = max(yOffset, 0) // -50 cause of tabBar
        messageTextView.contentInset.bottom = max(yOffset, 0)
        
        UIView.animate(withDuration: animTime!, delay: 0, options: curve, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (value: Bool) in
            
        })
        
        scrollView.contentInset.bottom = max(yOffset, 0)
        
        if messageTextView.isFirstResponder, show {

            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height + self.scrollView.contentInset.bottom - self.scrollView.bounds.size.height)
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
        
        
    }
    
}

//************************************
// MARK: - Search Bar delegate
//************************************

extension NewMessageVC : UITextViewDelegate{

    
    func textViewDidChange(_ textView: UITextView) {
        
        let textH = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        textViewHeightConstraint.constant = textH
    
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutSubviews()
            textView.frame.size.height = textH
        }) { (ended) in
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height + self.scrollView.contentInset.bottom - self.scrollView.bounds.size.height)
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
        
        if textViewHeightConstraint.constant != textView.frame.size.height {
            textViewDidChange(textView)
        }
        
        
        
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
        searchGooglePlaceDetail(autocomp: nil)
    }
    
    
    func enterSearch() {
        //setSearchResultHidden(true, animated: true)
        //resultView.setFaded(true)
        
    }
    
    func exitSearch() {
        //resultView.setFaded(false)
        if locationToAdd != nil {
            searchBar.text = locationToAdd.googleName
        }
    }
    
    func resetSearch() {
        autocompleteView.autoCompletes = []
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
                
        var addressesAutocomp = [GMSAutocompletePrediction]()
        let userCoord = LocationManager.shared.lastKnownCoord
        let bounds = userCoord == nil ? nil : GMSCoordinateBounds(coordinate: userCoord!, coordinate: userCoord!)
        
        let filter = GMSAutocompleteFilter()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        GMSPlacesClient().autocompleteQuery(text, bounds: bounds, filter: filter, callback: { [weak self] (results, error) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil {
                return
            }
            if let results = results {
                for result in results {
//                    let autoComp = MKSAutocompleteResult()
//                    autoComp.autoString = result.attributedFullText.string
//                    autoComp.googlePlaceId = result.placeID
//                    autoComp.type = .address
                    addressesAutocomp.append(result)
                    
                }
            }
            self?.autocompleteView.autoCompletes = addressesAutocomp
            
        })
        
        
    }

    func searchGooglePlaceDetail(autocomp:GMSAutocompletePrediction?) {
        
        var autocomp = autocomp
        if autocomp == nil, autocompleteView.autoCompletes.count >= 1 {
            autocomp = autocompleteView.autoCompletes[0]
        }
        
        if autocomp == nil {
            return
        }
        
        searchBar.resignFirstResponder()
        searchBar.text = autocomp!.attributedPrimaryText.string
        autocompleteView.autoCompletes = []
        
        if autocomp?.placeID == nil {
            return
        }
        
        GMSPlacesClient().lookUpPlaceID(autocomp!.placeID!) { [weak self] (place, error) in
            
            if place == nil { return }
            let loc = CGLocation()
            
            loc.googleName = place!.name
            loc.googleAddress = place!.formattedAddress
            loc.coordinate = place!.coordinate
            loc.googlePlaceId = place!.placeID
            
            self?.locationToAdd = loc
            
        }
    }
    

    
    
}

