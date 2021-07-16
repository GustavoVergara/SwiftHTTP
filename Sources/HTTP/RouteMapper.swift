import Foundation

protocol RouteMapperProtocol {
    func map(_ route: HTTPRoute) throws -> URLRequest
}

struct RouteMapper: RouteMapperProtocol {
    func map(_ route: HTTPRoute) throws -> URLRequest {
        let routeUrl = try url(route: route)
        let routeRequest = try request(route: route, url: routeUrl)
        return routeRequest
    }
    
    private func url(route: HTTPRoute) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.host = route.host
        urlComponents.scheme = route.scheme
        urlComponents.path = route.path
        let query = route.query.filter { $0.value.isEmpty == false }
        if query.isEmpty == false {
            urlComponents.queryItems = query.map { URLQueryItem(name: $0, value: $1) }
        }
        
        guard let url = urlComponents.url else {
            throw RouteMapperError.invalidURL
        }
        return url
    }
    
    private func request(route: HTTPRoute, url: URL) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = route.method.rawValue
        route.headers.forEach {
            urlRequest.setValue($1, forHTTPHeaderField: $0)
        }
        
        if let body = route.body {
            body.additionalHeaders.forEach {
                urlRequest.setValue($1, forHTTPHeaderField: $0)
            }
            urlRequest.httpBody = try body.data()
        }
        
        return urlRequest
    }
}

enum RouteMapperError: Error {
    case invalidURL
}
