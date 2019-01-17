import Foundation
import RxSwift

protocol BaseViewModelProtocol {
    var fetchEndpoint: Endpoint? { get }
}

class BaseViewModel<ResultValueType: Codable> {
    enum ViewState {
        case loading
        case loaded
        case error
    }
    
    let observableResult = BehaviorSubject<Result<ResultValueType>?>(value: nil)
    
    var viewState: Observable<ViewState> {
        return observableResult.map { result in
            if case .success? = result {
                return .loaded
            } else if case .failure? = result {
                return .error
            } else {
                return .loading
            }
        }
    }
    
    var errorMessage: Observable<String?> {
        return observableResult.map { result in
            guard case .failure(let error)? = result else {
                return nil
            }
            return error.localizedDescription
        }
    }
    
    private let timer: DispatchSourceTimer
    
    init() {
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.setEventHandler(handler: fetchData)
        
        rescheduleTimer()
        timer.resume()
    }
    
    deinit {
        timer.cancel()
    }
    
    func rescheduleTimer() {
        let fetchPeriod = 60.0
        timer.schedule(deadline: DispatchTime.now(), repeating: fetchPeriod)
    }
    
    func fetchData() {
        if let viewModel = self as? BaseViewModelProtocol {
            if let endpoint = viewModel.fetchEndpoint {
                self.call(endpoint: endpoint).observe { [weak self] result in
                    self?.observableResult.onNext(result)
                    
                    if case .failure = result {
                        self?.fetchData()
                    }
                }
            } else {
                rescheduleTimer()
            }
        }
    }
    
    private func call(endpoint: Endpoint) -> Future<ResultValueType> {
        return URLSession.shared.request(endpoint).decoded()
    }
}
