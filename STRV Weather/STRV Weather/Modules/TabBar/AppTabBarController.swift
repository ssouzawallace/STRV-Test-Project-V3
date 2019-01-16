import UIKit
import SwiftLocation

class AppTabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = .white
        
        Locator.requestAuthorizationIfNeeded()
        
        LocationObserver.sharedInstance.startUpdating()
        
        configureChildren()        
    }
    
    func configureChildren() {
        if let todayViewController = UIStoryboard(name: "Today", bundle: nil).instantiateInitialViewController(),
            let forecastViewController = UIStoryboard(name: "Forecast", bundle: nil).instantiateInitialViewController() {
            viewControllers = [todayViewController,
                               forecastViewController]
        }
    }
}

