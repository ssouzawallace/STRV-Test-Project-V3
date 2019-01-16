import Foundation
import CoreLocation
import SwiftLocation

class LocationObserver {
    
    // MARK: Singleton
    
    static let sharedInstance = LocationObserver()
    
    private init() { /* do nothing */ }
    
    // MARK: Public API
    
    var latestCoordinate: CLLocationCoordinate2D?
    
    var currentCity: String?
    
    var currentCountry: String?
    
    func startUpdating() {
        Locator.subscribePosition(accuracy: .city, onUpdate: { location in
            self.latestCoordinate = location.coordinate
            
            Locator.location(fromCoordinates: location.coordinate, onSuccess: { place in
                self.currentCity = place.first?.city
                self.currentCountry = place.first?.country
            }, onFail: { error in
                print("Error getting plcae: \(error)")
            })
        }, onFail: { error, _ in
            print("Error getting location: \(error)")
        })
    }
}
