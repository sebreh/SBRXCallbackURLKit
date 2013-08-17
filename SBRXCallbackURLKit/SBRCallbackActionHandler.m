//
//  SBRXCallbackURLActionHandler.m
//
//  Created by Sebastian Rehnby on 8/7/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "SBRCallbackActionHandler.h"

@implementation SBRCallbackActionHandler

- (instancetype)initWithActionName:(NSString *)actionName requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRCallbackActionHandlerBlock)handlerBlock {
  self = [super init];
  if (self) {
    _actionName = [actionName copy];
    _requiredParameters = [requiredParameters copy];
    _handlerBlock = [handlerBlock copy];
  }
  return self;
}

+ (instancetype)handlerForActionName:(NSString *)actionName requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRCallbackActionHandlerBlock)handlerBlock {
  return [[self alloc] initWithActionName:actionName requiredParameters:requiredParameters handlerBlock:handlerBlock];
}

@end
