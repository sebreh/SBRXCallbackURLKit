//
//  SBRXCallbackURLAction.m
//
//  Created by Sebastian Rehnby on 8/7/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "SBRXCallbackURLAction.h"

@implementation SBRXCallbackURLAction

- (instancetype)initWithName:(NSString *)name requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRXCallbackURLActionHandlerBlock)handlerBlock {
  self = [super init];
  if (self) {
    _name = [name copy];
    _requiredParameters = [requiredParameters copy];
    _handlerBlock = [handlerBlock copy];
  }
  return self;
}

+ (instancetype)actionWithName:(NSString *)name requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRXCallbackURLActionHandlerBlock)handlerBlock {
  return [[self alloc] initWithName:name requiredParameters:requiredParameters handlerBlock:handlerBlock];
}

@end
