import Foundation
import RxSwift

class TodayViewModel {
    
    private static let fetchPeriod = 10.0
    
    private let weather: Observable<WeatherResponse?> = Observable<WeatherResponse?>.create { observer in
        Timer(timeInterval: TodayViewModel.fetchPeriod, repeats: true) { _ in
            WeatherFetcher().fetchWeatherAt(lat: 0, lon: 0).observe { result in
                switch (result) {
                case .success(let value):
                    observer.onNext(value)
                case .failure(let error):
                    print(error)
                }
            }
        }.fire()
        return Disposables.create()
    }
    
    // MARK - Public observables
    
    var navigationTitle: Variable<String> = Variable(.today)
    
    var locationDescription: Observable<String?> {
        return weather.map { _ in
            let locationObserver = LocationObserver.sharedInstance
            guard let currentCity = locationObserver.currentCity, let currentCountry = locationObserver.currentCountry else {
                return nil
            }
            return currentCity + ", " + currentCountry
        }
    }
    
    var weatherDescription: Observable<String?> {
        return weather.map {
            guard let temperature = $0?.main.temp, let mainName = $0?.weather.first?.main else {
                return nil
            }
            return Int(temperature).description + "ºC" + " | " + mainName
        }
    }
    
    var weatherIconName: Observable<String?> {
        return weather.map {
            return $0?.weather.first?.iconImageName(forSize: .big)
        }
    }
}

fileprivate extension String {
    static let today = NSLocalizedString("Today", comment: "Title of the Today section.")
}

