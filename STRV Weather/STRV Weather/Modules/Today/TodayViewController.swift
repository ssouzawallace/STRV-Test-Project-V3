import UIKit
import RxSwift
import RxCocoa

class TodayViewController: UIViewController {
    
    let viewModel = TodayViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    @IBOutlet weak var upperFeaturesStackView: UIStackView!
    @IBOutlet weak var bottomFeaturesStackView: UIStackView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTabBarItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.navigationTitle
        
        configureRx()
        
        let featureView = WeatherFeatureView()
        featureView.iconImageView.image = UIImage(named: "30x30 Precipitation (Other)")
        featureView.valueLabel.text = "teste"
        featureView.sizeToFit()
        featureView.layoutIfNeeded()
        upperFeaturesStackView.addArrangedSubview(featureView)
    }
    
    func configureRx() {
        viewModel.locationDescription.bind(to: currentLocationLabel.rx.text).disposed(by: disposeBag)
        viewModel.weatherDescription.map(weatherDescriptionAttributedString).bind(to: weatherDescriptionLabel.rx.attributedText).disposed(by: disposeBag)
        viewModel.weatherIconName.map { (imageName) -> UIImage? in
            guard let imageName = imageName else {
                return nil
            }
            return UIImage(named: imageName)
            }.bind(to: weatherIconImageView.rx.image).disposed(by: disposeBag)
        viewModel.errorMessage.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
        viewModel.viewState.map({ $0 != .error }).bind(to: errorLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.viewState.map({ $0 != .loading }).bind(to: activityIndicator.rx.isHidden).disposed(by: disposeBag)
        viewModel.viewState.map({ $0 != .loaded }).bind(to: containerView.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.weatherFeatures.subscribe(onNext: { features in
            DispatchQueue.main.async {
                self.cleanFeatures()
                self.addUpperFeatures(features.enumerated().prefix(while: { $0.offset < 3 }).map({ $0.element }))
                self.addBottomFeatures(Array(features.dropFirst(3)))
            }
        }).disposed(by: disposeBag)
    }
    
    private func weatherDescriptionAttributedString(_ items: (String?, String?)?) -> NSAttributedString? {
        guard let _ = items, let first = items?.0, let second = items?.1 else {
            return nil
        }
        
        let fontColor = UIColor.vividBlue
        let regularAttributes = [NSAttributedString.Key.font: UIFont.proximaNova(of: .regular, withSize: 24),
                                 NSAttributedString.Key.foregroundColor: fontColor]
        let heavyAttributes = [NSAttributedString.Key.font: UIFont.proximaNova(of: .heavy, withSize: 24),
                                 NSAttributedString.Key.foregroundColor: fontColor]
        let separator = " | "
        let string = first + separator + second
        let nsString = NSString(string: string)
        let attributedString = NSMutableAttributedString(string: string)

        attributedString.addAttributes(regularAttributes, range: nsString.range(of: first))
        attributedString.addAttributes(regularAttributes, range: nsString.range(of: second))
        
        attributedString.addAttributes(heavyAttributes, range: nsString.range(of: separator))
        
        return attributedString
    }
    
    func cleanFeatures() {
        upperFeaturesStackView.subviews.forEach( {$0.removeFromSuperview() })
        bottomFeaturesStackView.subviews.forEach( {$0.removeFromSuperview() })
    }
    
    func addUpperFeatures(_ features: [TodayViewModel.WeatherFeature]) {
        features.map( { return ($0, self.upperFeaturesStackView) }).forEach(add)
    }
    
    func addBottomFeatures(_ features: [TodayViewModel.WeatherFeature]) {
        features.map( { return ($0, self.bottomFeaturesStackView) }).forEach(add)
    }
    
    func add(weatherFeature feature: TodayViewModel.WeatherFeature, to stackView: UIStackView) {
        let featureView = WeatherFeatureView()
        featureView.iconImageView.image = UIImage(named: feature.iconName)
        featureView.valueLabel.text = feature.value
        stackView.addArrangedSubview(featureView)
    }
    
    func configureTabBarItem() {
        let tabBarItemImage = UIImage(named: "25x25 Today Inactive (Tab)")?.withRenderingMode(.alwaysOriginal)
        let tabBarItemSelectedImage = UIImage(named: "25x25 Today Active (Tab)")?.withRenderingMode(.alwaysOriginal)
        tabBarItem = UITabBarItem(title: viewModel.navigationTitle,
                                  image: tabBarItemImage,
                                  selectedImage: tabBarItemSelectedImage)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let activityViewControler = UIActivityViewController(activityItems: [viewModel.shareableText],
                                                             applicationActivities: nil)
        present(activityViewControler, animated: true)
    }
}

class WeatherFeatureView: UIView {
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.proximaNova(of: .semibold, withSize: 15)
        label.textColor = UIColor.veryDarkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconImageView)
        addSubview(valueLabel)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        let viewsDictionary = ["image": iconImageView,
                               "label": valueLabel]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[image]-1-[label]",
                                                      options: .directionLeadingToTrailing,
                                                      metrics: nil,
                                                      views: viewsDictionary))
        
        addConstraint(NSLayoutConstraint(item: iconImageView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: valueLabel,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0))
    }
}
