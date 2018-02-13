//
//  CardVerifier.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/18/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCardVefifier) public protocol CardVerifier {
    @objc func verifyCard(card: Card) -> Bool
}