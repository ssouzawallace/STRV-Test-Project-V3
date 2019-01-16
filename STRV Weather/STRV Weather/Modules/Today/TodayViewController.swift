import UIKit
import RxSwift
import RxCocoa

class TodayViewController: UIViewController {
    
    let viewModel = TodayViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.navigationTitle.asObservable().bind(to: rx.title).disposed(by: disposeBag)
        
        viewModel.weatherDescription.bind(to: weatherLabel.rx.text).disposed(by: disposeBag)
        viewModel.weatherIconName.map { (imageName) -> UIImage? in
            guard let imageName = imageName else {
                return nil
            }
            return UIImage(named: imageName)
            }.bind(to: weatherIconImageView.rx.image).disposed(by: disposeBag)
    }
    
}
