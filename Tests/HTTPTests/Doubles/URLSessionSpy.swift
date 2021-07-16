import Foundation
@testable import HTTP

final class URLSessionSpy: URLSessionProtocol {
    var invokedDataTask = false
    var invokedDataTaskCount = 0
    var invokedDataTaskParameters: (request: URLRequest, Void)?
    var invokedDataTaskParametersList = [(request: URLRequest, Void)]()
    var stubbedDataTaskCompletionHandlerResult: (Data?, URLResponse?, Error?)?
    var stubbedDataTaskResult: URLSessionDataTaskProtocol!

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        invokedDataTask = true
        invokedDataTaskCount += 1
        invokedDataTaskParameters = (request, ())
        invokedDataTaskParametersList.append((request, ()))
        if let result = stubbedDataTaskCompletionHandlerResult {
            completionHandler(result.0, result.1, result.2)
        }
        return stubbedDataTaskResult
    }
}
