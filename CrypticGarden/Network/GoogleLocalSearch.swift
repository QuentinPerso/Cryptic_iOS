//
//  GoogleLocalSearch.swift
//  CrypticGarden
//
//  Created by Quentin Beaudouin on 22/02/2018.
//  Copyright © 2018 Marks. All rights reserved.
//


import Alamofire
import CoreLocation

extension APIConnector {
    
    
    static func googleLocalSearch(center:CLLocationCoordinate2D, completion:@escaping (CGLocation?) -> Void){
        
        
        //https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=48.837991483632585%2C2.3484099235473908&key=AIzaSyAdHCHmiKVw1_66qaq6zK4P9_IItBcu37c&rankby=distance
        
        var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        
        
        let queryParams:[String:String] = [ "location": "\(center.latitude),\(center.longitude)",
                                            "key": APIConnector.kGooglePlacesApi,
                                            "rankby": "distance"]
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        sessionManager.request(url, parameters: queryParams).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            print(response.result.value)
            
        }
        
        
        
    }
}
