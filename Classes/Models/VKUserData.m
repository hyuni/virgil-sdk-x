//
//  VKUserData.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKUserData.h"
#import "VKIdBundle.h"
#import "VKModelCommons.h"

#import <VirgilFrameworkiOS/VFUserData_Protected.h>
#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

@interface VKUserData ()

@property (nonatomic, copy, readwrite) VKIdBundle *idb;
@property (nonatomic, copy, readwrite) NSNumber *confirmed;

@end

@implementation VKUserData

@synthesize idb = _idb;
@synthesize confirmed = _confirmed;

#pragma mark - Lifecycle

- (instancetype)initWithIdb:(VKIdBundle *)idb dataClass:(VFUserDataClass)dataClass dataType:(VFUserDataType)dataType value:(NSString *)value confirmed:(NSNumber *)confirmed {
    self = [super initWithDataClass:dataClass dataType:dataType value:value];
    if (self == nil) {
        return nil;
    }

    _idb = [idb copy];
    _confirmed = [confirmed copy];
    return self;
}

- (instancetype)initWithUserData:(VKUserData *)userData {
    return [self initWithIdb:userData.idb dataClass:userData.dataClass dataType:userData.dataType value:userData.value confirmed:userData.confirmed];
}

- (instancetype)initWithDataClass:(VFUserDataClass)dataClass dataType:(VFUserDataType)dataType value:(NSString *)value {
    return [self initWithIdb:nil dataClass:dataClass dataType:dataType value:value confirmed:@NO];
}

- (instancetype)init {
    return [self initWithIdb:nil dataClass:UDCUnknown dataType:UDTUnknown value:nil confirmed:@NO];
}

#pragma mark - NSCopying protocol implementation

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithIdb:self.idb dataClass:self.dataClass dataType:self.dataType value:self.value confirmed:self.confirmed];
}

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VKIdBundle *idb = [[aDecoder decodeObjectForKey:kVKModelId] as:[VKIdBundle class]];
    NSNumber *classCandidate = [[aDecoder decodeObjectForKey:kVFModelClass] as:[NSNumber class]];
    NSNumber *typeCandidate = [[aDecoder decodeObjectForKey:kVFModelType] as:[NSNumber class]];
    NSString *value = [[aDecoder decodeObjectForKey:kVFModelValue] as:[NSString class]];
    NSNumber *confirmed = [[aDecoder decodeObjectForKey:kVKModelConfirmed] as:[NSNumber class]];
    
    return [self initWithIdb:idb dataClass:(VFUserDataClass)[classCandidate unsignedIntegerValue] dataType:(VFUserDataType)[typeCandidate unsignedIntegerValue] value:value confirmed:confirmed];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.idb != nil) {
        [aCoder encodeObject:self.idb forKey:kVKModelId];
    }
    if (self.confirmed != nil) {
        [aCoder encodeObject:self.confirmed forKey:kVKModelConfirmed];
    }
}

#pragma mark - VKSerializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *idBundle = [candidate[kVKModelId] as:[NSDictionary class]];
    VKIdBundle *idb = [VKIdBundle deserializeFrom:idBundle];

    NSString *classCandidate = [candidate[kVFModelClass] as:[NSString class]];
    NSString *typeCandidate = [candidate[kVFModelType] as:[NSString class]];
    NSString *value = [candidate[kVFModelValue] as:[NSString class]];
    NSNumber *confirmed = [candidate[kVKModelConfirmed] as:[NSNumber class]];
    
    return [[self alloc] initWithIdb:idb dataClass:[self userDataClassFromString:classCandidate] dataType:[self userDataTypeFromString:typeCandidate] value:value confirmed:confirmed];
}

#pragma mark - Overrides 

- (NSNumber *)isValid {
    BOOL valid = NO;
    valid = ( [super isValid] && (self.idb.userDataId.length > 0) );
    return [NSNumber numberWithBool:valid];
}

@end
