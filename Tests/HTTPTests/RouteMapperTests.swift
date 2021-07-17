import XCTest
@testable import HTTPTestKit
@testable import HTTP

final class RouteMapperTests: XCTestCase {
    
    var httpRouteStub: HTTPRouteStub!
    var httpBodyStub: HTTPBodyStub!
    
    var sut: RouteMapperProtocol!
    
    override func setUp() {
        httpBodyStub = HTTPBodyStub()
        httpRouteStub = HTTPRouteStub(scheme: Stub.scheme, host: Stub.host, body: httpBodyStub)
        
        sut = createSUT()
    }
    
    func createSUT()
    -> RouteMapperProtocol {
        RouteMapper()
    }
    
    func test_map_setsURLToBaseURL_whenNoPathIsReceived() throws {
        let urlRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(urlRequest.url, URL(string: Stub.baseURL))
        
        httpRouteStub.host = Stub.alternateHost
        let alternateURLRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(alternateURLRequest.url, URL(string: Stub.alternateBaseURL))
    }
    
    func test_map_setsURLToBaseURLWithPath() throws {
        httpRouteStub.path = "/StubPath"
        let urlRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(urlRequest.url, URL(string: Stub.baseURL + "/StubPath"))
    }
    
    func test_map_setsQueryItems() throws {
        httpRouteStub.query = ["StubKey": "StubValue"]
        let urlRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(urlRequest.url, URL(string: Stub.baseURL + "?StubKey=StubValue"))
    }
    
    func test_map_doesNotSetQueryItems_whenTheValueIsEmpty() throws {
        httpRouteStub.query = ["q": ""]
        let urlRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(urlRequest.url, URL(string: Stub.baseURL))
    }
    
    func test_map_setsMethod() throws {
        httpRouteStub.method = .put
        let urlRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(urlRequest.httpMethod, HTTPMethod.put.rawValue)
        
        httpRouteStub.method = .delete
        let otherURLRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(otherURLRequest.httpMethod, HTTPMethod.delete.rawValue)
    }
    
    func test_map_setsHeaders() throws {
        let expectedHeaders = ["StubKey": "StubValue"]
        httpRouteStub.headers = expectedHeaders
        let urlRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, expectedHeaders)
    }
    
    func test_map_addsHeadersFromBody() throws {
        let expectedHeaders = ["Content-Type": "application/json; charset=utf-8"]
        httpBodyStub.additionalHeaders = expectedHeaders
        let urlRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, expectedHeaders)
    }
    
    func test_map_addsBothRouteAndBodyHeaders() throws {
        let routeStub = (key: "RouteStubKey", value: "RouteStubValue")
        let bodyStub = (key: "BodyStubKey", value: "BodyStubValue")
        httpRouteStub.headers = [routeStub.key: routeStub.value]
        httpBodyStub.additionalHeaders = [bodyStub.key: bodyStub.value]
        let urlRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, [routeStub.key: routeStub.value, bodyStub.key: bodyStub.value])
    }
    
    func test_map_addsBodyData() throws {
        let expectedData = Data([2, 0, 7, 7])
        httpBodyStub.stubbedDataResult = expectedData
        let urlRequest = try sut.map(httpRouteStub)
        XCTAssertEqual(urlRequest.httpBody, expectedData)
    }
    
    func test_map_throws_whenBodyDataThrows() {
        let expectedError = ErrorStub()
        httpBodyStub.stubbedDataError = expectedError
        
        XCTAssertThrowsError(try sut.map(httpRouteStub)) { receivedError in
            XCTAssertEqual(receivedError as? ErrorStub, expectedError)
        }
    }
    
    func test_map_throws_whenPathIsInvalid() {
        httpRouteStub.path = "💩"
        
        XCTAssertThrowsError(try sut.map(httpRouteStub)) { receivedError in
            XCTAssertEqual(receivedError as? RouteMapperError, RouteMapperError.invalidURL)
        }
    }
    
    enum Stub {
        static let scheme = "https"
        static let host = "www.google.com"
        static let alternateHost = "www.twitter.com"
        
        static let baseURL = "\(scheme)://\(host)"
        static let alternateBaseURL = "\(scheme)://\(alternateHost)"
    }
}
