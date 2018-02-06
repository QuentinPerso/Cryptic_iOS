//
//  SearchResultMapView.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 24/03/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MapKit

class SearchResultMapView: UIView {

    @IBOutlet weak var mapView: MKMapView!
    
    var filteredPlaces = [CGLocation]() { didSet{ setupMap() } }
    
    var mapFirstCentered = false
    
    var clickPlaceAction:((CGLocation)->())?
    
    var mapReadyAction:(()->())?
    
    var pinZIndex = 0

    //************************************
    // MARK: - View Methods
    //************************************
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //trick iOS < 10 map and layout guides
        let iOS10 = (UIDevice.current.systemVersion as NSString).floatValue >= 10
        if !iOS10 {
            mapView.removeFromSuperview()
            mapView = MKMapView(frame: self.bounds)
            addSubview(mapView)
        }
        
        mapView.delegate = self
        
        mapView.showsUserLocation = true

    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mapView.frame = self.bounds
        
        sendSubview(toBack: mapView)
    }
    
    
    
}



//************************************
// MARK: - Map methods
//************************************
extension SearchResultMapView {
    
    func setupMap(){
        
        for annot in mapView.annotations {
            if annot is PlaceAnnotation{
                mapView.removeAnnotation(annot)
            }
        }
        
        var annots = [PlaceAnnotation]()
        for place in filteredPlaces {
            let artwork = PlaceAnnotation(place: place)
            annots.append(artwork)
        }
        mapView.addAnnotations(annots)
        mapView.showAnnotations(annots, animated: false)
        
        
    }

    
    
}

//************************************
// MARK: - Map View Delegate
//************************************

extension SearchResultMapView : MKMapViewDelegate{
    

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if !mapFirstCentered {
            mapView.centerOn(userLocation.coordinate, zoomLevel: 13.5, animated: false)
            mapReadyAction?()
            mapFirstCentered = true
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        pinZIndex += 1
        
        view.layer.zPosition = CGFloat(pinZIndex)
        
//        if let selAnnot = view.annotation as? PlaceAnnotation  {
//            
//            
//            if isScrolling {
//                return
//            }
//            
//            for place in filteredPlaces {
//                if selAnnot.place == place {
//                    let indexP = IndexPath(row: filteredPlaces.index(of: place)!, section: 0)
//                    collectionView.scrollToItem(at: indexP, at: .centeredHorizontally, animated: true)
//                }
//            }
//            
//        }
        
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        if let annotation = annotation as? PlaceAnnotation {
//
//            var type:PlaceTypes = .hot
//
//
//            annotationView.clickSelectedAction = { [weak self] in
//                self?.clickPlaceAction?(annotation.place)
//            }
//
//
//            return annotationView
//
//        }
//        return nil
//
//    }
    
}

