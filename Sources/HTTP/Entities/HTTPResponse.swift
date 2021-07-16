import Foundation

public struct HTTPResponse: Equatable {
    public var response: HTTPURLResponse
    public var body: Data
    
    public init(
        response: HTTPURLResponse,
        body: Data
    ) {
        self.response = response
        self.body = body
    }
}
