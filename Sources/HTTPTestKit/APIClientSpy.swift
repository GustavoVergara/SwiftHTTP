import Foundation
import HTTP

public final class HTTPClientSpy: HTTPClientProtocol {
    public init() {}
    
    public var invokedRequest = false
    public var invokedRequestCount = 0
    public var invokedRequestParameters: (route: HTTPRoute, returnQueue: DispatchQueue?)?
    public var invokedRequestParametersList = [(route: HTTPRoute, returnQueue: DispatchQueue?)]()
    public var stubbedRequestCompletionResult: HTTPResult?

    public func request(_ route: HTTPRoute, returnQueue: DispatchQueue?, completion: @escaping (HTTPResult) -> Void) {
        invokedRequest = true
        invokedRequestCount += 1
        invokedRequestParameters = (route, returnQueue)
        invokedRequestParametersList.append((route, returnQueue))
        if let result = stubbedRequestCompletionResult {
            completion(result)
        }
    }
}
