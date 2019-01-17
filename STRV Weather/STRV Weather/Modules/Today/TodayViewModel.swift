import Foundation
import RxSwift

class TodayViewModel {
    
    let disposeBag = DisposeBag()
    
    private let weather = PublishSubject<WeatherResponse?>()
    
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
                switch (result) {
                case .success(let value):
                    if let weatherObserver = self?.weather.asObserver(), let disposeBag = self?.disposeBag {
                        Observable.just(value).bind(to: weatherObserver).disposed(by: disposeBag)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    // MARK - Public observables
    
    var navigationTitle: String = .today
    
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

