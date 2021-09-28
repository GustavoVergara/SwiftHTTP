import XCTest
@testable import HTTPTestKit
@testable import HTTP

final class HTTPClientTests: XCTestCase {
    
    var routeMapperSpy: RouteMapperSpy!
    var urlSessionSpy: URLSessionSpy!
    var dataTaskSpy: URLSessionDataTaskSpy!
    var httpLoggerSpy: HTTPLoggerSpy!

    var sut: HTTPClientProtocol!
    
    override func setUp() {
        routeMapperSpy = RouteMapperSpy()
        routeMapperSpy.stubbedMapResult = Stub.urlRequest
        urlSessionSpy = URLSessionSpy()
        dataTaskSpy = URLSessionDataTaskSpy()
        urlSessionSpy.stubbedDataTaskResult = dataTaskSpy
        httpLoggerSpy = HTTPLoggerSpy()

        sut = createSUT()
    }
    
    func createSUT() -> HTTPClientProtocol {
        HTTPClient(
            urlSession: urlSessionSpy,
            routeMapper: routeMapperSpy,
            logger: httpLoggerSpy
        )
    }
    
    func test_request_fowardsRouteToMapper() {
        let expectedRoute = HTTPRouteStub(path: "/search")
        
        sut.request(expectedRoute, completion: { _ in })
        
        let receivedRoute = routeMapperSpy.invokedMapParameters?.route
        XCTAssertEqual(receivedRoute as? HTTPRouteStub, expectedRoute)
    }
    
    func test_request_completesWithAnError_whenRouteMapperThrows() {
        let expectedResult = HTTPResult.failure(HTTPError(code: .invalidRequest, response: nil))
        var receivedResult: HTTPResult?
        
        routeMapperSpy.stubbedMapError = RouteMapperError.invalidURL
        
        sut.request(HTTPRouteStub()) { result in
            receivedResult = result
        }
        
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func test_request_fowardsRequestToURLSession() {
        sut.request(HTTPRouteStub(), completion: { _ in })

        XCTAssertEqual(urlSessionSpy.invokedDataTaskParameters?.request, Stub.urlRequest)
    }
    
    func test_request_resumesDataTask() {
        sut.request(HTTPRouteStub(), completion: { _ in })

        XCTAssertTrue(dataTaskSpy.invokedResume)
    }
    
    func test_request_completesWithAnInvalidResponse_whenURLSessionReturnsEmpty() {
        let expectedResult = HTTPResult.failure(HTTPError(code: .invalidResponse, response: nil))
        var receivedResult: HTTPResult?
        
        urlSessionSpy.stubbedDataTaskCompletionHandlerResult = (nil, nil, nil)
        
        sut.request(HTTPRouteStub()) { result in
            receivedResult = result
        }
        
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func test_request_completesWithAnInvalidResponse_whenURLSessionReturnsOnlyAnError() {
        let expectedResult = HTTPResult.failure(HTTPError(code: .invalidResponse, response: nil))
        var receivedResult: HTTPResult?
        
        urlSessionSpy.stubbedDataTaskCompletionHandlerResult = (nil, nil, ErrorStub())
        
        sut.request(HTTPRouteStub()) { result in
            receivedResult = result
        }
        
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func test_request_completesWithUnknownError_whenURLSessionReturnsAnErrorWithDataAndResponse() {
        let expectedResult = HTTPResult.failure(HTTPError(code: .unknown, response: Stub.httpResponse))
        var receivedResult: HTTPResult?
        
        urlSessionSpy.stubbedDataTaskCompletionHandlerResult = (Stub.data, Stub.httpURLResponse, ErrorStub())
        
        sut.request(HTTPRouteStub()) { result in
            receivedResult = result
        }
        
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func test_request_completesWithSuccess_whenURLSessionReturnsDataAndAHTTPResponse() {
        let expectedResult = HTTPResult.success(Stub.httpResponse)
        var receivedResult: HTTPResult?
        
        urlSessionSpy.stubbedDataTaskCompletionHandlerResult = (Stub.data, Stub.httpURLResponse, nil)
        
        sut.request(HTTPRouteStub()) { result in
            receivedResult = result
        }
        
        XCTAssertEqual(receivedResult, expectedResult)
    }
    
    func test_request_respondsOnSpecifiedQueue() {
        let expectedReturnQueue = DispatchQueue(label: #function, qos: .userInitiated, attributes: .concurrent)
        let expectedDispatchKey = DispatchSpecificKey<Void>()
        expectedReturnQueue.setSpecific(key: expectedDispatchKey, value: ())
        
        var receivedOnExpectedQueue: Bool?
        
        urlSessionSpy.stubbedDataTaskCompletionHandlerResult = (Stub.data, Stub.httpURLResponse, nil)
        
        let expectation = self.expectation(description: "request callback")
        sut.request(HTTPRouteStub(), returnQueue: expectedReturnQueue) { _ in
            receivedOnExpectedQueue = DispatchQueue.getSpecific(key: expectedDispatchKey) != nil
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertNotNil(receivedOnExpectedQueue)
        XCTAssert(receivedOnExpectedQueue == true)
    }
    
    func test_request_logsRequest() {
        sut.request(HTTPRouteStub(), completion: { _ in })
        
        XCTAssertEqual(httpLoggerSpy.invokedLogRequestParameters?.request, Stub.urlRequest)
    }
    
    func test_request_logsResponse() {
        urlSessionSpy.stubbedDataTaskCompletionHandlerResult = (Stub.data, Stub.httpURLResponse, nil)
        
        sut.request(HTTPRouteStub()) { _ in }
        
        let logResponseParameters = httpLoggerSpy.invokedLogResponseParameters
        XCTAssertEqual(logResponseParameters?.data, Stub.data)
        XCTAssertEqual(logResponseParameters?.response, Stub.httpURLResponse)
    }
    
    enum Stub {
        static let url = URL(string: "www.google.com.br")!
        static let urlRequest = URLRequest(url: url)
        static let httpURLResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        static let data = Data([1, 5, 9, 4, 2, 3, 1])
        static let httpResponse = HTTPResponse(response: httpURLResponse, body: data)
    }
}
