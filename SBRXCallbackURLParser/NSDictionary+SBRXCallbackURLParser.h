//
//  NSDictionary+SBRXCallbackURLParser.h
//  XCallbackURLParserDemo
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SBRXCallbackURLParser)

- (NSDictionary *)sbr_dictionaryFromKeysPassingTest:(BOOL (^)(id key))block;

@end
