//
//  NSString+SBRXCallbackURL.m
//  XCallbackURLParserDemo
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "NSString+SBRXCallbackURL.h"

@implementation NSString (SBRXCallbackURL)

- (NSString *)sbr_URLEncode {
  NSString *encodedString = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                   (__bridge CFStringRef)self,
                                                                                                   NULL,
                                                                                                   (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8);
  return encodedString;
}

- (NSString *)sbr_URLDecode {
  NSString *decodedString = (__bridge_transfer NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                   (__bridge CFStringRef)self,
                                                                                                                   CFSTR(""),
                                                                                                                   kCFStringEncodingUTF8);
  return decodedString;
}

@end
