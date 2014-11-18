//
//  DetailViewController.swift
//  BlueSky
//
//  Created by Patrick on 11/18/14.
//  Copyright (c) 2014 Patrick Triest. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var urlSession: NSURLSession!
    let apiID = "6b120251e9c87a7c31a21ee14f0a8eef"
    
    var weatherReport: NSDictionary!


    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlSession = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        
        queryOpenWeather(Location: "Boston")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func queryOpenWeather(Location location: String) {
        
        let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" + location + "&APPID=" + apiID
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
                
                //self.tableView.reloadData()
                //update view
                
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

