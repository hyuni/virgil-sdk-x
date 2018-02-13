//
//  HttpConnection.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

open class HttpConnection: HttpConnectionProtocol {
    private let queue: OperationQueue
    private let session: URLSession

    @objc(VSSServiceConnectionError) public enum ServiceConnectionError: Int, Error {
        case noUrlInRequest = 1
        case wrongResponseType = 2
    }

    public init() {
        self.queue = OperationQueue()
        self.queue.maxConcurrentOperationCount = 10

        let config = URLSessionConfiguration.ephemeral
        self.session = URLSession(configuration: config, delegate: nil, delegateQueue: self.queue)
    }

    public func send(_ request: Request) throws -> Response {
        let nativeRequest = request.getNativeRequest()

        guard let url = nativeRequest.url else {
            throw ServiceConnectionError.noUrlInRequest
        }

        let className = String(describing: type(of: self))

        Log.debug("\(className): request method: \(nativeRequest.httpMethod ?? "")")
        Log.debug("\(className): request url: \(url.absoluteString)")
        if let data = nativeRequest.httpBody, !data.isEmpty, let str = String(data: data, encoding: .utf8) {
            Log.debug("\(className): request body: \(str)")
        }
        Log.debug("\(className): request headers: \(nativeRequest.allHTTPHeaderFields ?? [:])")
        if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            for cookie in cookies {
                Log.debug("*******COOKIE: \(cookie.name): \(cookie.value)")
            }
        }

        let semaphore = DispatchSemaphore(value: 0)

        var dataT: Data?
        var responseT: URLResponse?
        var errorT: Error?
        let task = self.session.dataTask(with: nativeRequest) { dataR, responseR, errorR in
            dataT = dataR
            responseT = responseR
            errorT = errorR

            semaphore.signal()
        }
        task.resume()

        semaphore.wait()

        if let error = errorT {
            throw error
        }

        guard let response = responseT as? HTTPURLResponse else {
            throw ServiceConnectionError.wrongResponseType
        }

        Log.debug("\(className): response URL: \(response.url?.absoluteString ?? "")")
        Log.debug("\(className): response HTTP status code: \(response.statusCode)")
        Log.debug("\(className): response headers: \(response.allHeaderFields as AnyObject)")

        if let data = dataT, !data.isEmpty, let str = String(data: data, encoding: .utf8) {
            Log.debug("\(className): response body: \(str)")
        }

        return Response(statusCode: response.statusCode, response: response, body: dataT)
    }

    deinit {
        self.session.invalidateAndCancel()
        self.queue.cancelAllOperations()
    }
}