//
//  VirgilCardVerifier.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/18/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Virgil implementation of CardVerifier protocol
/// By default verifies Card's self signature and Virgil Cards Service signature
@objc(VSSVirgilCardVerifier) public final class VirgilCardVerifier: NSObject, CardVerifier {
    /// Signer identifier for self signatures
    @objc public static let selfSignerIdentifier = "self"
    /// Signer identifier for Virgil Cards Service signatures
    @objc public static let virgilSignerIdentifier = "virgil"
    /// Base64 encoded string with Virgil Service's Public Key for verifying Virgil Cards Service signatures
    /// - Note: Can be found [here](https://dashboard.virgilsecurity.com)
    @objc public static let virgilPublicKeyBase64 = "MCowBQYDK2VwAyEAr0rjTWlCLJ8q9em0og33grHEh/3vmqp0IewosUaVnQg="

    /// CardCrypto instance
    @objc public let cardCrypto: CardCrypto
    /// Imported Virgil Service's Public Key for verifying Virgil Cards Service signatures
    @objc public let virgilPublicKey: PublicKey
    /// VirgilCardVerifier will verify self signature if true
    @objc public var verifySelfSignature: Bool = true
    /// VirgilCardVerifier will verify Virgil Cards Service signatures if true
    @objc public var verifyVirgilSignature: Bool = true
    /// Array with collections of verifiers
    /// - Important: VirgilCardVerifier verifies Card if it contains signature from AT LEAST
    ///   one verifier from EACH Whitelist
    @objc public var whitelists: [Whitelist]

    /// Initializer
    ///
    /// - Parameters:
    ///   - cardCrypto: CardCrypto instance
    ///   - whitelists:  collections of verifiers
    /// - Important: VirgilCardVerifier verifies Card if it contains signature from AT LEAST
    ///   one verifier from EACH Whitelist
    @objc public init?(cardCrypto: CardCrypto, whitelists: [Whitelist] = []) {
        self.whitelists = whitelists
        self.cardCrypto = cardCrypto

        guard let publicKeyData = Data(base64Encoded: VirgilCardVerifier.virgilPublicKeyBase64),
              let publicKey = try? cardCrypto.importPublicKey(from: publicKeyData) else {
                return nil
        }

        self.virgilPublicKey = publicKey

        super.init()
    }

    /// Verifies Card instance using set rules
    ///
    /// - Parameter card: Card to verify
    /// - Returns: true if Card verified, false otherwise
    /// - Important: VirgilCardVerifier verifies Card if it contains signature from AT LEAST
    ///   one verifier from EACH Whitelist
    @objc public func verifyCard(_ card: Card) -> Bool {
        return verifySelfSignature(card) && verifyVirgilSignature(card) && verifyWhitelistsSignatures(card)
    }

    private func verifySelfSignature(_ card: Card) -> Bool {
        if self.verifySelfSignature {
            return VirgilCardVerifier.verify(cardCrypto: cardCrypto, card: card,
                                             signer: VirgilCardVerifier.selfSignerIdentifier,
                                             signerPublicKey: card.publicKey)
        }

        return true
    }

    private func verifyVirgilSignature(_ card: Card) -> Bool {
        if self.verifyVirgilSignature {
            return VirgilCardVerifier.verify(cardCrypto: self.cardCrypto, card: card,
                                             signer: VirgilCardVerifier.virgilSignerIdentifier,
                                             signerPublicKey: self.virgilPublicKey)
        }

        return true
    }

    private func verifyWhitelistsSignatures(_ card: Card) -> Bool {
        for whitelist in self.whitelists {
            guard let signerInfo = whitelist.verifiersCredentials.first(where: {
                    Set<String>(card.signatures.map({ $0.signer })).contains($0.signer)
                  }),
                  let publicKey = try? self.cardCrypto.importPublicKey(from: signerInfo.publicKey),
                  VirgilCardVerifier.verify(cardCrypto: self.cardCrypto, card: card, signer: signerInfo.signer,
                                            signerPublicKey: publicKey) else {
               return false
            }
        }

        return true
    }

    private class func verify(cardCrypto: CardCrypto, card: Card, signer: String, signerPublicKey: PublicKey) -> Bool {
        guard let signature = card.signatures.first(where: { $0.signer == signer }),
              let cardSnapshot = try? card.getRawCard().contentSnapshot,
              cardCrypto.verifySignature(signature.signature, of: cardSnapshot + (signature.snapshot ?? Data()),
                                         with: signerPublicKey) else {
                return false
        }

        return true
    }
}
