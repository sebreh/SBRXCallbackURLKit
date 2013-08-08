//
//  SBRXCallbackURLParser.h
//
//  Created by Sebastian Rehnby on 8/7/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBRXCallbackURLAction.h"

typedef NS_ENUM(NSUInteger, SBRXCallbackURLParserError) {
  SBRXCallbackURLParserErrorMissingParameter = 1,
};

@protocol SBRXCallbackURLParserDelegate;

@interface SBRXCallbackURLParser : NSObject

@property (nonatomic, weak) id<SBRXCallbackURLParserDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *URLScheme;

- (instancetype)initWithURLScheme:(NSString *)URLScheme;
+ (instancetype)parserWithURLScheme:(NSString *)URLScheme;

- (void)addAction:(SBRXCallbackURLAction *)action;
- (void)addActionWithName:(NSString *)actionName handlerBlock:(SBRXCallbackURLActionHandlerBlock)handlerBlock;
- (void)addActionWithName:(NSString *)actionName requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRXCallbackURLActionHandlerBlock)handlerBlock;

- (BOOL)handleURL:(NSURL *)URL;

@end


@protocol SBRXCallbackURLParserDelegate <NSObject>

@optional

- (void)xCallbackURLParser:(SBRXCallbackURLParser *)parser shouldOpenSourceCallbackURL:(NSURL *)callbackURL;

@end