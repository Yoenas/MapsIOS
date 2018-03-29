//
//  ViewController.swift
//  googlemap ios
//
//  Created by Yoenas on 3/28/18.
//  Copyright © 2018 imastudio. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate {

    var lokasi : CLLocationManager? = nil
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    @IBOutlet weak var maps: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ini untuk ambil koordinat device
        
        lokasi = CLLocationManager()
        
        lokasi?.delegate = self
        lokasi?.requestWhenInUseAuthorization()

        lokasi?.requestLocation()
        lokasi?.startUpdatingLocation()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    // ambil koordinat gps
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let koordinat = locations.last?.coordinate
        let lat = koordinat?.latitude
        let lon = koordinat?.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: lat!,
                                              longitude: lon!,
                                              zoom: 15)
        maps.camera = camera
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "lokasiku"
        marker.appearAnimation = GMSMarkerAnimation.pop
        maps.mapType = GMSMapViewType.satellite
        marker.map = maps

        tampil(lat: lat!, lon: lon!)

        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func tampil(lat : Double, lon : Double) {
        let camera = GMSCameraPosition.camera(withLatitude: lat,
                                              longitude: lon,
                                              zoom: 15)
        maps.camera = camera
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "lokasiku"
        marker.appearAnimation = GMSMarkerAnimation.pop
        maps.mapType = GMSMapViewType.satellite
        marker.map = maps
        
//       / maps.settings.compassButton = true
      //  maps.settings.myLocationButton = true
        
    }

}



// Handle the user's selection.
extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
//        Do something with the selected place.
        
        print("Place name: \(place.name)")
        print("Place address: \(place.coordinate.latitude)")
        print("Place address: \(place.coordinate.longitude)")
           route(lat: place.coordinate.latitude, lon: place.coordinate.longitude)
        tampil(lat: place.coordinate.latitude, lon:    place.coordinate.longitude)
        
     
    
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func route(lat : Double, lon : Double){
        
        let awal = "-6.1973006,106.7937623"
        let tujuan = String(lat) + "," + String(lon)
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin="+awal+"&destination="+tujuan
        
        print(url)
        
        Alamofire.request(url).responseJSON { (responseRoute) in
            
            // check JSON
            responseRoute.result.ifSuccess {
                
                // get JSON
                let getAllJSON = JSON(responseRoute.result.value as Any)
                
                print(getAllJSON)
                
                // get array route
                let route = getAllJSON["routes"].arrayValue
                let obj0 = route[0].dictionaryValue
                
                let overview = obj0["overview_polyline"]?.dictionaryValue
                
                let point = overview!["points"]?.stringValue
                
                let path = GMSPath(fromEncodedPath: point!)
                
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = .blue
                polyline.strokeWidth = 5.0
                polyline.map = self.maps
                polyline.geodesic = true
                
                let legs = obj0["legs"]?.arrayValue
                let leg0 = legs![0].dictionaryValue
                
                let distance = leg0["distance"]?.dictionaryValue
                let text = distance!["text"]?.stringValue
                let value = distance!["value"]?.intValue
                
                let path_text = GMSPath(fromEncodedPath: text!)
                
                
                let duration = leg0["distance"]?.dictionaryValue
                let text1 = duration!["text"]?.stringValue
                let value1 = duration!["value"]?.intValue
                
                let path_duration = GMSPath(fromEncodedPath: text1!)
                
                
            }
        }
    }
}







