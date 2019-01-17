import Foundation
import RxSwift

class TodayViewModel: BaseViewModel<WeatherResponse> {
    struct WeatherFeature {
        let iconName: String
        let value: String
    }
    
    let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        observableResult.subscribe(onNext: { [weak self] result in
            if case .success(let response)? = result {
                self?.firebaseLog(response: response)
            }
        }).disposed(by: disposeBag)
    }
    
    func firebaseLog(response: WeatherResponse) {
        guard let lat = response.coord?.lat, let lon = response.coord?.lon else {
            return
        }
        FirebaseUtils.sharedInstance.log(userEmail: "email@super.fake",
                                         temperature: response.main.temp,
                                         latitude: lat,
                                         longitude: lon)
    }
    
    // MARK - Public observables
    
    var navigationTitle: String = .today
    
    var locationDescription: Observable<String?> {
        return observableResult.map { _ in
            let locationObserver = LocationObserver.sharedInstance
            guard let currentCity = locationObserver.currentCity, let currentCountry = locationObserver.currentCountry else {
                return nil
            }
            return currentCity + ", " + currentCountry
        }
    }
    
    var weatherDescription: Observable<(String?, String)?> {
        return observableResult.map { result in
            guard case .success(let weatherResponse)? = result else {
                return nil
            }
            let temperature = weatherResponse.main.temp
            let mainName = weatherResponse.weather.first?.main ?? ""
            
            return (Int(temperature).description + "ºC", mainName)
        }
    }
    
    var weatherIconName: Observable<String?> {
        return observableResult.map { result in
            guard case .success(let weatherResponse)? = result else {
                return nil
            }
            return weatherResponse.weather.first?.iconImageName(forSize: .big)
        }
    }
    
    var weatherFeatures: Observable<[WeatherFeature]> {
        return observableResult.map { result in
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
extension TodayViewModel: BaseViewModelProtocol {
    var fetchEndpoint: Endpoint? {
        guard let latestCoordinate = LocationObserver.sharedInstance.latestCoordinate else {
            return nil
        }
        return Endpoint.fetchWeatherAt(latestCoordinate.latitude,
                                       lon: latestCoordinate.longitude)
    }
}

fileprivate extension String {
    static let today = NSLocalizedString("Today", comment: "Title of the Today section.")
}

