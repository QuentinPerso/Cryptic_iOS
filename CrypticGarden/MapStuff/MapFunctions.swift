//
//  MapFunctions.swift
//  Busity
//
//  Created by Quentin BEAUDOUIN on 04/06/2016.
//  Copyright © 2016 Instama. All rights reserved.
//

import UIKit
import MapKit

struct Viewport {
    var southWest:CLLocationCoordinate2D
    var northEast:CLLocationCoordinate2D
}

extension MKMapView {
    
    //************************************
    // MARK: - CLLocation
    //************************************
    
    func centerOn(location: CLLocation, radius:CLLocationDistance?, animated:Bool) {
        
        if radius != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, radius!, radius!)
            self.setRegion(coordinateRegion, animated: animated)
        }
        else {
            self.setCenter(location.coordinate, animated: animated)
        }
    }
    
    //************************************
    // MARK: - Coordinate
    //************************************
    
    func centerOn(coord: CLLocationCoordinate2D, radius:CLLocationDistance?, animated:Bool) {
        
        if radius != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coord, radius!, radius!)
            self.setRegion(coordinateRegion, animated: animated)
        }
        else {
            self.setCenter(coord, animated: animated)
        } 
    }
    
    
    func viewportVisibleAnnot(_ annotViewSize:CGSize = CGSize.zero) -> Viewport {
        
        let sidePadding = annotViewSize.width/3
        let topAdditionalPadding = annotViewSize.height
        let nePoint =
            CGPoint(x:self.bounds.origin.x + self.bounds.size.width - sidePadding,
                    y:self.bounds.origin.y + self.layoutMargins.top + topAdditionalPadding)
        let swPoint =
            CGPoint(x:(self.bounds.origin.x + sidePadding),
                    y:(self.bounds.origin.y + self.bounds.size.height - self.layoutMargins.bottom))
        
        //Then transform those point into lat,lng values
        let ne = self.convert(nePoint, toCoordinateFrom: self)
        let sw = self.convert(swPoint, toCoordinateFrom: self)
        
        
//        //Draw vieport view
//        for view in subviews {
//            if view.backgroundColor == UIColor.blue.withAlphaComponent(0.15) {
//                return Viewport(southWest: sw, northEast: ne)
//            }
//        }
//        let rect = CGRect(x: swPoint.x,
//                          y: nePoint.y,
//                          width: abs(swPoint.x - nePoint.x),
//                          height: abs(swPoint.y - nePoint.y) )
//        let view = UIView(frame: rect)
//        self.addSubview(view)
//        view.isUserInteractionEnabled = false
//        view.backgroundColor = UIColor.blue.withAlphaComponent(0.15)
        
        
        
        
//        //Visible map rect
//        for view in subviews {
//            if view.backgroundColor == UIColor.blue.withAlphaComponent(0.15) {
//                return Viewport(southWest: sw, northEast: ne)
//            }
//        }
//        
//        let mreg = MKCoordinateRegionForMapRect(visibleMapRect)
//        let rect = self.convertRegion(mreg, toRectTo: self)
//        let view = UIView(frame: rect)
//        self.addSubview(view)
//        view.isUserInteractionEnabled = false
//        view.backgroundColor = UIColor.blue.withAlphaComponent(0.15)
        
        
        return Viewport(southWest: sw, northEast: ne)
        
        
    }
    
    
}


let MERCATOR_RADIUS = 85445659.44705395
let MERCATOR_OFFSET = 268435456.0
let MAX_GOOGLE_LEVELS:Double = 20

extension MKMapView {
    
