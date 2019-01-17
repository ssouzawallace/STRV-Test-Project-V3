import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ForecastViewController: UIViewController {
    
    let viewModel = ForecastViewModel()
    let disposeBag = DisposeBag()
    
    let dataSource = ForecastViewController.dataSource()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTabBarItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.tabTitle
        
        configureRx()
    }
    
    func configureRx() {
        viewModel.viewState.map({ $0 != .loading }).bind(to: activityIndicator.rx.isHidden).disposed(by: disposeBag)
        viewModel.navigationTitle.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        viewModel.viewState.map({ $0 != .error }).bind(to: errorLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.errorMessage.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.predictions.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    func configureTabBarItem() {
        let tabBarItemImage = UIImage(named: "25x25 Forecast Inactive (Tab)")?.withRenderingMode(.alwaysOriginal)
        let tabBarItemSelectedImage = UIImage(named: "25x25 Forecast Active (Tab)")?.withRenderingMode(.alwaysOriginal)
        tabBarItem = UITabBarItem(title: viewModel.tabTitle,
                                  image: tabBarItemImage,
                                  selectedImage: tabBarItemSelectedImage)
    }
    
    private static func dataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<Int, WeatherResponse>> {
        
        return RxTableViewSectionedReloadDataSource<SectionModel<Int, WeatherResponse>>(
            configureCell: { (dataSource, table, indexPath, item) in
                let cell: WeatherCell = table.dequeueReusableCell(forIndexPath: indexPath)
                
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
        let cell: HeaderCell = tableView.dequeueReusableCell()
        let title = titleForHeaderInSection(section)
        cell.titleLabel.text = title
        return cell
    }
    
    private func titleForHeaderInSection(_ section: Int) -> String? {
        guard let dateTimeInterval = dataSource[section].items.first?.dt else {
            return nil
        }
        var title: String? = .today
        if section != 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            title = dateFormatter.string(from: Date(timeIntervalSince1970: dateTimeInterval))
        }
        return title?.uppercased()
    }
}

fileprivate extension String {
    static let today = NSLocalizedString("Today", comment: "Header title of Forecast list.")
}
