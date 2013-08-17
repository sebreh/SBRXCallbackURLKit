//
//  NSError+SBRCallbackURLParser.h
//  DemoApp
//
//  Created by Sebastian Rehnby on 8/17/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SBRXCallbackURLErrorCode) {
  SBRXCallbackURLErrorCodeMissingParameter = 1,
};

extern NSString * const SBRXCallbackURLErrorDomain;

@interface NSError (SBRCallbackURLParser)

+ (NSError *)sbr_errorWithCode:(NSInteger)code message:(NSString *)message;

@end
