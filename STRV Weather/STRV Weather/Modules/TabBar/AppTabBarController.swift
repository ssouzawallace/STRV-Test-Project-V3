import UIKit
import SwiftLocation

class AppTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Locator.requestAuthorizationIfNeeded()
        
        LocationObserver.sharedInstance.startUpdating()
        
        if let todayViewController = UIStoryboard(name: "Today", bundle: nil).instantiateInitialViewController(),
            let forecastViewController = UIStoryboard(name: "Forecast", bundle: nil).instantiateInitialViewController() {
            viewControllers = [todayViewController,
                               forecastViewController]
        }
    }
}

