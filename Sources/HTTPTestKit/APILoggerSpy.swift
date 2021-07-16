import Foundation
@testable import HTTP

public final class HTTPLoggerSpy: HTTPLoggerProtocol {
    public var invokedLogRequest = false
    public var invokedLogRequestCount = 0
    public var invokedLogRequestParameters: (request: URLRequest, Void)?
    public var invokedLogRequestParametersList = [(request: URLRequest, Void)]()

    public func logRequest(_ request: URLRequest) {
        invokedLogRequest = true
        invokedLogRequestCount += 1
        invokedLogRequestParameters = (request, ())
        invokedLogRequestParametersList.append((request, ()))
    }

    public var invokedLogResponse = false
    public var invokedLogResponseCount = 0
    public var invokedLogResponseParameters: (data: Data?, response: URLResponse?, error: Error?)?
    public var invokedLogResponseParametersList = [(data: Data?, response: URLResponse?, error: Error?)]()

    public func logResponse(data: Data?, response: URLResponse?, error: Error?) {
        invokedLogResponse = true
        invokedLogResponseCount += 1
        invokedLogResponseParameters = (data, response, error)
        invokedLogResponseParametersList.append((data, response, error))
    }
}
