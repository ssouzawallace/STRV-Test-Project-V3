import UIKit
import SwiftLocation

class AppTabBarController: UITabBarController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Locator.requestAuthorizationIfNeeded()
        
        LocationObserver.sharedInstance.startUpdating()
        
        configureChildren()
        configureStyle()
    }
    
    func configureStyle() {
        tabBar.barTintColor = .white
        let normalTitleTextAttributes = [NSAttributedString.Key.font: UIFont.proximaNova(of: .semibold, withSize: 10),
                                         NSAttributedString.Key.foregroundColor: UIColor(white: 51/255, alpha: 1)]
        let selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 47/255, green: 145/255, blue: 255/255, alpha: 1)]
        children.forEach { child in
            child.tabBarItem.setTitleTextAttributes(normalTitleTextAttributes,
                                                    for: .normal)
            
            child.tabBarItem.setTitleTextAttributes(selectedTitleTextAttributes,
                                                    for: .selected)
        }
    }
    
    func configureChildren() {
        if let todayViewController = UIStoryboard(name: "Today", bundle: nil).instantiateInitialViewController(),
            let forecastViewController = UIStoryboard(name: "Forecast", bundle: nil).instantiateInitialViewController() {
            viewControllers = [todayViewController,
                               forecastViewController]
        }
    }
}

