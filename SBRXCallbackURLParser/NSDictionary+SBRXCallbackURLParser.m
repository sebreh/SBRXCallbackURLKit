//
//  NSDictionary+SBRXCallbackURLParser.m
//  XCallbackURLParserDemo
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "NSDictionary+SBRXCallbackURLParser.h"

@implementation NSDictionary (SBRXCallbackURLParser)

- (NSDictionary *)sbr_dictionaryFromKeysPassingTest:(BOOL (^)(id key))block {
  NSArray *filteredKeys = [[self keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
    return block(key);
  }] sortedArrayUsingDescriptors:nil];
  
  return [self dictionaryWithValuesForKeys:filteredKeys];
}

@end
