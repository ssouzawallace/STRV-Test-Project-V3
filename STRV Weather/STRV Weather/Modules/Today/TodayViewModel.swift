import Foundation
import RxSwift

class TodayViewModel {
    
    private let weather: Observable<WeatherResponse?>
    
    init() {
        let spLat: Double = -23.547400
        let spLon: Double = -46.644026
        
        weather = Observable<WeatherResponse?>.create { observer in
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                WeatherFetcher().fetchWeatherAt(lat: spLat, lon: spLon).observe { result in
                    switch (result) {
                    case .success(let value):
                        observer.onNext(value)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK - Public observables
    
    var navigationTitle: Variable<String> = Variable(.today)
    
    var weatherDescription: Observable<String?> {
        return weather.map {
            guard let temperature = $0?.main.temp.description, let mainName = $0?.weather.first?.main else {
                return nil
            }
            return temperature + " | " + mainName
        }
    }
    
    var weatherIconName: Observable<String?> {
        return weather.map {
            guard let mainName = $0?.weather.first?.main else {
                return nil
            }
            let hour = Calendar.current.component(.hour, from: Date())
            let dayPeriod = hour > 5 && hour < 18 ? "Day" : "Night" // TODO: use sunrise and sunset
            return "100x100 " + mainName + " " + "(" + dayPeriod + ")"
        }
    }
}

fileprivate extension String {
    static let today = NSLocalizedString("Today", comment: "Title of the Today section.")
}

