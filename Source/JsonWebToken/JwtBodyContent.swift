//
//  JwtBodyContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSJwtBodyContent) public class JwtBodyContent: NSObject, Codable {

    @objc public let appId: String
    @objc public let identity: String
    @objc public let expiresAt: Int
    @objc public let issuedAt: Int
    @objc public let additionalData: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case appId = "iss"
        case identity = "sub"
        case issuedAt = "iat"
        case expiresAt = "exp"
        case additionalData = "ada"
    }

    @objc public init(appId: String, identity: String, expiresAt: Date,
                      issuedAt: Date, additionalData: [String: String]? = nil) {
        self.appId = appId
        self.identity = identity
        self.expiresAt = Int(expiresAt.timeIntervalSince1970)
        self.issuedAt = Int(issuedAt.timeIntervalSince1970)
        self.additionalData = additionalData

        super.init()
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let issuer = try values.decode(String.self, forKey: .appId)
        let subject = try values.decode(String.self, forKey: .identity)

        self.appId = issuer.replacingOccurrences(of: "virgil-", with: "")
        self.identity = subject.replacingOccurrences(of: "identity-", with: "")
        self.additionalData = try? values.decode(Dictionary.self, forKey: .additionalData)
        self.issuedAt = try values.decode(Int.self, forKey: .issuedAt)
        self.expiresAt = try values.decode(Int.self, forKey: .expiresAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode("virgil-" + self.appId, forKey: .appId)
        try container.encode("identity-" + self.identity, forKey: .identity)
        try container.encode(self.issuedAt, forKey: .issuedAt)
        try container.encode(self.expiresAt, forKey: .expiresAt)
        if let additionalData = self.additionalData {
            try container.encode(additionalData, forKey: .additionalData)
        }
    }

    @objc public static func importFrom(base64UrlEncoded: String) -> JwtBodyContent? {
        guard let data = Data(base64UrlEncoded: base64UrlEncoded) else {
            return nil
        }

        return try? JSONDecoder().decode(JwtBodyContent.self, from: data)
    }

    @objc public func base64UrlEncodedString() throws -> String {
        return try JSONEncoder().encode(self).base64UrlEncodedString()
    }
}
