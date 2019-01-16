import Foundation
import RxSwift
import RxDataSources

class ForecastViewModel {
    
    private static let fetchPeriod = 10.0
    
    private let forecast: Observable<ForecastResponse?>
    
    init() {
        let spLat: Double = -23.547400
        let spLon: Double = -46.644026
        
        forecast = Observable<ForecastResponse?>.create { observer in
            Timer.scheduledTimer(withTimeInterval: ForecastViewModel.fetchPeriod, repeats: true) { _ in
                WeatherFetcher().fetchForecastAt(lat: spLat, lon: spLon).observe { result in
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
    
    var navigationTitle: Variable<String> = Variable("TODO: current city")
    
    var tabTitle: Variable<String> = Variable(.forecast)

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
