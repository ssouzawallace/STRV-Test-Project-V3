import Foundation
import RxSwift

class TodayViewModel {
    enum ViewState {
        case loading
        case loaded
        case error
    }
    
    struct WeatherFeature {
        let iconName: String
        let value: String
    }
    
    private let weatherResult = BehaviorSubject<Result<WeatherResponse>?>(value: nil)
    
    private let timer: DispatchSourceTimer
    
    init() {
        let fetchPeriod = 5.0
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: DispatchTime.now(), repeating: fetchPeriod)
        timer.setEventHandler {
            self.fetchWeather()
        }
        timer.resume()
    }
    
    deinit {
        timer.cancel()
    }
    
    func fetchWeather() {
        if let latestCoordinate = LocationObserver.sharedInstance.latestCoordinate {
            WeatherFetcher().fetchWeatherAt(lat: latestCoordinate.latitude, lon: latestCoordinate.longitude).observe { [weak self] result in
                self?.weatherResult.onNext(result)
                
                if case .failure = result {
                    self?.fetchWeather()
                }
            }
        }
    }
    
    // MARK - Public observables
    
    var navigationTitle: String = .today
    
    var errorMessage: Observable<String?> {
        return weatherResult.map { result in
            guard case .failure(let error)? = result else {
                return nil
            }
            return error.localizedDescription
        }
    }
    
    var viewState: Observable<ViewState> {
        return weatherResult.map { result in
            if case .success? = result {
                return .loaded
            } else if case .failure? = result {
                return .error
            } else {
                return .loading
            }
        }
    }
    
    var locationDescription: Observable<String?> {
        return weatherResult.map { _ in
            let locationObserver = LocationObserver.sharedInstance
            guard let currentCity = locationObserver.currentCity, let currentCountry = locationObserver.currentCountry else {
                return nil
            }
            return currentCity + ", " + currentCountry
        }
    }
    
    var weatherDescription: Observable<(String?, String)?> {
        return weatherResult.map { result in
            guard case .success(let weatherResponse)? = result else {
                return nil
            }
            let temperature = weatherResponse.main.temp
            let mainName = weatherResponse.weather.first?.main ?? ""
            
            return (Int(temperature).description + "ºC", mainName)
        }
    }
    
    var weatherIconName: Observable<String?> {
        return weatherResult.map { result in
            guard case .success(let weatherResponse)? = result else {
                return nil
            }
            return weatherResponse.weather.first?.iconImageName(forSize: .big)
        }
    }
    
    var weatherFeatures: Observable<[WeatherFeature]> {
        return weatherResult.map { result in
            guard case .success(let weatherResponse)? = result else {
                return []
            }
            var features: [WeatherFeature] = []
            
            if let humidity = weatherResponse.main.humidity {
                features.append(WeatherFeature(iconName: "30x30 Humidity (Other)",
                                               value: Int(humidity).description + "%"))
            }
            if let precipitation = weatherResponse.rain?.lastHour ?? weatherResponse.rain?.lastThreeHours {
                features.append(WeatherFeature(iconName: "30x30 Precipitation (Other)",
                                               value: precipitation.description + " mm"))
            }
            if let pressure = weatherResponse.main.pressure {
                features.append(WeatherFeature(iconName: "30x30 Pressure (Other)",
                                               value: Int(pressure).description + " hPa"))
            }
            if let windSpeed = weatherResponse.wind.speed {
                features.append(WeatherFeature(iconName: "30x30 Wind (Other)",
                                               value: Int(windSpeed).description + "  km/h"))
            }
            if let direction = weatherResponse.wind.cardinalDirection {
                features.append(WeatherFeature(iconName: "30x30 Wind Direction (Other)",
                                               value: direction.rawValue))
            }
            
            return features
        }
    }
}

fileprivate extension String {
    static let today = NSLocalizedString("Today", comment: "Title of the Today section.")
}

