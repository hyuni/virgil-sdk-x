//
//  VSSTestsUtils.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCard.h"
#import "VSSRevokeCard.h"
#import "VSSCrypto.h"

extern NSString *__nonnull const kApplicationToken;
extern NSString *__nonnull const kApplicationPublicKeyBase64;
extern NSString *__nonnull const kApplicationPrivateKeyBase64;
extern NSString *__nonnull const kApplicationPrivateKeyPassword;
extern NSString *__nonnull const kApplicationIdentityType;
extern NSString *__nonnull const kApplicationId;

@interface VSSTestsUtils : NSObject

@property (nonatomic, readonly) VSSCrypto * __nonnull crypto;

- (VSSCard * __nonnull)instantiateCard;
- (VSSRevokeCard * __nonnull)instantiateRevokeCardForCard:(VSSCard * __nonnull)card;
- (BOOL)checkCard:(VSSCard * __nonnull)card1 isEqualToCard:(VSSCard * __nonnull)card2;
- (BOOL)checkRevokeCard:(VSSRevokeCard * __nonnull)revokeCard1 isEqualToRevokeCard:(VSSRevokeCard * __nonnull)revokeCard2;

- (instancetype __nonnull)init NS_UNAVAILABLE;

- (instancetype __nonnull)initWithCrypto:(VSSCrypto * __nonnull)crypto;

@end
