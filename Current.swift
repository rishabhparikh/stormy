//
//  Current.swift
//  Stormy
//
//  Created by Rishabh Parikh on 1/9/15.
//  Copyright (c) 2015 Rishabh Parikh. All rights reserved.
//

import Foundation
import UIKit

struct Current {
    var currentTime: String?
    var temperature: Int?
    var humidity: Double?
    var precipProbability: Double?
    var summary: String?
    var icon: UIImage?
    
    init(weatherDictionary: NSDictionary) {
        let currentWeather: NSDictionary = weatherDictionary["currently"] as NSDictionary
        self.temperature = currentWeather["temperature"] as? Int
        self.humidity = currentWeather["humidity"] as? Double
        self.precipProbability = currentWeather["precipProbability"] as? Double
        self.summary = currentWeather["summary"] as? String
        self.currentTime = dateStringFromUNIXTime(currentWeather["time"] as Int)
        self.icon = weatherIconFromString(currentWeather["icon"] as String)
    }
    
    func dateStringFromUNIXTime(unixTIme: Int) -> String {
        let timeInSecs = NSTimeInterval(unixTIme)
        let currentDate = NSDate(timeIntervalSince1970: timeInSecs)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(currentDate)
    }
    
    func weatherIconFromString(stringIcon: String) -> UIImage {
        var imageName: String
        
        switch stringIcon {
            case "clear-day":
                imageName = "clear-day"
            case"clear-night":
                imageName = "clear-night"
            case "rain":
                imageName = "rain"
            case "snow":
                imageName = "snow"
            case "sleet":
                imageName = "sleet"
            case "wind":
                imageName = "wind"
            case "fog":
                imageName = "fog"
            case "cloudy":
                imageName = "cloudy"
            case "partly-cloudy-day":
                imageName = "partly-cloudy"
            case "partly-cloudy-night":
                imageName = "cloudy-night"
            default:
                imageName = "default"
        
        }
        
        return UIImage(named: imageName)!
    }
}