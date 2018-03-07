//
//  ViewController.swift
//  Pulley
//
//  Created by Brendan Lee on 7/6/16.
//  Copyright © 2016 52inc. All rights reserved.
//

import UIKit
import MapKit

class MapContentVC: UIViewController {
    

    @IBOutlet weak var mapView: InteractivMap!
    @IBOutlet var controlsContainer: UIView!
    
    @IBOutlet weak var locButton: UIButton!
    /**
     * IMPORTANT! If you have constraints that you use to 'follow' the drawer (like the temperature label in the demo)...
     * Make sure you constraint them to the bottom of the superview and NOT the superview's bottom margin. Double click the constraint, and you can change it in the dropdown in the right-side panel. If you don't, you'll have varying spacings to the drawer depending on the device.
     */
    @IBOutlet var locButtonBotConstraint: NSLayoutConstraint!
    fileprivate let locButtonBotDistance: CGFloat = 8.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        controlsContainer.layer.cornerRadius = 10.0
        locButton.layer.cornerRadius = 10.0
        
        
        mapView.mapReadyAction = { [weak self] in self?.callAPILocations() }
        mapView.mapRegionDidChangeAction = { [weak self] in self?.callAPILocations() }
        mapView.mapDeselectAnnotationAction = { [weak self] annotationView in self?.locationDeselected() }
        mapView.mapSelectAnnotationAction = { [weak self] annotationView in
            if let annot = annotationView.annotation as? PlaceAnnotation  {
                self?.locationSelected(annot.place)
            }

        }
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Customize Pulley in viewWillAppear, as the view controller's viewDidLoad will run *before* Pulley's and some changes may be overwritten.
        if let drawer = parent as? PulleyViewController {
            // Uncomment if you want to change the visual effect style to dark. Note: The rest of the sample app's UI isn't made for dark theme. This just shows you how to do it.
            // drawer.drawerBackgroundVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            
            // We want the 'side panel' layout in landscape iPhone / iPad, so we set this to 'automatic'. The default is 'bottomDrawer' for compatibility with older Pulley versions.
            drawer.displayMode = .automatic
        }
    }
    
}

//************************************
// MARK: - Actions
//************************************

extension MapContentVC {
    
    @IBAction func locationButtonClicked(sender: AnyObject) {
        
        if let mainVC = parent as? PulleyViewController, let drawerVC = mainVC.drawerContentViewController as? DrawerContentVC {
            
            if let coord = LocationManager.shared.lastKnownCoord {
                
                mapView.mapView.set3DCamera(coord: coord, animated: true)
               // mapView.mapView.centerOn(coord: coord, radius: MapFunctions.defaultRegionRadius, animated: true)
                drawerVC.autofillSearchBar()
            }
            
            
        }
    }
    
    @IBAction func profileButtonClicked(sender: AnyObject) {
        
        //        startVerification()
        if let userVC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateInitialViewController() {
            present(userVC, animated: true, completion: nil)
        }
        
        
        //        if let drawer = self.parent as? PulleyViewController,  let userVC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateInitialViewController() {
        //
        //            drawer.setPrimaryContentViewController(controller: userVC, animated: true)
        //        }
    }
    
    func selectAnnotation(location:CGLocation) {
        
        for annot in mapView.mapView.annotations {
            if let pAnnot = annot as? PlaceAnnotation {
                if pAnnot.place == location {
                    mapView.mapView.selectAnnotation(pAnnot, animated: true)
                    return
                }
            }
        }
        
    }
    
    func locationSelected(_ location:CGLocation) {
        
        if let mainVC = parent as? PulleyViewController {
            mainVC.setDrawerPosition(position: .partiallyRevealed, animated: true)
            if let drawerVC = mainVC.drawerContentViewController as? DrawerContentVC {
                drawerVC.currentLocation = location
            }
        }
    }
    
    func locationDeselected() {
        
        if let mainVC = parent as? PulleyViewController {
            mainVC.setDrawerPosition(position: .collapsed, animated: true)
            if let drawerVC = mainVC.drawerContentViewController as? DrawerContentVC {
                drawerVC.currentLocation = nil
            }
        }
    }
    
}

//************************************
// MARK: - API Calls
//************************************

extension MapContentVC {
    
    func callAPILocations(completion:(([CGLocation])->())? = nil) {
        
        _ = APIConnector.getLocations(viewport: mapView.mapView.viewportVisibleAnnot(), completion: { [weak self] (locations, cancelled) in
            
            if locations == nil { return }
            
            self?.mapView.filteredPlaces = locations!
            completion?(locations!)
        })
        
    }
    
}

//************************************
// MARK: - Drawer Delegate
//************************************

extension MapContentVC: PulleyPrimaryContentControllerDelegate {
    
    func makeUIAdjustmentsForFullscreen(progress: CGFloat, bottomSafeArea: CGFloat) {
        guard let drawer = parent as? PulleyViewController, drawer.currentDisplayMode == .bottomDrawer else {
            controlsContainer.alpha = 1.0
            return
        }
        
        controlsContainer.alpha = 1.0 - progress
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        guard drawer.currentDisplayMode == .bottomDrawer else {
            
            locButtonBotConstraint.constant = locButtonBotDistance
            return
        }
        
        if distance <= 268.0 + bottomSafeArea {
            locButtonBotConstraint.constant = distance + locButtonBotDistance
        }
        else {
            locButtonBotConstraint.constant = 268.0 + locButtonBotDistance
        }
    }
}

//************************************
// MARK: - Drawer Navigation
//************************************

extension MapContentVC {
    
    @IBAction func runPrimaryContentTransition(sender: AnyObject) {

        if let drawer = self.parent as? PulleyViewController,  let userVC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateInitialViewController() {

            drawer.setPrimaryContentViewController(controller: userVC, animated: true)
        }
    }
}

