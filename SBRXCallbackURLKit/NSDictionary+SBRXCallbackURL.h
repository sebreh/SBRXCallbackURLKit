//
//  NSDictionary+SBRXCallbackURL.h
//  XCallbackURLParserDemo
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SBRXCallbackURL)

- (NSDictionary *)sbr_dictionaryFromKeysPassingTest:(BOOL (^)(id key))block;

- (NSDictionary *)sbr_dictionaryWithURLEncodedValues;

- (NSString *)sbr_queryStringFromKeysAndValues;

@end
