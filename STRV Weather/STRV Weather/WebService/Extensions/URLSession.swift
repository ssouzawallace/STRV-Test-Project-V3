import Foundation

typealias Networking = (Endpoint) -> Future<Data>

extension URLSession {
    func request(_ endpoint: Endpoint) -> Future<Data> {
        let promise = Promise<Data>()
        
        guard let url = endpoint.url else {
            promise.reject(with: Endpoint.Error.invalidURL)
            return promise
        }
        let task = dataTask(with: url) { data, response, error in
            if let error = error {
                promise.reject(with: error)
                return
            }
            if let data = data {
                promise.resolve(with: data)
                return
            }
        }
        
        task.resume()
        
        return promise
    }
}
