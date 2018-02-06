//
//  MKSAutocompleteResult.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 25/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import Foundation
import CoreLocation

enum AutoResultType:String {
    case tag = "tag"
    case place = "place"
    case curator = "curator"
    case address = "address"
    case notMKSPlace = "notMarksPlace"

}

class MKSAutocompleteResult : NSObject {
    
    var objectID:String?
    var type:AutoResultType!
    var autoString:String!
    var coordinate:CLLocationCoordinate2D!
    var googlePlaceId:String!
    var googleAddress:String!
    
    override init() { super.init() }
    
    init(dictionary:[String : AnyObject]) {

        super.init()
        
        objectID = dictionary["id"] as? String
        autoString = dictionary["value"] as! String
        
        let typeString = dictionary["type"] as! String
        switch typeString {
        case "tag":
            type = .tag
        case "place":
            type = .place
        case "curator":
            type = .curator
        default:
            type = .tag
        }
        
        
    }
    
    
}
