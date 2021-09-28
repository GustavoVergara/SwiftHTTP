import XCTest
@testable import HTTPTestKit
@testable import HTTP

@available(iOS 15.0.0, macOS 12.0.0, tvOS 15.0, watchOS 8.0, *)
final class HTTPClientAsyncTests: XCTestCase {
    
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
        urlSessionSpy.stubbedDataResult = (Data(), URLResponse())
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
    
    func test_request_fowardsRouteToMapper() async {
        let expectedRoute = HTTPRouteStub(path: "/search")
        
        _ = try? await sut.request(expectedRoute)
        
        let receivedRoute = routeMapperSpy.invokedMapParameters?.route
        XCTAssertEqual(receivedRoute as? HTTPRouteStub, expectedRoute)
    }
    
    func test_request_completesWithAnError_whenRouteMapperThrows() async {
        let expectedError = HTTPError(code: .invalidRequest, response: nil)
        var receivedError: Error?
        
        routeMapperSpy.stubbedMapError = RouteMapperError.invalidURL
        
        do {
            _ = try await sut.request(HTTPRouteStub())
        } catch {
            receivedError = error
        }
        
        XCTAssertEqual(receivedError as? HTTPError, expectedError)
    }
    
    func test_request_fowardsRequestToURLSession() async {
        _ = try? await sut.request(HTTPRouteStub())

        XCTAssertEqual(urlSessionSpy.invokedDataParameters?.request, Stub.urlRequest)
    }
    
    func test_request_completesWithAnInvalidResponse_whenURLSessionDoesNotReturnAHTTPURLResponse() async {
        let expectedError = HTTPError(code: .invalidResponse, response: nil)
        var receivedError: Error?
        
        urlSessionSpy.stubbedDataResult = (Stub.data, URLResponse())
        
        do {
            _ = try await sut.request(HTTPRouteStub())
        } catch {
            receivedError = error
        }
        
        XCTAssertEqual(receivedError as? HTTPError, expectedError)
    }

    func test_request_completesWithUnknownError_whenURLSessionThrows() async {
        let expectedError = HTTPError(code: .unknown, response: nil)
        var receivedError: Error?
        
        urlSessionSpy.stubbedDataError = ErrorStub()
        
        do {
            _ = try await sut.request(HTTPRouteStub())
        } catch {
            receivedError = error
        }
        
        XCTAssertEqual(receivedError as? HTTPError, expectedError)
    }
    
    func test_request_completesWithSuccess_whenURLSessionReturnsDataAndAHTTPResponse() async throws {
        let expectedResponse = Stub.httpResponse
        var receivedResponse: HTTPResponse?

        urlSessionSpy.stubbedDataResult = (Stub.data, Stub.httpURLResponse)

        receivedResponse = try await sut.request(HTTPRouteStub())
        
        XCTAssertEqual(receivedResponse, expectedResponse)
    }
    
    func test_request_logsRequest() async {
        _ = try? await sut.request(HTTPRouteStub())

        XCTAssertEqual(httpLoggerSpy.invokedLogRequestParameters?.request, Stub.urlRequest)
    }

    func test_request_logsResponse() async {
        urlSessionSpy.stubbedDataResult = (Stub.data, Stub.httpURLResponse)

        _ = try? await sut.request(HTTPRouteStub())

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
