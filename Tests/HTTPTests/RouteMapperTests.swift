import XCTest
@testable import HTTPTestKit
@testable import HTTP

final class RouteMapperTests: XCTestCase {
    
    var apiRouteStub: HTTPRouteStub!
    var apiBodyStub: HTTPBodyStub!
    
    var sut: RouteMapperProtocol!
    
    override func setUp() {
        apiBodyStub = HTTPBodyStub()
        apiRouteStub = HTTPRouteStub(scheme: Stub.scheme, host: Stub.host, body: apiBodyStub)
        
        sut = createSUT()
    }
    
    func createSUT()
    -> RouteMapperProtocol {
        RouteMapper()
    }
    
    func test_map_setsURLToBaseURL_whenNoPathIsReceived() throws {
        let urlRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(urlRequest.url, URL(string: Stub.baseURL))
        
        apiRouteStub.host = Stub.alternateHost
        let alternateURLRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(alternateURLRequest.url, URL(string: Stub.alternateBaseURL))
    }
    
    func test_map_setsURLToBaseURLWithPath() throws {
        apiRouteStub.path = "/StubPath"
        let urlRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(urlRequest.url, URL(string: Stub.baseURL + "/StubPath"))
    }
    
    func test_map_setsQueryItems() throws {
        apiRouteStub.query = ["StubKey": "StubValue"]
        let urlRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(urlRequest.url, URL(string: Stub.baseURL + "?StubKey=StubValue"))
    }
    
    func test_map_doesNotSetQueryItems_whenTheValueIsEmpty() throws {
        apiRouteStub.query = ["q": ""]
        let urlRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(urlRequest.url, URL(string: Stub.baseURL))
    }
    
    func test_map_setsMethod() throws {
        apiRouteStub.method = .put
        let urlRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(urlRequest.httpMethod, HTTPMethod.put.rawValue)
        
        apiRouteStub.method = .delete
        let otherURLRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(otherURLRequest.httpMethod, HTTPMethod.delete.rawValue)
    }
    
    func test_map_setsHeaders() throws {
        let expectedHeaders = ["StubKey": "StubValue"]
        apiRouteStub.headers = expectedHeaders
        let urlRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, expectedHeaders)
    }
    
    func test_map_addsHeadersFromBody() throws {
        let expectedHeaders = ["Content-Type": "application/json; charset=utf-8"]
        apiBodyStub.additionalHeaders = expectedHeaders
        let urlRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, expectedHeaders)
    }
    
    func test_map_addsBothRouteAndBodyHeaders() throws {
        apiRouteStub.headers = ["RouteStubKey": "RouteStubValue"]
        apiBodyStub.additionalHeaders = ["BodyStubKey": "BodyStubValue"]
        let urlRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["RouteStubKey": "RouteStubValue", "BodyStubKey": "BodyStubValue"])
    }
    
    func test_map_addsBodyData() throws {
        let expectedData = Data([2, 0, 7, 7])
        apiBodyStub.stubbedDataResult = expectedData
        let urlRequest = try sut.map(apiRouteStub)
        XCTAssertEqual(urlRequest.httpBody, expectedData)
    }
    
    func test_map_throws_whenBodyDataThrows() {
        let expectedError = ErrorStub()
        apiBodyStub.stubbedDataError = expectedError
        
        XCTAssertThrowsError(try sut.map(apiRouteStub)) { receivedError in
            XCTAssertEqual(receivedError as? ErrorStub, expectedError)
        }
    }
    
    func test_map_throws_whenPathIsInvalid() {
        apiRouteStub.path = "💩"
        
        XCTAssertThrowsError(try sut.map(apiRouteStub)) { receivedError in
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