    func getZoomLevel() -> Double {
        
        //        let longitudeDelta = self.region.span.longitudeDelta
        
        //        let centerPixelX = longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        //        let centerPixelY = latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        //
        //        // determine the scale value from the zoom level
        //
        //        let zoomLevel = MAX_GOOGLE_LEVELS - zoomExponent
        //        let zoomExponent = log2(zoomScale)
        //        let zoomScale = scaledMapWidth/Double(mapSizeInPixels.width)
        //
        //
        //        // figure out the position of the top-left pixel
        //        let topLeftPixelX = centerPixelX - Double(scaledMapWidth / 2)
        //        let topLeftPixelY = centerPixelY - Double(scaledMapHeight / 2)
        //
        //        // find delta between left and right longitudes
        //        let minLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        //        let maxLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        //        let longitudeDelta = maxLng - minLng
        //
        //        // find delta between top and bottom latitudes
        //        let minLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        //        let maxLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        //        let latitudeDelta = -1 * (maxLat - minLat)
        //
        //        // create and return the lat/lng span
        //        let span = MKCoordinateSpanMake(longitudeDelta, longitudeDelta)
        
        let region = self.region
        
        let centerPixelX = longitudeToPixelSpaceX(longitude: region.center.longitude)
        let topLeftPixelX = longitudeToPixelSpaceX(longitude: region.center.longitude - region.span.longitudeDelta / 2)
        
        let scaledMapWidth = (centerPixelX - topLeftPixelX) * 2
        let mapSizeInPixels = self.bounds.size
        let zoomScale = scaledMapWidth / Double(mapSizeInPixels.width)
        let zoomExponent = log2(zoomScale) / log2(2)
        let zoomLevel = 20 - zoomExponent
        
        let roundZoom = Double(round(zoomLevel*100)/100)
        
        return roundZoom
        
        //        let longitudeDelta = self.region.span.longitudeDelta
        //        let mapWidthInPixels = self.bounds.size.width
        //        let zoomScale:Double = longitudeDelta * MERCATOR_RADIUS * .pi / Double((180.0 * mapWidthInPixels))
        //        var zoomer = MAX_GOOGLE_LEVELS - log2( zoomScale )
        //        if ( zoomer < 0 ) { zoomer = 0 }
        //        //  zoomer = round(zoomer)
        //        return zoomer
    }
    
    
    //MARK: - Map conversion methods
    
    private func longitudeToPixelSpaceX(longitude:Double) -> Double {
        
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * .pi / 180.0)
    }
    
    private func latitudeToPixelSpaceY(latitude:Double) -> Double {
        
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * .pi / 180.0)) / (1 - sin(latitude * .pi / 180.0))) / 2.0)
    }
    
    private func pixelSpaceXToLongitude(pixelX:Double) -> Double {
        
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / .pi
    }
    
    private func  pixelSpaceYToLatitude(pixelY:Double) -> Double {
        let trigo = atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))
        return (.pi / 2.0 - 2.0 * trigo) * 180.0 / .pi
    }
    
    //MARK: - Map Helper methods
    
    private func coordinateSpan(_ mapView:MKMapView, centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double) -> MKCoordinateSpan {
        
        // convert center coordiate to pixel space
        let centerPixelX = longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        
        // determine the scale value from the zoom level
        let zoomExponent = MAX_GOOGLE_LEVELS - zoomLevel
        let zoomScale:Double = pow(2.0, zoomExponent)
        
        // scale the map’s size in pixel space
        let mapWInPixels = mapView.bounds.size.width - mapView.layoutMargins.left - mapView.layoutMargins.right
        let mapHInPixels = mapView.bounds.size.height - mapView.layoutMargins.top - mapView.layoutMargins.bottom - UIApplication.shared.statusBarFrame.size.height
        let scaledMapWidth = Double(mapWInPixels) * zoomScale
        let scaledMapHeight = Double(mapHInPixels) * zoomScale
        
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - Double(scaledMapWidth / 2)
        let topLeftPixelY = centerPixelY - Double(scaledMapHeight / 2)
        
        // find delta between left and right longitudes
        let minLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        
        // find delta between top and bottom latitudes
        let minLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1 * (maxLat - minLat)
        
        // create and return the lat/lng span
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        return span
    }
    
    //MARK: - Public methods
    
    func centerOn(_ centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double, animated:Bool) {
        
        // clamp large numbers to 28
        let zoomLevel = min(zoomLevel, 28)
        
        // use the zoom level to compute the region
        let span = coordinateSpan(self, centerCoordinate: centerCoordinate, zoomLevel: zoomLevel)
        let region = MKCoordinateRegionMake(centerCoordinate, span)
        // set the region like normal
        self.setRegion(region, animated: animated)
    }
    
}

