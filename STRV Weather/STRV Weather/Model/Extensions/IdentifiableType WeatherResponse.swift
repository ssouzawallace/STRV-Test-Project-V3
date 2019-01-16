import Foundation
import RxDataSources

extension WeatherResponse: IdentifiableType, Hashable {
    
    var hashValue: Int { return dt.hashValue }
    
    static func ==(lhs: WeatherResponse, rhs: WeatherResponse) -> Bool {
        return lhs.dt == rhs.dt
    }
    
    var identity: Double { return dt }
}
