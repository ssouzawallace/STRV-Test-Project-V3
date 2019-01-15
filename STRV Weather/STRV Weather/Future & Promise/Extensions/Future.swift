import Foundation

extension Future {
    func chained<NextValue>(with closure: @escaping (Value) throws -> Future<NextValue>) -> Future<NextValue> {
        // Start by constructing a "wrapper" promise that will be
        // returned from this method
        let promise = Promise<NextValue>()
        
        // Observe the current future
        observe { result in
            switch result {
            case .success(let value):
                do {
                    // Attempt to construct a new future given
                    // the value from the first one
                    let future = try closure(value)
                    
                    // Observe the "nested" future, and once it
                    // completes, resolve/reject the "wrapper" future
                    future.observe { result in
                        switch result {
                        case .success(let value):
                            promise.resolve(with: value)
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                    }
                } catch {
                    promise.reject(with: error)
                }
            case .failure(let error):
                promise.reject(with: error)
            }
        }
        
        return promise
    }
}

extension Future {
    func transformed<NextValue>(with closure: @escaping (Value) throws -> NextValue) -> Future<NextValue> {
        return chained { value in
            return try Promise(value: closure(value))
        }
    }
}

extension Future where Value == Data {
    
    fileprivate func decoded<T: Decodable>(as: T.Type, using decoder: JSONDecoder) -> Future<T> {
        return chained { value in
            return try Promise(value: decoder.decode(T.self, from: value))
        }
    }
    
    func decoded<T: Decodable>() -> Future<T> {
        return decoded(as: T.self, using: JSONDecoder())
    }
}
