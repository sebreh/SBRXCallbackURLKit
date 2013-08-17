//
//  SBRXCallbackURLAction.h
//  DemoApp
//
//  Created by Sebastian Rehnby on 8/9/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBRCallbackParser.h"

typedef void (^SBRCallbackActionSuccessBlock) (NSDictionary *parameters);
typedef void (^SBRCallbackActionFailureBlock) (NSError *error);
typedef void (^SBRCallbackActionCancelBlock) (void);

@interface SBRCallbackAction : NSObject

@property (nonatomic, copy, readonly) NSString *URLScheme;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSDictionary *parameters;

+ (instancetype)actionWithURLScheme:(NSString *)URLScheme name:(NSString *)name;
+ (instancetype)actionWithURLScheme:(NSString *)URLScheme name:(NSString *)name parameters:(NSDictionary *)parameters;

- (BOOL)canTrigger;
- (BOOL)trigger;

- (void)registerWithParser:(SBRCallbackParser *)parser successBlock:(SBRCallbackActionSuccessBlock)successBlock;

- (void)registerWithParser:(SBRCallbackParser *)parser
              successBlock:(SBRCallbackActionSuccessBlock)successBlock
              failureBlock:(SBRCallbackActionFailureBlock)failureBlock;

- (void)registerWithParser:(SBRCallbackParser *)parser
              successBlock:(SBRCallbackActionSuccessBlock)successBlock
              failureBlock:(SBRCallbackActionFailureBlock)failureBlock
               cancelBlock:(SBRCallbackActionCancelBlock)cancelBlock;

@end
