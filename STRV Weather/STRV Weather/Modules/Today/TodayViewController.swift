import UIKit
import RxSwift
import RxCocoa

class TodayViewController: UIViewController {
    
    let viewModel = TodayViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.navigationTitle.asObservable().bind(to: rx.title).disposed(by: disposeBag)
        viewModel.locationDescription.bind(to: currentLocationLabel.rx.text).disposed(by: disposeBag)
        viewModel.weatherDescription.bind(to: weatherDescriptionLabel.rx.text).disposed(by: disposeBag)
        viewModel.weatherIconName.map { (imageName) -> UIImage? in
            guard let imageName = imageName else {
                return nil
            }
            return UIImage(named: imageName)
            }.bind(to: weatherIconImageView.rx.image).disposed(by: disposeBag)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        print("Share attempt")
    }
}
