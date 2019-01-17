import UIKit

extension UIFont {
    static func proximaNova(of weight: UIFont.Weight, withSize size: CGFloat) -> UIFont {
        let fontName = "ProximaNova-" + weight.name
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}

extension UIFont.Weight {
    var name: String {
        switch self {
        case .bold:
            return "Bold"
        case .light:
            return "Light"
        case .semibold:
            return "Semibold"
        case .heavy:
            return "Extrabold"
        default:
            return "Regular"
        }
    }
}
