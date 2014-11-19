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
    
    var weatherLocation: String? {
        didSet {
            if isViewLoaded() {
                queryOpenWeather(Location: weatherLocation!)
            }
        }
    }
    
    func setLocation (location: NSString) {
        self.weatherLocation = location
    }
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queryOpenWeather(Location: weatherLocation!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func queryOpenWeather(Location location: String) {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlSession = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        
        //Remove spaces to avoid malformed URLs
        let formatedLocation = location.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" + formatedLocation + "&APPID=" + apiID
        
        if let url = NSURL(string: urlString as NSString) {
            let dataTask = urlSession.dataTaskWithURL(url, completionHandler: {data, response, error in
                let response = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                // Detect http request error
                if error != nil {
                    self.showErrorAlert("You broke the Internet. Just send a screenshot of this to the developer to find out what went wrong: \(error)")
                }
                else {
                    // Parse JSON
                    if let weatherReport: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as?NSDictionary {
                        self.weatherReport = weatherReport as NSDictionary
                        
                        //Check for an error message within the response
                        if let errorMessage: NSString = weatherReport["message"] as? NSString {
                            let errorCode: NSString = weatherReport["cod"] as NSString
                            println(errorMessage + ", Code: " + errorCode)
                            self.showErrorAlert(errorMessage)
                        }
                        else {
                            println(response)
                            let weatherDataArray = weatherReport["weather"] as NSArray
                            let weatherDataDict = weatherDataArray[0] as NSDictionary
                            self.detailDescriptionLabel.text = weatherDataDict["description"] as NSString
                        }
                        //extract image using http://openweathermap.org/weather-conditions
                    }
                    else {
                        //Catch parsing error
                        print("JSON Parse Error")
                        self.showErrorAlert("JSON Parse Error")
                    }
                }
                //Hide progress indicator
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            
            //Show progress indicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            dataTask.resume()
            
        }
        //Catch NSURL formation error
        else {
            showErrorAlert("Invalid URL. You Must Be Trying to Find A Really Weird Place")
        }
    }
    
    func showErrorAlert(errorMessage: NSString) {
        var alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        var okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            //TODO why doesnt this work?
            self.navigationController?.popToRootViewControllerAnimated(true)
            return
        })
        alert.addAction(okAction)
    }
    
}

