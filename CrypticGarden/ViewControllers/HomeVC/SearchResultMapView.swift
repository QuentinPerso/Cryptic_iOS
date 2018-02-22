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

    var mapView: MKMapView!
    
    var filteredPlaces = [CGLocation]() { didSet{ reloadMap(previousLocations: oldValue) } }
    
    var mapFirstCentered = false
    
    var clickPlaceAction:((CGLocation)->())?
    var mapReadyAction:(()->())?
    var mapStartPanAction:(()->())?
    var mapSelectAnnotationAction:((MKAnnotationView)->())?
    var mapDeselectAnnotationAction:((MKAnnotationView)->())?
    var mapRegionDidChangeAction:(()->())?
    
    var pinZIndex = 0
    
    var skipRegionChangeDelegate = true

    //************************************
    // MARK: - View Methods
    //************************************
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mapView = MKMapView(frame: self.bounds)
        //trick iOS < 10 map and layout guides
        
        
        addSubview(mapView)
        
        confMap()
        
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        
        
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mapView.frame = self.bounds

    }
    
    
    
}



//************************************
// MARK: - Map methods
//************************************
extension SearchResultMapView:UIGestureRecognizerDelegate  {
    
    func confMap(){
        
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panRec.delegate = self
        
        let pinchRec = UIPinchGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        pinchRec.delegate = self
        
        mapView.addGestureRecognizer(panRec)
        mapView.addGestureRecognizer(pinchRec)
        
    }
    
    func reloadMap(previousLocations:[CGLocation]){
        
        var annotsplaces = [CGLocation]()
        for annot in mapView.annotations {
            if let pAnnot = annot as? PlaceAnnotation {
                
                if !filteredPlaces.contains(pAnnot.place), mapView.selectedAnnotations.count > 0, let selAnnot = mapView.selectedAnnotations[0] as? PlaceAnnotation, selAnnot.place.googlePlaceId == pAnnot.place.googlePlaceId  {
                    mapView.removeAnnotation(annot)
                }
                else {
                    annotsplaces.append(pAnnot.place)
                }
            }
        }
        
        var annots = [PlaceAnnotation]()
        for place in filteredPlaces {
            if !annotsplaces.contains(place) {
                let artwork = PlaceAnnotation(place: place)
                annots.append(artwork)
            }
            
        }
        mapView.addAnnotations(annots)
        
        
    }
    
    @objc func didDragMap(_ gestureRecognizer:UIGestureRecognizer){
        
        if (gestureRecognizer.state == .began) {
            
            mapStartPanAction?()
            
            if gestureRecognizer.numberOfTouches <= 4 {
                skipRegionChangeDelegate = false
                //searchOverlay?.show()
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        
        if skipRegionChangeDelegate { return }
        
        skipRegionChangeDelegate = true
        
        mapRegionDidChangeAction?()
        
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        mapDeselectAnnotationAction?(view)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        pinZIndex += 1
        
        view.layer.zPosition = CGFloat(pinZIndex)
        
        mapSelectAnnotationAction?(view)
        
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

