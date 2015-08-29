//
//  SBRXCallbackURLParser.h
//
//  Created by Sebastian Rehnby on 8/7/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBRCallbackActionHandler.h"

typedef NS_ENUM(NSInteger, SBRCallbackParserError) {
  SBRCallbackParserErrorMissingParameter = 1,
};

@protocol SBRCallbackParserDelegate;

@interface SBRCallbackParser : NSObject

@property (nonatomic, weak) id<SBRCallbackParserDelegate> delegate;
@property (nonatomic, copy) NSString *URLScheme;

+ (instancetype)sharedParser;

- (instancetype)initWithURLScheme:(NSString *)URLScheme;
+ (instancetype)parserWithURLScheme:(NSString *)URLScheme;

- (void)addActionHandler:(SBRCallbackActionHandler *)handler;
- (SBRCallbackActionHandler *)addHandlerForActionName:(NSString *)actionName handlerBlock:(SBRCallbackActionHandlerBlock)handlerBlock;
- (SBRCallbackActionHandler *)addHandlerForActionName:(NSString *)actionName requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRCallbackActionHandlerBlock)handlerBlock;

- (NSURL *)callbackURLForActionHandler:(SBRCallbackActionHandler *)actionHandler;

- (BOOL)handleURL:(NSURL *)URL;

@end


@protocol SBRCallbackParserDelegate <NSObject>

@optional

- (void)xCallbackURLParser:(SBRCallbackParser *)parser shouldOpenSourceCallbackURL:(NSURL *)callbackURL;

@end