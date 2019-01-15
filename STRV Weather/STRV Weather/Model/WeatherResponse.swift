import Foundation

struct WeatherResponse: Codable {
    let weather: [Weather]
    let main: WeatherMain
    let wind: Wind
    let rain: Rain?
    let name: String
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct WeatherMain: Codable {
    let temp: Double
    let pressure: Double
    let humidity: Double
}

struct Wind: Codable {
    let speed: Double
    let deg: Double
}

struct Rain: Codable {
    private enum CodingKeys: String, CodingKey {
        case lastHour = "1h"
        case lastThreeHours = "3h"
    }
    
    let lastHour: Double?
    let lastThreeHours: Double?
}
