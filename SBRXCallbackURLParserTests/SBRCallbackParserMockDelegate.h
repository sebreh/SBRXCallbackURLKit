//
//  SBRXCallbackURLParserMockDelegate.h
//  DemoApp
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBRCallbackParser.h"

@interface SBRCallbackParserMockDelegate : NSObject <SBRCallbackParserDelegate>

- (BOOL)wasCallbackURLStringCalled:(NSString *)URLString;

@end
