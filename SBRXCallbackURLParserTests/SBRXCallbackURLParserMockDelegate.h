//
//  SBRXCallbackURLParserMockDelegate.h
//  DemoApp
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBRXCallbackURLParser.h"

@interface SBRXCallbackURLParserMockDelegate : NSObject <SBRXCallbackURLParserDelegate>

- (BOOL)wasCallbackURLStringCalled:(NSString *)URLString;

@end
