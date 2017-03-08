//
//  VSSVirgilApi.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSVirgilApi.h"
#import "VSSCardsManagerPrivate.h"
#import "VSSKeysManagerPrivate.h"
#import "VSSIdentitiesManagerPrivate.h"

NSString *const kVSSVirgilApiErrorDomain = @"VSSVirgilApiErrorDomain";

@implementation VSSVirgilApi

@synthesize Identities = _Identities;
@synthesize Cards = _Cards;
@synthesize Keys = _Keys;

- (instancetype)init {
    return [self initWithToken:nil];
}

- (instancetype)initWithContext:(VSSVirgilApiContext *)context {
    self = [super init];
    if (self) {
        _Identities = [[VSSIdentitiesManager alloc] initWithContext:context];
        _Cards = [[VSSCardsManager alloc] initWithContext:context];
        _Keys = [[VSSKeysManager alloc] initWithContext:context];
    }
    
    return self;
}

- (instancetype)initWithToken:(NSString *)token {
    VSSVirgilApiContext *context = [[VSSVirgilApiContext alloc] initWithToken:token];
    return [self initWithContext:context];
}

@end
