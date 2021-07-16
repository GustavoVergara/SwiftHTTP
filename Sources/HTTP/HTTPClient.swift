import Foundation

public typealias HTTPResult = Result<HTTPResponse, HTTPError>

public protocol HTTPClientProtocol {
    func request(_ route: HTTPRoute, returnQueue: DispatchQueue?, completion: @escaping (HTTPResult) -> Void)
}

public extension HTTPClientProtocol {
    func request(_ route: HTTPRoute, completion: @escaping (HTTPResult) -> Void) {
        request(route, returnQueue: nil, completion: completion)
    }
}

public struct HTTPClient: HTTPClientProtocol {
    let urlSession: URLSessionProtocol
    let routeMapper: RouteMapperProtocol
    let logger: HTTPLoggerProtocol
    
    init(
        urlSession: URLSessionProtocol = URLSession.shared,
        routeMapper: RouteMapperProtocol,
        logger: HTTPLoggerProtocol
    ) {
        self.urlSession = urlSession
        self.routeMapper = routeMapper
        self.logger = logger
    }
    
    public init(
        logger: HTTPLoggerProtocol = HTTPLogger(level: .none)
    ) {
        self = HTTPClient(routeMapper: RouteMapper(),
                         logger: logger)
    }
    
    public func request(_ route: HTTPRoute, returnQueue: DispatchQueue?, completion: @escaping (HTTPResult) -> Void) {
        guard let request = try? routeMapper.map(route) else {
            returnQueue.execute(
                completion,
                with: .failure(HTTPError(code: .invalidRequest, response: nil))
            )
            return
        }
        logger.logRequest(request)
        let dataTask = urlSession.dataTask(with: request) { [self] (data, urlResponse, error) in
            logger.logResponse(data: data, response: urlResponse, error: error)
            let result = self.result(data: data, response: urlResponse, error: error)
            returnQueue.execute(completion, with: result)
        }
        dataTask.resume()
    }
    
    private func result(data: Data?, response: URLResponse?, error: Error?) -> HTTPResult {
        guard let data = data, let response = response as? HTTPURLResponse else {
            return .failure(HTTPError(code: .invalidResponse, response: nil))
        }
        
        let apiResponse = HTTPResponse(response: response, body: data)
        guard error == nil else {
            return .failure(HTTPError(code: .unknown, response: apiResponse))
        }
        
        return .success(apiResponse)
    }
    
    private func call<T>(_ closure: @escaping (T) -> Void, with value: T, on queue: DispatchQueue? = nil) {
        if let queue = queue {
            queue.async { closure(value) }
        } else {
            closure(value)
        }
    }
    
}

extension Optional where Wrapped == DispatchQueue {
    
    fileprivate func execute<T>(_ closure: @escaping (T) -> Void, with value: T) {
        if let queue = self {
            queue.async { closure(value) }
        } else {
            closure(value)
        }
    }
    
}
