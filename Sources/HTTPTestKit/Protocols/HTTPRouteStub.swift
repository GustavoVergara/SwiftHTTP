import Foundation
import HTTP

public final class HTTPRouteStub: HTTPRoute, Equatable {
    public let id = UUID()
    public var scheme: String = ""
    public var host: String = ""
    public var path: String = ""
    public var method: HTTPMethod = .get
    public var headers: [String: String] = [:]
    public var query: [String: String] = [:]
    public var body: HTTPBody?

    public init(
        scheme: String = "",
        host: String = "",
        path: String = "",
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        query: [String: String] = [:],
        body: HTTPBody? = nil
    ) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.method = method
        self.headers = headers
        self.query = query
        self.body = body
    }
    
    public static func == (lhs: HTTPRouteStub, rhs: HTTPRouteStub) -> Bool {
        lhs.id == rhs.id
    }

}
