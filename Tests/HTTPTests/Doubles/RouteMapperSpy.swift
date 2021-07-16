import Foundation
@testable import HTTP

final class RouteMapperSpy: RouteMapperProtocol {
    var invokedMap = false
    var invokedMapCount = 0
    var invokedMapParameters: (route: HTTPRoute, Void)?
    var invokedMapParametersList = [(route: HTTPRoute, Void)]()
    var stubbedMapError: Error?
    var stubbedMapResult: URLRequest!

    func map(_ route: HTTPRoute) throws -> URLRequest {
        invokedMap = true
        invokedMapCount += 1
        invokedMapParameters = (route, ())
        invokedMapParametersList.append((route, ()))
        if let error = stubbedMapError {
            throw error
        }
        return stubbedMapResult
    }
}
