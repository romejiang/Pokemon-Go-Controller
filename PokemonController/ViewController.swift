//
//  ViewController.swift
//  PokemonController
//
//  Created by Ka Ho on 7/7/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit
import MapKit
import GCDWebServer

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var currentLocation:CLLocationCoordinate2D!
    var timer:NSTimer!
    var webServer:GCDWebServer = GCDWebServer()
    
    let initialLocation = CLLocation(latitude: -37.7983336702636, longitude: 144.978288)
    let regionRadius: CLLocationDistance = 1000
    
    enum direction {
        case UP, DOWN, LEFT, RIGHT
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerMapOnLocation(initialLocation)
        getSavedLocation() ? showMapOnLocation() : ()
        
        startWebServer()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        currentLocation = mapView.centerCoordinate
        saveLocation()
    }
    
    func moveInterval() -> Double {
        return Double("0.0000\(40 + (rand() % 20))")!
    }
    
    func randomBetweenNumbers(firstNumber: Double, secondNumber: Double) -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
    
    func changeCurrentLocation(move:direction) {
        let jitter = randomBetweenNumbers(-0.000009, secondNumber: 0.000009)
        
        switch move {
        case .UP:
            currentLocation.latitude += moveInterval()
            currentLocation.longitude += jitter
        case .DOWN:
            currentLocation.latitude -= moveInterval()
            currentLocation.longitude += jitter
        case .LEFT:
            currentLocation.latitude += jitter
            currentLocation.longitude -= moveInterval()
        case .RIGHT:
            currentLocation.latitude += jitter
            currentLocation.longitude += moveInterval()
        }
        
        saveLocation()
        showMapOnLocation()
    }
    
    func showMapOnLocation() {
        mapView.setCamera(MKMapCamera(lookingAtCenterCoordinate: currentLocation, fromEyeCoordinate: currentLocation, eyeAltitude: 500.0), animated: false)
    }
    
    func saveLocation() {
        NSUserDefaults.standardUserDefaults().setObject(getCurrentLocationDict(), forKey: "savedLocation")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getSavedLocation() -> Bool {
        guard let savedLocation = NSUserDefaults.standardUserDefaults().objectForKey("savedLocation") else {
            return false
        }
        return putCurrentLocationFromDict(savedLocation as! [String : String])
    }
    
    func getCurrentLocationDict() -> [String:String] {
        return ["lat":"\(currentLocation.latitude)", "lng":"\(currentLocation.longitude)"]
    }
    
    func putCurrentLocationFromDict(dict: [String:String]) -> Bool {
        currentLocation = CLLocationCoordinate2D(latitude: Double(dict["lat"]!)!, longitude: Double(dict["lng"]!)!)
        return true
    }
    @IBAction func downLong(sender: UILongPressGestureRecognizer) {
        switch (sender.state) {
        case .Began:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(downDidPress), userInfo: nil, repeats: true)
            break;
        case .Ended:
            
            timer.invalidate()
            timer = nil;
            
            break;
        default:
            break;
        }

    }
    @IBAction func leftLong(sender: UILongPressGestureRecognizer) {
        switch (sender.state) {
        case .Began:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(leftDidPress), userInfo: nil, repeats: true)
            break;
        case .Ended:
            
            timer.invalidate()
            timer = nil;
            
            break;
        default:
            break;
        }

    }
    
    @IBAction func upLongPress(sender: UILongPressGestureRecognizer) {
        switch (sender.state) {
        case .Began:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(upDidPress), userInfo: nil, repeats: true)
            break;
        case .Ended:
            
            timer.invalidate()
            timer = nil;
            
            break;
        default:
            break;
        }

    }
    func rigthDidPress(){
        //NSLog("sdfsdfsdf")
        changeCurrentLocation(.RIGHT)
    }
    func leftDidPress(){
        //NSLog("sdfsdfsdf")
        changeCurrentLocation(.LEFT)
    }
    func downDidPress(){
        //NSLog("sdfsdfsdf")
        changeCurrentLocation(.DOWN)
    }
    func upDidPress(){
        //NSLog("sdfsdfsdf")
        changeCurrentLocation(.UP)
    }
    
    @IBAction func RigthLongPress(sender: UILongPressGestureRecognizer) {
        switch (sender.state) {
        case .Began:
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(rigthDidPress), userInfo: nil, repeats: true)
            break;
        case .Ended:
    
                timer.invalidate()
                timer = nil;
            
            break;
        default:
            break;
        }
    }
    
    
    
    @IBAction func moveUp(sender: AnyObject) {
        changeCurrentLocation(.UP)
        
    }
    
    @IBAction func moveDown(sender: AnyObject) {
        changeCurrentLocation(.DOWN)
    }
    
    @IBAction func moveLeft(sender: AnyObject) {
        changeCurrentLocation(.LEFT)
    }
    
    @IBAction func moveRight(sender: AnyObject) {
        changeCurrentLocation(.RIGHT)
    }
    
    func startWebServer(){
        webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse.init(JSONObject: self.getCurrentLocationDict())
        })
        webServer.startWithPort(8080, bonjourName: "pokemonController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}