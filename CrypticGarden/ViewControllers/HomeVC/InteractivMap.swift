//
//  InteractivMap.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 24/03/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MapKit

class InteractivMap: UIView {

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
        mapView.showsBuildings = true
       // mapView.mapType = .satelliteFlyover
        
        
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
extension InteractivMap:UIGestureRecognizerDelegate  {
    
    func confMap(){
        
//        let overlayPath = "https://cartodb-basemaps-{scale}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png"
//        let overlay = MKTileOverlay(urlTemplate: overlayPath)
//        overlay.canReplaceMapContent = true
//        self.mapView.add(overlay)
        
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
                
                var annotSelected = false
                
                if mapView.selectedAnnotations.count > 0, let selAnnot = mapView.selectedAnnotations[0] as? PlaceAnnotation, selAnnot.place.googlePlaceId == pAnnot.place.googlePlaceId {
                    annotSelected = true
                }
                
                if !filteredPlaces.contains(pAnnot.place), !annotSelected {
                    mapView.removeAnnotation(annot)
                }
                else if let index = filteredPlaces.index(of: pAnnot.place){
                    pAnnot.place = filteredPlaces[index]
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

extension InteractivMap : MKMapViewDelegate{
    

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if !mapFirstCentered {
            
            mapView.set3DCamera(coord: userLocation.coordinate, animated: true)
            //mapView.centerOn(coord: userLocation.coordinate, radius: MapFunctions.defaultRegionRadius, animated: true)
            mapReadyAction?()
            mapFirstCentered = true
        }
        let userLocationView = mapView.view(for: userLocation)
        userLocationView?.canShowCallout = false
        
        LocationManager.shared.lastLocation = userLocation.location
        
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let tileOverlay = overlay as? MKTileOverlay else {
            return MKOverlayRenderer(overlay: overlay)
        }
        print("****************", tileOverlay.urlTemplate)
        return MKTileOverlayRenderer(tileOverlay: tileOverlay)
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

