import Foundation
import RxSwift

class TodayViewModel {
    
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
            }
        }
    }
    
    // MARK - Public observables
    
    var navigationTitle: String = .today
    
    var locationDescription: Observable<String?> {
        return weatherResult.map { _ in
            let locationObserver = LocationObserver.sharedInstance
            guard let currentCity = locationObserver.currentCity, let currentCountry = locationObserver.currentCountry else {
                return nil
            }
            return currentCity + ", " + currentCountry
        }
    }
    
    var weatherDescription: Observable<String?> {
        return weatherResult.map { result in
            guard case .success(let weatherResponse)? = result else {
                return nil
            }
            let temperature = weatherResponse.main.temp
            let mainName = weatherResponse.weather.first?.main ?? ""
            
            return Int(temperature).description + "ºC" + " | " + mainName
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
}

fileprivate extension String {
    static let today = NSLocalizedString("Today", comment: "Title of the Today section.")
}

