import UIKit
import RxSwift
import RxCocoa

class TodayViewController: UIViewController {
    
    let viewModel = TodayViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTabBarItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.navigationTitle
        
        configureRx()
    }
    
    func configureRx() {
        viewModel.locationDescription.bind(to: currentLocationLabel.rx.text).disposed(by: disposeBag)
        viewModel.weatherDescription.bind(to: weatherDescriptionLabel.rx.text).disposed(by: disposeBag)
        viewModel.weatherIconName.map { (imageName) -> UIImage? in
            guard let imageName = imageName else {
                return nil
            }
            return UIImage(named: imageName)
            }.bind(to: weatherIconImageView.rx.image).disposed(by: disposeBag)
    }
    
    func configureTabBarItem() {
        let tabBarItemImage = UIImage(named: "25x25 Today Inactive (Tab)")?.withRenderingMode(.alwaysOriginal)
        let tabBarItemSelectedImage = UIImage(named: "25x25 Today Active (Tab)")?.withRenderingMode(.alwaysOriginal)
        tabBarItem = UITabBarItem(title: viewModel.navigationTitle,
                                  image: tabBarItemImage,
                                  selectedImage: tabBarItemSelectedImage)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        print("Share attempt")
    }
}
