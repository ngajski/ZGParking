//
//  MapViewController.swift
//  ZGParking
//
//  Created by Nikola Gajski on 4/2/17.
//  Copyright © 2017 ngajski. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class MapViewController: UIViewController {

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    @IBOutlet weak var zoneLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var carPicker: UIPickerView!
    
    @IBOutlet weak var zoneLabelTopConstraint: NSLayoutConstraint!
    
    var pickerData = ["Auto 1", "Auto 2", "Auto 3", "Auto 4", "Auto 5", "Auto 6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zoneLabel.text = "Zona:"
        priceLabel.text = "Cijena:"
        
        carPicker.delegate = self
        carPicker.dataSource = self
        
        initLocationManager()
        initGoogleMapView()
    }
    
    private func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
    }
    
    private func initGoogleMapView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 45.813720, longitude: 15.977885, zoom: zoomLevel)
        
        let width = self.view.bounds.width
        let height = self.view.bounds.height / 2
        
        self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: width, height: height), camera: camera)
        
        self.mapView.settings.myLocationButton = true
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        zoneLabelTopConstraint.constant = height + 20
        
    }
    
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        let stringCoordinates = "(" + location.coordinate.latitude.description + "," + location.coordinate.longitude.description + ")"
        
        zoneLabel.text = "Zona: " + stringCoordinates
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension MapViewController: UIPickerViewDelegate, UIPickerViewDataSource {
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
}
