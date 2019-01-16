import Foundation

class WeatherFetcher {
    
    private let networking: Networking
    
    init(networking: @escaping Networking = URLSession.shared.request) {
        self.networking = networking
    }
    
    func fetchWeatherAt(lat: Double, lon: Double) -> Future<WeatherResponse> {
        let endpoint = Endpoint.fetchWeatherAt(lat, lon: lon)
        return networking(endpoint).decoded()
    }
    
    func fetchForecastAt(lat: Double, lon: Double) -> Future<ForecastResponse> {
        let endpoint = Endpoint.fetchForecastAt(lat, lon: lon)
        return networking(endpoint).decoded()
    }
}
