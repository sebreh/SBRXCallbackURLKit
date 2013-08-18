//
//  SBRXCallbackURLAction.m
//  DemoApp
//
//  Created by Sebastian Rehnby on 8/9/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "SBRCallbackAction.h"
#import "NSDictionary+SBRXCallbackURL.h"
#import "NSError+SBRXCallbackURL.h"
#import "NSString+SBRXCallbackURL.h"

@interface SBRCallbackAction ()

@property (nonatomic, strong) NSMutableDictionary *mutParameters;

@end

@implementation SBRCallbackAction

- (instancetype)initWithURLScheme:(NSString *)URLScheme name:(NSString *)name parameters:(NSDictionary *)parameters {
  self = [super init];
  if (self) {
    _URLScheme = [URLScheme copy];
    _name = [name copy];
    _mutParameters = [parameters mutableCopy];
  }
  return self;
}

+ (instancetype)actionWithURLScheme:(NSString *)URLScheme name:(NSString *)name {
  return [self actionWithURLScheme:URLScheme name:name parameters:nil];
}

+ (instancetype)actionWithURLScheme:(NSString *)URLScheme name:(NSString *)name parameters:(NSDictionary *)parameters {
  return [[self alloc] initWithURLScheme:URLScheme name:name parameters:parameters];
}

#pragma mark - Properties

- (NSDictionary *)parameters {
  return [self.mutParameters copy];
}

- (NSMutableDictionary *)mutParameters {
  if (!_mutParameters) {
    _mutParameters = [[NSMutableDictionary alloc] init];
  }
  
  return _mutParameters;
}

#pragma mark - Impl

- (BOOL)canTrigger {
  return [[UIApplication sharedApplication] canOpenURL:[self actionURL]];
}

- (BOOL)trigger {
  return [[UIApplication sharedApplication] openURL:[self actionURL]];
}

- (void)registerCallbacksWithParser:(SBRCallbackParser *)parser successBlock:(SBRCallbackActionSuccessBlock)successBlock {
  return [self registerCallbacksWithParser:parser successBlock:successBlock failureBlock:nil];
}

- (void)registerCallbacksWithParser:(SBRCallbackParser *)parser
          successBlock:(SBRCallbackActionSuccessBlock)successBlock
          failureBlock:(SBRCallbackActionFailureBlock)failureBlock {
  return [self registerCallbacksWithParser:parser successBlock:successBlock failureBlock:failureBlock cancelBlock:nil];
}

- (void)registerCallbacksWithParser:(SBRCallbackParser *)parser
          successBlock:(SBRCallbackActionSuccessBlock)successBlock
          failureBlock:(SBRCallbackActionFailureBlock)failureBlock
           cancelBlock:(SBRCallbackActionCancelBlock)cancelBlock {
  if (successBlock) {
    NSString *successAction = [NSString stringWithFormat:@"%@-%@-success", self.URLScheme, self.name];
    
    SBRCallbackActionHandler *handler = [parser addHandlerForActionName:successAction handlerBlock:^BOOL(NSDictionary *parameters, NSString *source, SBRCallbackActionHandlerCompletionBlock completion) {
      successBlock(parameters);
      
      return YES;
    }];
    
    NSString *callbackURLString = [[parser callbackURLForActionHandler:handler] absoluteString];
    [self.mutParameters setObject:callbackURLString forKey:@"x-success"];
  }
  
  if (failureBlock) {
    NSString *errorAction = [NSString stringWithFormat:@"%@-%@-error", self.URLScheme, self.name];
    
    SBRCallbackActionHandler *handler = [parser addHandlerForActionName:errorAction handlerBlock:^BOOL(NSDictionary *parameters, NSString *source, SBRCallbackActionHandlerCompletionBlock completion) {
      NSUInteger code = [parameters[@"errorCode"] integerValue];
      NSString *message = parameters[@"errorMessage"];
      NSError *error = [NSError sbr_errorWithCode:code message:message];
      
      failureBlock(error);
      
      return YES;
    }];
    
    NSString *callbackURLString = [[parser callbackURLForActionHandler:handler] absoluteString];
    [self.mutParameters setObject:callbackURLString forKey:@"x-error"];
  }
  
  if (cancelBlock) {
    NSString *cancelAction = [NSString stringWithFormat:@"%@-%@-cancel", self.URLScheme, self.name];
    
    SBRCallbackActionHandler *handler = [parser addHandlerForActionName:cancelAction handlerBlock:^BOOL(NSDictionary *parameters, NSString *source, SBRCallbackActionHandlerCompletionBlock completion) {
      cancelBlock();
      
      return YES;
    }];
    
    NSString *callbackURLString = [[parser callbackURLForActionHandler:handler] absoluteString];
    [self.mutParameters setObject:callbackURLString forKey:@"x-cancel"];
  }
}

#pragma mark - Helpers

- (NSURL *)actionURL {
  NSString *urlString = [NSString stringWithFormat:@"%@://x-callback-url/%@", self.URLScheme, self.name];
  
  if ([self.parameters count] > 0) {
    NSString *queryString = [self.parameters sbr_queryStringFromKeysAndValues];
    urlString = [urlString stringByAppendingFormat:@"?%@", queryString];
  }
  
  return [NSURL URLWithString:urlString];
}

@end
