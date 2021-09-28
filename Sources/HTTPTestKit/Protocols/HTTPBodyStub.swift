import Foundation
import HTTP

public final class HTTPBodyStub: HTTPBody {
    public init(
        additionalHeaders: [String: String] = [:],
        data: Data = Data()) {
        self.additionalHeaders = additionalHeaders
        self.stubbedDataResult = data
    }
    
    public var additionalHeaders: [String: String]

    public var invokedData = false
    public var invokedDataCount = 0
    public var stubbedDataError: Error?
    public var stubbedDataResult: Data

    public func data() throws -> Data {
        invokedData = true
        invokedDataCount += 1
        if let error = stubbedDataError {
            throw error
        }
        return stubbedDataResult
    }
}
