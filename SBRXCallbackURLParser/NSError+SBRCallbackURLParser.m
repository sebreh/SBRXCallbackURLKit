//
//  NSError+SBRCallbackURLParser.m
//  DemoApp
//
//  Created by Sebastian Rehnby on 8/17/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "NSError+SBRCallbackURLParser.h"

NSString * const SBRXCallbackURLErrorDomain = @"SBRXCallbackURLErrorDomain";

@implementation NSError (SBRCallbackURLParser)

+ (NSError *)sbr_errorWithCode:(NSInteger)code message:(NSString *)message {
  NSDictionary *userInfo = message ? @{NSLocalizedDescriptionKey: message} : nil;
  NSError *error = [NSError errorWithDomain:SBRXCallbackURLErrorDomain code:code userInfo:userInfo];
  
  return error;
}

@end
