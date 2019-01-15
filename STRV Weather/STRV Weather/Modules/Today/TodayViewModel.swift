import Foundation
import RxSwift

class TodayViewModel {
    var navigationTitle: Variable<String> = Variable(.today)
}

fileprivate extension String {
    static let today = NSLocalizedString("Today", comment: "Title of the Today section.")
}

