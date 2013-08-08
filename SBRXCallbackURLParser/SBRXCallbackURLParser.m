//
//  SBRXCallbackURLParser.m
//
//  Created by Sebastian Rehnby on 8/7/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "SBRXCallbackURLParser.h"
#import "NSDictionary+SBRXCallbackURLParser.h"
#import "NSURL+SBRXCallbackURLParser.h"
#import "NSString+SBRXCallbackURLParser.h"

@interface SBRXCallbackURLParser ()

@property (nonatomic, copy) NSString *URLScheme;
@property (nonatomic, strong) NSMutableDictionary *actions;

@end

@implementation SBRXCallbackURLParser

- (instancetype)initWithURLScheme:(NSString *)URLScheme {
  self = [super init];
  if (self) {
    _URLScheme = [URLScheme copy];
  }
  return self;
}

+ (instancetype)parserWithURLScheme:(NSString *)URLScheme {
  return [[self alloc] initWithURLScheme:URLScheme];
}

#pragma mark - NSObject

- (NSString *)description {
  NSMutableArray *actionDescriptions = [NSMutableArray new];
  
  [self.actions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    NSString *actionName = key;
    SBRXCallbackURLAction *action = obj;
    
    NSString *actionDescription = [NSString stringWithFormat:@"%@ = %@://x-callback-url/%@", actionName, self.URLScheme, action.name];
    [actionDescriptions addObject:actionDescription];
  }];
  
  return [actionDescriptions description];
}

#pragma mark - Properties

- (NSMutableDictionary *)actions {
  if (!_actions) {
    _actions = [NSMutableDictionary new];
  }
  
  return _actions;
}

#pragma mark - Impl

- (void)addAction:(SBRXCallbackURLAction *)action {
  [self.actions setObject:action forKey:action.name];
}

- (void)addActionWithName:(NSString *)actionName handlerBlock:(SBRXCallbackURLActionHandlerBlock)handlerBlock {
  [self addActionWithName:actionName requiredParameters:nil handlerBlock:handlerBlock];
}

- (void)addActionWithName:(NSString *)actionName requiredParameters:(NSArray *)requiredParameters handlerBlock:(SBRXCallbackURLActionHandlerBlock)handlerBlock {
  SBRXCallbackURLAction *action = [SBRXCallbackURLAction actionWithName:actionName
                                                   requiredParameters:requiredParameters
                                                         handlerBlock:handlerBlock];
  [self addAction:action];
}

- (BOOL)handleURL:(NSURL *)URL {
  SBRXCallbackURLAction *action = [self actionForURL:URL];
  if (!action) {
    return NO;
  }
  
  NSDictionary *xParameters = [self xParametersFromURL:URL];
  NSDictionary *userParameters = [self userParametersFromURL:URL];
  
  // Look for missing parameters
  NSArray *missingParameters = [self missingParametersInUserParameters:userParameters requiredParameters:action.requiredParameters];
  if ([missingParameters count] > 0) {
    NSString *message = [NSString stringWithFormat:@"Missing parameters %@", [missingParameters componentsJoinedByString:@"m"]];
    [self callErrorCallbackInXParameters:xParameters code:SBRXCallbackURLParserErrorMissingParameter message:message];
    return NO;
  }
  
  // Call handler
  __weak SBRXCallbackURLParser *weakSelf = self;
  SBRXCallbackURLActionCompletionBlock completion = ^(NSDictionary *successParameters, NSError *error, BOOL cancelled) {
    [weakSelf performCallbacksInXParameters:xParameters successParameters:successParameters error:error cancelled:cancelled];
  };
  
  // x-source:
  // The friendly name of the source app calling the action. If the action in the
  // target app requires user interface elements, it may be necessary to identify to the user
  // the app requesting the action.
  NSString *xSource = xParameters[@"x-source"];
  
  BOOL handled = action.handlerBlock(userParameters, xSource, completion);
  
  return handled;
}

#pragma mark - Helpers

- (SBRXCallbackURLAction *)actionForURL:(NSURL *)URL {
  if (![URL.scheme isEqualToString:self.URLScheme] || ![URL.host isEqualToString:@"x-callback-url"]) {
    return nil;
  }
  
  NSString *actionName = [URL.path lastPathComponent];
  if ([actionName length] == 0) {
    return nil;
  }
  
  SBRXCallbackURLAction *action = [self.actions objectForKey:actionName];
  if (!action) {
    return nil;
  }
  
  if (!action.handlerBlock) {
    return nil;
  }
  
  return action;
}

- (NSDictionary *)xParametersFromURL:(NSURL *)URL {
  NSDictionary *parameters = [URL sbr_queryParameters];
  NSDictionary *xParameters = [parameters sbr_dictionaryFromKeysPassingTest:^BOOL(id key) {
    return [key length] >= 2 && [[key substringToIndex:2] isEqualToString:@"x-"];
  }];
  
  return xParameters;
}

