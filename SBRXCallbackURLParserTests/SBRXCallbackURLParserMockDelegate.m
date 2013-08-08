//
//  SBRXCallbackURLParserMockDelegate.m
//  DemoApp
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "SBRXCallbackURLParserMockDelegate.h"

@interface SBRXCallbackURLParserMockDelegate ()

@property (nonatomic, strong) NSMutableArray *callbacks;

@end

@implementation SBRXCallbackURLParserMockDelegate

#pragma mark - Properties

- (NSMutableArray *)callbacks {
  if (!_callbacks) {
    _callbacks = [[NSMutableArray alloc] init];
  }
  
  return _callbacks;
}

#pragma mark - Impl

- (BOOL)wasCallbackURLStringCalled:(NSString *)URLString {
  return [self.callbacks containsObject:URLString];
}

#pragma mark - SBRXCallbackURLParserDelegate

- (void)xCallbackURLParser:(SBRXCallbackURLParser *)parser shouldOpenSourceCallbackURL:(NSURL *)callbackURL {
  [self.callbacks addObject:[callbackURL absoluteString]];
}

@end
