//
//  NSURL+SBRXCallbackURL.m
//  XCallbackURLParserDemo
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "NSURL+SBRXCallbackURL.h"
#import "NSString+SBRXCallbackURL.h"

@implementation NSURL (SBRXCallbackURL)

- (NSDictionary *)sbr_queryParameters {
  NSArray *chunks = [[self query] componentsSeparatedByString:@"&"];
  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:[chunks count]];
  
  [chunks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSArray *parts = [obj componentsSeparatedByString:@"="];
    
    if ([parts count] >= 2) {
      NSString *name = parts[0];
      NSString *value = parts[1];
      parameters[name] = [value sbr_URLDecode];
    }
  }];
  
  return [parameters copy];
}

@end
