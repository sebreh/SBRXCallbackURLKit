//
//  SBRXCallbackURLAction.h
//
//  Created by Sebastian Rehnby on 8/7/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <Foundation/Foundation.h>

// Returns the success parameters to include. The success callback URL will be called with the
// returned parameters appended.
typedef void (^SBRXCallbackURLActionCompletionBlock) (NSDictionary *successParameters, NSError *error, BOOL cancelled);
typedef BOOL (^SBRXCallbackURLActionHandlerBlock) (NSDictionary *parameters, NSString *source, SBRXCallbackURLActionCompletionBlock completion);

@interface SBRXCallbackURLAction : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *requiredParameters;
@property (nonatomic, copy) SBRXCallbackURLActionHandlerBlock handlerBlock;

- (instancetype)initWithName:(NSString *)name requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRXCallbackURLActionHandlerBlock)handlerBlock;

+ (instancetype)actionWithName:(NSString *)name requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRXCallbackURLActionHandlerBlock)handlerBlock;

@end
