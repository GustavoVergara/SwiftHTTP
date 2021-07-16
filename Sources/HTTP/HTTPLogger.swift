import Foundation

public protocol HTTPLoggerProtocol {
    func logRequest(_ request: URLRequest)
    func logResponse(data: Data?, response: URLResponse?, error: Error?)
}

public class HTTPLogger: HTTPLoggerProtocol {
    var level: HTTPLoggerLevel
    var shouldTryToPrettyPrintJSON: Bool
    
    public init(level: HTTPLoggerLevel, shouldTryToPrettyPrintJSON: Bool = true) {
        self.level = level
        self.shouldTryToPrettyPrintJSON = shouldTryToPrettyPrintJSON
    }
    
    public func logRequest(_ request: URLRequest) {
        guard level.logsRequest else { return }
        var logString = "\n📤 Request: "

        if let method = request.httpMethod {
            logString += " \(method)"
        }

        if let url = request.url?.absoluteString {
            logString += " \(url)"
        }

        logString += "\n"

        if let headers = request.allHTTPHeaderFields, headers.isEmpty == false {
            logString += logHeaders(headers) + "\n"
        }

        if let body = request.httpBody, body.isEmpty == false, level.logsRequestBody {
            logString += logBody(body) + "\n"
        }
        
        print(logString)
    }
    
    public func logResponse(data: Data?, response: URLResponse?, error: Error?) {
        guard level.logsResponse else { return }
        var logString = "\n📥 Response: "
        if let url = response?.url?.absoluteString {
            logString += " \(url)"
        }
        logString += "\n"
        
        if let httpResponse = response as? HTTPURLResponse {
            let localisedStatus = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode).capitalized
            logString += "Status:  \(httpResponse.statusCode) - \(localisedStatus)\n"
            
            if let headers = httpResponse.allHeaderFields as? [String: String], headers.isEmpty == false {
                logString += self.logHeaders(headers) + "\n"
            }
        }
        
        if let body = data, body.isEmpty == false, level.logsResponseBody {
            logString += logBody(body) + "\n"
        }
        
        print(logString)
    }
    
    private func logHeaders(_ headers: [String : String]) -> String {
        let string = headers.reduce(String()) { str, header in
            let string = "  \(header.key) : \(header.value)"
            return str + "\n" + string
        }
        let logString = "Header:\n[\(string)\n]"
        return logString
    }
    
    private func logBody(_ data: Data) -> String {
        var data = data
        if shouldTryToPrettyPrintJSON, let json = try? prettyJSON(data) {
            data = json
        }
        guard let bodyString = String(data: data, encoding: .utf8) else {
            return ""
        }
        return """
        Body:
        \(bodyString)
        """
    }
    
    private func prettyJSON(_ data: Data) throws -> Data {
        let json = try JSONSerialization.jsonObject(with: data)
        return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    }
}

public enum HTTPLoggerLevel {
    case none
    case outgoingMetadata
    case outgoing
    case metadata
    case verbose
    
    var logsRequest: Bool {
        switch self {
        case .none: return false
        case .outgoing, .outgoingMetadata, .metadata, .verbose: return true
        }
    }
    
    var logsResponse: Bool {
        switch self {
        case .none, .outgoing, .outgoingMetadata: return false
        case .metadata, .verbose: return true
        }
    }
    
    var logsRequestBody: Bool {
        switch self {
        case .none, .outgoingMetadata, .metadata: return false
        case .outgoing, .verbose: return true
        }
    }
    
    var logsResponseBody: Bool {
        switch self {
        case .none, .outgoingMetadata, .outgoing, .metadata: return false
        case .verbose: return true
        }
    }
}
