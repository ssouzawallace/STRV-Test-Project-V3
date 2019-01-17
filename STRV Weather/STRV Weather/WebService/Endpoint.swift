import Foundation

struct Endpoint {
    enum Error: Swift.Error {
        case invalidURL
    }
    
    let path: String
    let queryItems: [URLQueryItem]
}

extension Endpoint {
    static func fetchWeatherAt(lat: Double, lon: Double) -> Endpoint {
        return Endpoint(
            path: "/data/2.5/weather",
            queryItems: [
                URLQueryItem(name: "lat", value: lat.description),
                URLQueryItem(name: "lon", value: lon.description)
            ]
        )
    }
    
    static func fetchForecastAt(lat: Double, lon: Double) -> Endpoint {
        return Endpoint(
            path: "/data/2.5/forecast",
            queryItems: [
                URLQueryItem(name: "lat", value: lat.description),
                URLQueryItem(name: "lon", value: lon.description)
            ]
        )
    }
}

extension Endpoint {
    var commonQueryItems: [URLQueryItem] {
        return [URLQueryItem(name: "units",
                      value: "metric"),
                URLQueryItem(name: "APPID",
                      value: "c24e21ebebee093dc832ddc161134d91")]
    }
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = path
        components.queryItems = queryItems + commonQueryItems
        return components.url
    }
}
