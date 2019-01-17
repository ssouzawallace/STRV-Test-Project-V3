import Foundation
import RxSwift
import RxDataSources
import CoreLocation

class ForecastViewModel: BaseViewModel<ForecastResponse> {
    
    
    var tabTitle: String = .forecast
    
    var navigationTitle: Observable<String?> {
        return observableResult.map { result in
            guard case .success? = result else {
                return self.tabTitle
            }
            return LocationObserver.sharedInstance.currentCity
        }
    }
    
    var predictions: Observable<[SectionModel<Int, WeatherResponse>]> {        
        return observableResult.map { result in
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

extension ForecastViewModel: BaseViewModelProtocol {
    var fetchEndpoint: Endpoint? {
        guard let latestCoordinate = LocationObserver.sharedInstance.latestCoordinate else {
            return nil
        }
        return Endpoint.fetchForecastAt(latestCoordinate.latitude,
                                        lon: latestCoordinate.longitude)
    }
}

fileprivate extension String {
    static let forecast = NSLocalizedString("Forecast", comment: "Title of the Today section.")
}
