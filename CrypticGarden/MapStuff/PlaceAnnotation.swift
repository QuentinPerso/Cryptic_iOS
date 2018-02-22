//
//  ArtWork.swift
//  Busity
//
//  Created by Quentin BEAUDOUIN on 04/06/2016.
//  Copyright © 2016 Instama. All rights reserved.
//

import UIKit
import MapKit

class PlaceAnnotation:NSObject, MKAnnotation {
    
    //    let title: String?
    let place:CGLocation!
    let coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    init(place:CGLocation) {
        
        self.place = place
        
//        if let likedPlaces = SavedPlacesStore.shared.likedPlaces, likedPlaces.contains(place) {
//            self.place.placeType = .liked
//        }
//        else if let bookedPlaces = SavedPlacesStore.shared.bookmarkedPlaces, bookedPlaces.contains(place) {
//            self.place.placeType = .booked
//        }
        
        self.coordinate = place.coordinate

        self.title = place.googleName
        
        super.init()
    }
    
}
