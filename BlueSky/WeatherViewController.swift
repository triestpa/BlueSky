//
//  DetailViewController.swift
//  BlueSky
//
//  Created by Patrick on 11/18/14.
//  Copyright (c) 2014 Patrick Triest. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (weatherLocation != nil) {
            navigationItem.title = weatherLocation?
            navigationController
            queryOpenWeather(Location: weatherLocation!)
        }
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
        
        let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" + formatedLocation + "&APPID=" + apiID  + "&units=metric"
        
        println(urlString)
        
        if let url = NSURL(string: urlString as NSString) {
            makeNetworkRequest(url)
        }
        else {
            //Catch NSURL formation error
            showErrorAlert("Invalid URL. You Must Be Trying to Find A Really Weird Place")
        }
    }
    
    func makeNetworkRequest(url: NSURL) {
        let dataTask = urlSession.dataTaskWithURL(url, completionHandler: {data, response, error in
            let response = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            // Detect http request error
            if error != nil {
                self.showErrorAlert("Web Request Failed, Make Sure The Internet on Your Device is Working")
            }
            else {
                println(response)
                self.parseResult(data)
            }
            //Hide progress indicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        //Show progress indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dataTask.resume()
    }
    
    func parseResult(data: NSData) {
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
                let weatherDataArray = weatherReport["weather"] as NSArray
                let weatherDataDict = weatherDataArray[0] as NSDictionary
                
                let temperatureDict = weatherReport["main"] as NSDictionary
                
                let currentTemp = temperatureDict["temp"] as NSNumber
                
                self.currentTempLabel.text = currentTemp.stringValue + " °C"
                self.iconImageView.image = UIImage(named: weatherDataDict["icon"] as NSString)
                self.minTempLabel.text = (temperatureDict["temp_min"] as NSNumber).stringValue + " °C"
                self.maxTempLabel.text = (temperatureDict["temp_max"] as NSNumber).stringValue + " °C"
                self.weatherConditionLabel.text = weatherDataDict["description"] as NSString
                
                setBackgroundPicture(weatherDataDict["id"] as Int)
            }
        }
        else {
            //Catch parsing error
            print("JSON Parse Error")
            self.showErrorAlert("JSON Parse Error")
        }
    }
    
    func showErrorAlert(errorMessage: NSString) {
        var alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        var okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            //TODO why doesnt this work?
            self.navigationController?.popToRootViewControllerAnimated(true)
            //self.navigationController?.dismissViewControllerAnimated(false, completion: nil)
            return
        })
        alert.addAction(okAction)
    }
    
    
    func setBackgroundPicture(code: Int) {
        
        println(code)
        
        var backgroudImage: UIImage
        if (code < 600) {
            backgroudImage = UIImage(named: "rain.png")!
        }
        else if (code < 700) {
            backgroudImage = UIImage(named: "snow.png")!
        }
        else if (code == 800) {
            backgroudImage = UIImage(named: "bluesky.png")!
        }
        else if (code < 800) {
            backgroudImage = UIImage(named: "mist.png")!
        }
        else if (code < 900) {
            backgroudImage = UIImage(named: "cloudy.png")!
        }
        else if (code < 950){
            backgroudImage = UIImage(named: "rain.png")!
        }
        else {
            backgroudImage = UIImage(named: "bluesky.png")!
        }
        
        UIView.animateWithDuration(1.5, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8,
            options: .CurveEaseOut
            , animations: {
                self.view.backgroundColor = UIColor(patternImage: backgroudImage)
            }, completion: nil)

    }
}

