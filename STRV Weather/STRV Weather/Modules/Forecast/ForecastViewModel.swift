import Foundation
import RxSwift
import RxDataSources
import CoreLocation

class ForecastViewModel {
    private static let fetchPeriod = 60.0
    
    private let forecast: Observable<ForecastResponse?>
    
    init() {
        forecast = Observable<ForecastResponse?>.create { observer in
            Timer(timeInterval: ForecastViewModel.fetchPeriod, repeats: true) { _ in
                if let latestCoordinate = LocationObserver.sharedInstance.latestCoordinate {
                    WeatherFetcher().fetchForecastAt(lat: latestCoordinate.latitude, lon: latestCoordinate.longitude).observe { result in
                        switch (result) {
                        case .success(let value):
                            observer.onNext(value)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                
            }.fire()
            return Disposables.create()
        }
    }
    
    // MARK - Public observables
    
    var navigationTitle: Observable<String?> {
        return forecast.map { _ in
            return LocationObserver.sharedInstance.currentCity
        }
    }
    
    var tabTitle: String = .forecast

    var predictions: Observable<[AnimatableSectionModel<Int, WeatherResponse>]> {
        return forecast.map {
            let items = $0?.list ?? []
            let groupedItems = Dictionary(grouping: items, by: { (item) -> Int in
                let date = Date(timeIntervalSince1970: item.dt)
                return Calendar.current.component(.day, from: date)
            })
            
            let sectionModel = groupedItems.sorted(by: {
                return $0.key < $1.key
            }).enumerated().map( {
                return AnimatableSectionModel(model: $0.offset, items: $0.element.value)
            })
            return sectionModel
        }
    }
}

fileprivate extension String {
    static let forecast = NSLocalizedString("Forecast", comment: "Title of the Today section.")
}
