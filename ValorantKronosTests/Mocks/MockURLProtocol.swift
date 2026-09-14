//
//  MockURLProtocol.swift
//  ValorantKronosTests
//

import Foundation

/// Custom URLProtocol subclass for intercepting network requests in unit tests.
public final class MockURLProtocol: URLProtocol {
    
    // MARK: - Thread-Safe Storage
    
    private static let lock = NSLock()
    
    public static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    public static var mockResponseData: Data?
    public static var mockStatusCode: Int = 200
    public static var mockHeaders: [String: String] = ["Content-Type": "application/json"]
    public static var mockError: Error?
    public static var responseDelay: TimeInterval = 0.0
    
    public private(set) static var recordedRequests: [URLRequest] = []
    
    // MARK: - Reset Helper
    
    public static func reset() {
        lock.lock()
        defer { lock.unlock() }
        requestHandler = nil
        mockResponseData = nil
        mockStatusCode = 200
        mockHeaders = ["Content-Type": "application/json"]
        mockError = nil
        responseDelay = 0.0
        recordedRequests.removeAll()
    }
    
    // MARK: - Factory Methods
    
    /// Creates a URLSession with this mock protocol registered.
    public static func makeMockSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
    
    // MARK: - URLProtocol Overrides
    
    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        MockURLProtocol.lock.lock()
        MockURLProtocol.recordedRequests.append(request)
        let handler = MockURLProtocol.requestHandler
        let error = MockURLProtocol.mockError
        let data = MockURLProtocol.mockResponseData
        let statusCode = MockURLProtocol.mockStatusCode
        let headers = MockURLProtocol.mockHeaders
        let delay = MockURLProtocol.responseDelay
        MockURLProtocol.lock.unlock()
        
        let execute = { [weak self] in
            guard let self = self else { return }
            
            if let handler = handler {
                do {
                    let (response, responseData) = try handler(self.request)
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    self.client?.urlProtocol(self, didLoad: responseData)
                    self.client?.urlProtocolDidFinishLoading(self)
                } catch {
                    self.client?.urlProtocol(self, didFailWithError: error)
                }
                return
            }
            
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }
            
            let url = self.request.url ?? URL(string: "https://mock.valorant.api")!
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: headers
            ) ?? HTTPURLResponse()
            
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            self.client?.urlProtocolDidFinishLoading(self)
        }
        
        if delay > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: execute)
        } else {
            execute()
        }
    }
    
    public override func stopLoading() {
        // No-op for mock protocol
    }
}
