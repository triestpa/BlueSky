//
//  DetailViewController.swift
//  BlueSky
//
//  Created by Patrick on 11/18/14.
//  Copyright (c) 2014 Patrick Triest. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

    var urlSession: NSURLSession!
    let apiID = "6b120251e9c87a7c31a21ee14f0a8eef"
    
    var weatherReport: NSDictionary!
    var weatherLocation: String!

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlSession = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        
        if weatherLocation != nil {
            queryOpenWeather(Location: weatherLocation)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func queryOpenWeather(Location location: String) {
        //Remove spaces to avoid malformed URLs
        let formatedLocation = location.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" + formatedLocation + "&APPID=" + apiID
        let url = NSURL(string: urlString as NSString)
        
        let dataTask = urlSession.dataTaskWithURL(url!, completionHandler: {data, response, error in
            let response = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            if let weatherReport: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as?NSDictionary {
                self.weatherReport = weatherReport as NSDictionary

                //Check for an error message in the response
                if let errorMessage = weatherReport["message"] {
                    let errorCode: NSString = weatherReport["cod"] as NSString
                    println(errorMessage as NSString + ", Code: " + errorCode)
                    
                }
                else {
                    let weatherDataArray = weatherReport["weather"] as NSArray
                    let weatherDataDict = weatherDataArray[0]
                    self.detailDescriptionLabel.text = weatherDataDict["description"] as NSString
                }
                //extract image using http://openweathermap.org/weather-conditions
            }
            else {
                print("JSON Parse Error")
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dataTask.resume()
    }
}