- (NSDictionary *)userParametersFromURL:(NSURL *)URL {
  NSDictionary *parameters = [URL sbr_queryParameters];
  NSDictionary *xParameters = [self xParametersFromURL:URL];
  
  NSDictionary *userParameters = [parameters sbr_dictionaryFromKeysPassingTest:^BOOL(id key) {
    return [xParameters objectForKey:key] == nil;
  }];
  
  return userParameters;
}

- (NSArray *)missingParametersInUserParameters:(NSDictionary *)userParameters requiredParameters:(NSArray *)requiredParameters {
  // Check for missing user parameters
  NSMutableArray *missingParameters = [NSMutableArray new];
  for (NSString *requiredParameter in requiredParameters) {
    NSString *value = userParameters[requiredParameter];
    if (!value || [value length] == 0) {
      [missingParameters addObject:requiredParameter];
    }
  }
  
  return [missingParameters copy];
}

- (void)performCallbacksInXParameters:(NSDictionary *)xParameters successParameters:(NSDictionary *)successParameters error:(NSError *)error cancelled:(BOOL)cancelled {
  if (error) {
    [self callErrorCallbackInXParameters:xParameters error:error];
  } else if (cancelled) {
    [self callCancelledCallbackInXParameters:xParameters];
  } else {
    [self callSuccessCallbackInXParameters:xParameters successParameters:successParameters];
  }
}

- (void)callErrorCallbackInXParameters:(NSDictionary *)xParameters error:(NSError *)error {
  [self callErrorCallbackInXParameters:xParameters code:error.code message:[error localizedDescription]];
}

- (void)callErrorCallbackInXParameters:(NSDictionary *)xParameters code:(NSUInteger)code message:(NSString *)message {
  // x-error:
  // URL to open if the requested action generates an error in the target app. This URL
  // will be open with at least the parameters “errorCode=code&errorMessage=message. If x-error
  // is not present, and a error occurs, it is assumed the target app will report the failure
  // to the user and remain in the target app.
  NSString *callback = xParameters[@"x-error"];
  
  if ([callback length] > 0) {
    NSDictionary *parameters = @{@"errorCode": [NSString stringWithFormat:@"%d", code],
                                 @"errorMessage": message};
    [self callSourceCallbackURLString:callback parameters:parameters];
  }
}

- (void)callSuccessCallbackInXParameters:(NSDictionary *)xParameters successParameters:(NSDictionary *)successParameters {
  // x-success:
  // If the action in the target method is intended to return a result to the source
  // app, the x-callback parameter should be included and provide a URL to open to return to
  // the source app. On completion of the action, the target app will open this URL, possibly
  // with additional parameters tacked on to return a result to the source app. If x-success
  // is not provided, it is assumed that the user will stay in the target app on successful
  // completion of the action.
  NSString *callback = xParameters[@"x-success"];
  
  if ([callback length] > 0) {
    [self callSourceCallbackURLString:callback parameters:successParameters];
  }
}

- (void)callCancelledCallbackInXParameters:(NSDictionary *)xParameters {
  // x-cancel:
  // URL to open if the requested action is cancelled by the user. In the case
  // where the target app offer the user the option to “cancel” the requested action, without
  // a success or error result, this the the URL that should be opened to return the user to
  // the source app.
  NSString *callback = xParameters[@"x-cancel"];
  
  if ([callback length] > 0) {
    [self callSourceCallbackURLString:callback parameters:nil];
  }
}

- (void)callSourceCallbackURLString:(NSString *)URLString parameters:(NSDictionary *)parameters {
  if ([self.delegate respondsToSelector:@selector(xCallbackURLParser:shouldOpenSourceCallbackURL:)]) {
    NSURL *url = [self callbackURLFromOriginalURLString:URLString parameters:parameters];
    [self.delegate xCallbackURLParser:self shouldOpenSourceCallbackURL:url];
  }
}

- (NSURL *)callbackURLFromOriginalURLString:(NSString *)originalURLString parameters:(NSDictionary *)parameters {
  NSString *urlString = originalURLString;
  
  if ([parameters count] > 0) {
    NSMutableArray *queryParameters = [[NSMutableArray alloc] initWithCapacity:[parameters count]];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      NSString *escapedValue = [obj sbr_URLEncode];
      NSString *queryParam = [NSString stringWithFormat:@"%@=%@", key, escapedValue];
      
      [queryParameters addObject:queryParam];
    }];
    
    NSString *queryString = [queryParameters componentsJoinedByString:@"&"];
    NSString *prefix = [originalURLString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
    
    urlString = [NSString stringWithFormat:@"%@%@%@", originalURLString, prefix, queryString];
  }
  
  return [NSURL URLWithString:urlString];
}

@end
