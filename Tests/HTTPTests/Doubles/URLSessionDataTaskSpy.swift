import Foundation
@testable import HTTP

final class URLSessionDataTaskSpy: URLSessionDataTaskProtocol {
    var invokedResume = false
    var invokedResumeCount = 0

    func resume() {
        invokedResume = true
        invokedResumeCount += 1
    }
}
