import UIKit

class AppNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = .white
        
        let shadowImage = UIImage(named: "2px Line")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar.shadowImage = shadowImage
        
        let titleTextAttributes = [NSAttributedString.Key.font: UIFont.proximaNova(of: .semibold, withSize: 18),
                                   NSAttributedString.Key.foregroundColor: UIColor(white: 51/255, alpha: 1)]
        navigationBar.titleTextAttributes = titleTextAttributes
    }
}
