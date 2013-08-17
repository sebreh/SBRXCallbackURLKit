//
//  SBRXCallbackURLActionHandler.h
//
//  Created by Sebastian Rehnby on 8/7/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>

// Returns the success parameters to include. The success callback URL will be called with the
// returned parameters appended.
typedef void (^SBRCallbackActionHandlerCompletionBlock) (NSDictionary *successParameters, NSError *error, BOOL cancelled);
typedef BOOL (^SBRCallbackActionHandlerBlock) (NSDictionary *parameters, NSString *source, SBRCallbackActionHandlerCompletionBlock completion);

@interface SBRCallbackActionHandler : NSObject

@property (nonatomic, copy) NSString *actionName;
@property (nonatomic, copy) NSArray *requiredParameters;
@property (nonatomic, copy) SBRCallbackActionHandlerBlock handlerBlock;

- (instancetype)initWithActionName:(NSString *)actionName requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRCallbackActionHandlerBlock)handlerBlock;

+ (instancetype)handlerForActionName:(NSString *)actionName requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRCallbackActionHandlerBlock)handlerBlock;

@end
