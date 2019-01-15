import UIKit
import RxSwift
import RxCocoa

class TodayViewController: UIViewController {
    
    let viewModel = TodayViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.navigationTitle.asObservable().bind(to: rx.title).disposed(by: disposeBag)
    }
}
