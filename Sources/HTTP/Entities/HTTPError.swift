public struct HTTPError: Error, Equatable {
    public var code: Code
    public var response: HTTPResponse?
    
    public init(
        code: Code,
        response: HTTPResponse? = nil
    ) {
        self.code = code
        self.response = response
    }

    public enum Code: Hashable {
        case invalidRequest
        case invalidResponse
        case unknown
    }
}
