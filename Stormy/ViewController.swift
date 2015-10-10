//
//  ViewController.swift
//  Stormy
//
//  Created by Rishabh Parikh on 1/8/15.
//  Copyright (c) 2015 Rishabh Parikh. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    private let apiKey = "c8f1549fe11bb93addb913f39cdf9fda"
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshActivity: UIActivityIndicatorView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let locationManager = CLLocationManager()
    var xCoord: Double?
    var yCoord: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            print("Location services are not enabled");
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        refreshActivity.hidden = true
        getWeatherDataForDate(datePicker.date)
        print(datePicker.date)

    }

    //CoreLocation Delegate Methods
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        if(error.code == 0 && error.domain == "kCLErrorDomain") {
            
        }
        
        locationManager.stopUpdatingLocation()
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        print(coord.latitude as Double)
        print(coord.longitude as Double)
        self.xCoord = coord.latitude
        self.yCoord = coord.longitude
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: self.xCoord!, longitude: self.yCoord!)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks! as [CLPlacemark]
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray[0]
            
            if let city = placeMark.addressDictionary?["City"] as? NSString {
                print(city)
                if let state = placeMark.addressDictionary?["State"] as? NSString {
                    if let country = placeMark.addressDictionary?["Country"] as? NSString {
                        self.cityLabel.text = "\(city), \(state), \(country)"
                    }
                }
            }
            else if let locationName = placeMark.addressDictionary?["Name"] as? NSString {
                self.cityLabel.text = locationName as String
            }
            else {
                self.cityLabel.text = "Unknown"
            }
        })
        getWeatherDataForDate(datePicker.date)
    }
    
    func getWeatherDataForDate(date: NSDate) {
        
        let unixTime: Int = Int(date.timeIntervalSince1970)
        var baseURL: NSURL
        if xCoord != nil {
            baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/\(xCoord!),\(yCoord!),\(unixTime)")!
        }
        else {
            baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/37.6442888,-121.8016367,\(unixTime)")!
        }
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(baseURL, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                let dataObject = NSData(contentsOfURL: location!)
                var weatherDictionary : NSDictionary?
                do {
                weatherDictionary = try NSJSONSerialization.JSONObjectWithData(dataObject!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                }
                catch {
                    
                }
                print(weatherDictionary)
                print(unixTime)
                let weather : Current = Current(weatherDictionary: weatherDictionary!)
    
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if(weather.temperature != nil) {
                        self.temperatureLabel.text = "\(weather.temperature!)"
                    }
                    else {
                        self.temperatureLabel.text = "N/A"
                    }
                    
                    if(weather.icon != nil) {
                        self.icon.image = weather.icon
                    }
                    
                    self.timeLabel.text = weather.currentTime
                    
                    if(weather.humidity != nil) {
                        self.humidityLabel.text = "\(weather.humidity!)"
                    }
                    else {
                        self.humidityLabel.text = "N/A"
                    }
                    
                    if(weather.precipProbability != nil) {
                        self.precipitationLabel.text = "\(weather.precipProbability!)"
                    }
                    else {
                        self.precipitationLabel.text = "N/A"
                    }
                    
                    if(weather.summary != nil) {
                        self.summaryLabel.text = weather.summary
                    }
                    else {
                        self.summaryLabel.text = "N/A"
                    }
                    
                    self.refreshActivity.stopAnimating()
                    self.refreshActivity.hidden = true
                    self.refreshButton.hidden = false
                })
            }
            else {
                let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                networkIssueController.addAction(okButton)
                self.presentViewController(networkIssueController, animated: true, completion: nil)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.refreshActivity.stopAnimating()
                    self.refreshActivity.hidden = true
                    self.refreshButton.hidden = false
                })
            }
        })
        
        downloadTask.resume()
    }
    
    @IBAction func refresh() {
        refreshButton.hidden = true
        refreshActivity.hidden = false
        refreshActivity.startAnimating()
        getWeatherDataForDate(datePicker.date)
    }
    
    @IBAction func dateChanged() {
        getWeatherDataForDate(datePicker.date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