class MapFunctions: NSObject {
    
    static let defaultRegionRadius:CLLocationDistance = 1200

    
    //************************************
    // MARK: - Utils
    //************************************

    
    static func mapRectThatFitsBounds(sw:CLLocationCoordinate2D, ne:CLLocationCoordinate2D) -> MKMapRect{
        
        let swPoint = MKMapPointForCoordinate(sw)
        let swRect = MKMapRect(origin: swPoint, size: MKMapSize(width: 0, height: 0))
        
        let nePoint = MKMapPointForCoordinate(ne)
        let neRect = MKMapRect(origin: nePoint, size: MKMapSize(width: 0, height: 0))
        
        return MKMapRectUnion(swRect, neRect)
    }
    
    static func isCoordInViewPort(coord:CLLocationCoordinate2D, viewport:Viewport) -> Bool {
        
        let rect = mapRectThatFitsBounds(sw: viewport.southWest, ne: viewport.northEast)
        
        let point = MKMapPointForCoordinate(coord)
        
        return MKMapRectContainsPoint(rect, point)
        
    }
    
    static func isCoordInMapRect(_ coord:CLLocationCoordinate2D, mapRect:MKMapRect) -> Bool {
        
        let point = MKMapPointForCoordinate(coord)
        
        return MKMapRectContainsPoint(mapRect, point)
        
    }
    
    static func isCoordinateInRegion(_ coord:CLLocationCoordinate2D, region:MKCoordinateRegion) -> Bool {
        
        let center = region.center
        let span = region.span
        
        var result = true
        result = result && cos((center.latitude - coord.latitude) * .pi/180.0) > cos(span.latitudeDelta/2.0 * .pi/180.0)
        result = result && cos((center.longitude - coord.longitude) * .pi/180.0) > cos(span.longitudeDelta/2.0 * .pi/180.0)
        
        return result
    }
    
//    static func isCoordInRect(coord:CLLocationCoordinate2D, rect:[CLLocationCoordinate2D]) -> Bool{
//        
//        if rect.count != 4 { return false }
//        
//        let point0 = MKMapPointForCoordinate(rect[0])
//        let rect0 = MKMapRect(origin: point0, size: MKMapSize(width: 0, height: 0))
//        
//        let point1 = MKMapPointForCoordinate(rect[1])
//        let rect1 = MKMapRect(origin: point1, size: MKMapSize(width: 0, height: 0))
//        
//        let rectU1 = MKMapRectUnion(rect0, rect1)
//        
//        
//        let point2 = MKMapPointForCoordinate(rect[2])
//        let rect2 = MKMapRect(origin: point2, size: MKMapSize(width: 0, height: 0))
//        
//        let point3 = MKMapPointForCoordinate(rect[3])
//        let rect3 = MKMapRect(origin: point3, size: MKMapSize(width: 0, height: 0))
//        
//        let rectU2 = MKMapRectUnion(rect2, rect3)
//        
//        let rectU = MKMapRectUnion(rectU1, rectU2)
//        
//        let point = MKMapPointForCoordinate(coord)
//        
//        return MKMapRectContainsPoint(rectU, point)
//        
//    }
    
    
//    static func getAverageColor(color1:UIColor, weight1:CGFloat, color2:UIColor, weight2:CGFloat) ->UIColor{
//        
//        var red1:CGFloat = 0.0, green1:CGFloat = 0.0, blue1:CGFloat = 0.0, alpha1:CGFloat = 0.0
//        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
//        
//        var red2:CGFloat = 0.0, green2:CGFloat = 0.0, blue2:CGFloat = 0.0, alpha2:CGFloat = 0.0
//        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
//        
//        return UIColor(red: (red1*weight1 + weight2*red2)/(weight2 + weight1),
//                       green: (green1*weight1 + weight2*green2)/(weight2 + weight1),
//                       blue: (blue1*weight1 + weight2*blue2)/(weight2 + weight1),
//                       alpha: 1)
//        
//    }
    

}
