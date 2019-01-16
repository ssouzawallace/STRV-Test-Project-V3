import UIKit

class AppNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = .white
        
        let shadowImage = UIImage(named: "2px Line")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar.shadowImage = shadowImage
    }
}
