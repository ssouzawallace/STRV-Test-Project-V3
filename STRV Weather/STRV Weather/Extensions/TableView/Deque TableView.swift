import UIKit

protocol ReusableView: class {
    static var reuseIdentifier: String {get}
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView {
}

extension UITableView {
    
    func dequeueReusableCell<CellType: UITableViewCell>(forIndexPath indexPath: IndexPath) -> CellType {
        guard let cell = dequeueReusableCell(withIdentifier: CellType.reuseIdentifier, for: indexPath) as? CellType else {
            fatalError("Could not dequeue cell with identifier: \(CellType.reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableCell<CellType: UITableViewCell>() -> CellType {
        guard let cell = dequeueReusableCell(withIdentifier: CellType.reuseIdentifier) as? CellType else {
            fatalError("Could not dequeue cell with identifier: \(CellType.reuseIdentifier)")
        }
        
        return cell
    }
}

