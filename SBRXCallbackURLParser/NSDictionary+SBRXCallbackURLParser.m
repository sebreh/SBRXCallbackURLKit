//
//  NSDictionary+SBRXCallbackURLParser.m
//  XCallbackURLParserDemo
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "NSDictionary+SBRXCallbackURLParser.h"
#import "NSString+SBRXCallbackURLParser.h"

@implementation NSDictionary (SBRXCallbackURLParser)

- (NSDictionary *)sbr_dictionaryFromKeysPassingTest:(BOOL (^)(id key))block {
  NSArray *filteredKeys = [[self keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
    return block(key);
  }] sortedArrayUsingDescriptors:nil];
  
  return [self dictionaryWithValuesForKeys:filteredKeys];
}

- (NSDictionary *)sbr_dictionaryWithURLEncodedValues {
  NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
  [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    NSString *escapedValue = [obj sbr_URLEncode];
    
    [mutDict setObject:escapedValue forKey:key];
  }];
  
  return [mutDict copy];
}

- (NSString *)sbr_queryStringFromKeysAndValues {
  NSDictionary *escapedParameters = [self sbr_dictionaryWithURLEncodedValues];
  
  NSMutableArray *queryParameters = [[NSMutableArray alloc] initWithCapacity:[escapedParameters count]];
  [escapedParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    NSString *param = [NSString stringWithFormat:@"%@=%@", key, obj];
    [queryParameters addObject:param];
  }];
  
  return [queryParameters componentsJoinedByString:@"&"];
}

@end
