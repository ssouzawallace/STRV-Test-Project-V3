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
}
