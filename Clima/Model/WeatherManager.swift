//
//  WeatherManager.swift
//  Clima
//
//  Created by Арстан on 2/6/22.

//

import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager,weather: WeatherModel)
    func didFailWithError (error : Error)
}
struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=e54558155addeaae5ac33d078d94ccf5&units=metric"
    
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(cityName : String){
        
        let urlString = "\(weatherURL)&q=\(cityName)"
        self.performRequest(urlString: urlString)
        
    }
    func fetchWeather (latitude: CLLocationDegrees,longtitude: CLLocationDegrees){
    let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longtitude)"
        performRequest(urlString: urlString)
    }

    func performRequest (urlString : String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                }
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        let weatherVC = WeatherViewController()
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    func parseJSON (weatherData: Data)-> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
            
        }catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
}

