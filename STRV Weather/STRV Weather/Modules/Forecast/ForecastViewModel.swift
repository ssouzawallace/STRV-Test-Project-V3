import Foundation
import RxSwift
import RxDataSources
import CoreLocation

class ForecastViewModel {
    enum ViewState {
        case loading
        case loaded
        case error
    }
    
    private let forecastResult = BehaviorSubject<Result<ForecastResponse>?>(value: nil)
    
    private let timer: DispatchSourceTimer
    
    init() {
        let fetchPeriod = 5.0
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: DispatchTime.now(), repeating: fetchPeriod)
        timer.setEventHandler {
            self.fetchForecast()
        }
        timer.resume()
    }
    
    deinit {
        timer.cancel()
    }
    
    func fetchForecast() {
        if let latestCoordinate = LocationObserver.sharedInstance.latestCoordinate {
            WeatherFetcher().fetchForecastAt(lat: latestCoordinate.latitude, lon: latestCoordinate.longitude).observe { [weak self] result in
                self?.forecastResult.onNext(result)
                
                if case .failure = result {
                    self?.fetchForecast()
                }
            }
        }
    }
    
    // MARK - Public observables
    
    var errorMessage: Observable<String?> {
        return forecastResult.map { result in
            guard case .failure(let error)? = result else {
                return nil
            }
            return error.localizedDescription
        }
    }
    
    var tabTitle: String = .forecast
    
    var navigationTitle: Observable<String?> {
        return forecastResult.map { result in
            guard case .success? = result else {
                return self.tabTitle
            }
            return LocationObserver.sharedInstance.currentCity
        }
    }
    
    var viewState: Observable<ViewState> {
        return forecastResult.map { result in
            if case .success? = result {
                return .loaded
            } else if case .failure? = result {
                return .error
            } else {
                return .loading
            }
        }
    }
    
    var predictions: Observable<[SectionModel<Int, WeatherResponse>]> {        
        return forecastResult.map { result in
            guard case .success(let forecastResponse)? = result else {
                return []
            }
            let items = forecastResponse.list
            let groupedItems = Dictionary(grouping: items, by: { (item) -> Int in
                let date = Date(timeIntervalSince1970: item.dt)
                return Calendar.current.component(.day, from: date)
            })
            
            let sectionModel = groupedItems.sorted(by: {
                return $0.key < $1.key
            }).enumerated().map( {
                return SectionModel(model: $0.offset, items: $0.element.value)
            })
            return sectionModel
        }
    }
}

fileprivate extension String {
    static let forecast = NSLocalizedString("Forecast", comment: "Title of the Today section.")
}
