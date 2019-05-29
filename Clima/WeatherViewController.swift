//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire //if can't be built - run build again
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "a59f163c4f30aa70cee27bdb10a54765"//my own appId
    /***Get your own App ID at https://openweathermap.org/appid ****/
    var toCelcius:Bool = true

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() //asynchronus method (runs in the background)
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String, parameters:Dictionary<String, String>) {
        //handles requests asynchronously
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in //once response is made - sends it to this reponse object
            if response.result.isSuccess {
                print("Success! Got the weather data")
                let weatherJSON:JSON = JSON(response.result.value!) //Method from swiftyJSON
                //because the following doesn't work
//              let weatherJSON:JSON = response.result.value as! JSON
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON) {
        if let tempResult = json["main"]["temp"].double {//functionality provided by Swifty JSON to double
            var convert:Double
            if toCelcius {
                convert = 273.15
            } else {convert = 0.0}
            weatherDataModel.temperature = Int(tempResult - convert) //Kelvin to Celcius conversion
            weatherDataModel.city = json["name"].stringValue //name of the city
            weatherDataModel.condition = json["weather"][0]["id"].intValue //conidtions codes that match website api codes
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
           
        }
    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        var tempString:String
        if toCelcius { tempString = "\(weatherDataModel.temperature)°C"}
        else{tempString = "\(weatherDataModel.temperature)°F"}
        temperatureLabel.text = tempString
        weatherIcon.image = UIImage(named:weatherDataModel.weatherIconName)
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {//make sure that the value is not invalid
            locationManager.stopUpdatingHeading()
            locationManager.delegate = nil // stop console from printing repeatedly (as it take time for .stopUpdating() to take effect)
            locationManager.delegate = self
            print("longitude = \(location.coordinate.longitude), lattitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params:[String:String] = ["lat":latitude,
                                          "lon":longitude,
                                          "appid":APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }

    //MARK: - Change City Delegate methods
    /***************************************************************/
    func userEnteredNewCityName(city: String) {
//        print(city)
        let params:[String:String] = ["q":city,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "unknown" {
        case "changeCityName":
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        case "unknown":
            print("unkown")
        default:
            print("default")
        }
    }
    
    
    @IBAction func toCelcius(_ sender: Any) {
        if toCelcius {
        toCelcius = false
        } else {toCelcius = true}
        print("toCelcius = \(toCelcius)")
        locationManager.startUpdatingLocation()
    print("locationManager.startUpdatingLocation()")
    }
    

}


