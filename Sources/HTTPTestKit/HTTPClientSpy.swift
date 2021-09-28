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
    
    public var invokedAsyncRequest = false
    public var invokedAsyncRequestCount = 0
    public var invokedAsyncRequestParameters: (route: HTTPRoute, Void)?
    public var invokedAsyncRequestParametersList = [(route: HTTPRoute, Void)]()
    public var stubbedAsyncRequestError: Error?
    public var stubbedAsyncRequestResult: HTTPResponse!

    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    public func request(_ route: HTTPRoute) async throws -> HTTPResponse {
        invokedAsyncRequest = true
        invokedAsyncRequestCount += 1
        invokedAsyncRequestParameters = (route, ())
        invokedAsyncRequestParametersList.append((route, ()))
        if let error = stubbedAsyncRequestError {
            throw error
        }
        return stubbedAsyncRequestResult
    }
}
