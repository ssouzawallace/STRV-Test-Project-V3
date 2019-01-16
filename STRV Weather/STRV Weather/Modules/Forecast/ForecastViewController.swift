import UIKit
import RxSwift
import RxCocoa
import RxDataSources

extension Reactive where Base: UITabBarItem {
    
    /// Bindable sink for `badgeValue` property.
    public var title: Binder<String?> {
        return Binder(self.base) { tabBarItem, title in
            tabBarItem.title = title
        }
    }
    
}

class ForecastViewController: UIViewController {
    
    let viewModel = ForecastViewModel()
    let disposeBag = DisposeBag()
    
    let dataSource = ForecastViewController.dataSource()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tabTitle.asObservable().bind(to: rx.title).disposed(by: disposeBag)
        viewModel.navigationTitle.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        viewModel.predictions.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    private static func dataSource() -> RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<Int, WeatherResponse>> {
        return RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<Int, WeatherResponse>>(
            configureCell: { (dataSource, table, indexPath, item) in
                let identifier = "weatherCell"
                let cell = table.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WeatherCell // TODO: remove bang!
                
                if let iconImageName = item.weather.first?.iconImageName(forSize: .small) {
                    cell.conditionIconImageView.image = UIImage(named: iconImageName)
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:00"
                cell.hourLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: item.dt))
                
                cell.conditionDescriptionLabel.text = item.weather.first?.description.capitalized
                
                cell.temperatureLabel.text = Int(item.main.temp).description + "º"
                
                cell.divider.isHidden = dataSource[indexPath.section].items.count - 1 == indexPath.row
                return cell
        })
    }
}

extension ForecastViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell // TODO: remove bang!
        let title = titleForHeaderInSection(section)
        cell.titleLabel.text = title
        return cell
    }
    
    private func titleForHeaderInSection(_ section: Int) -> String? {
        guard section != 0 else {
            return .today
        }
        guard let dateTimeInterval = dataSource[section].items.first?.dt else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date(timeIntervalSince1970: dateTimeInterval))
    }
}

fileprivate extension String {
    static let today = NSLocalizedString("Today", comment: "Header title of Forecast list.")
}
