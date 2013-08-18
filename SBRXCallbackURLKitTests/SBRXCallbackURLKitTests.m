//
//  SBRXCallbackURLKitTests.m
//
//  Created by Sebastian Rehnby on 8/7/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SBRCallbackAction.h"
#import "SBRCallbackParser.h"
#import "SBRCallbackParserMockDelegate.h"

static NSString * const kURLScheme = @"demoapp";

@interface SBRXCallbackURLKitTests : SenTestCase

@end

@implementation SBRXCallbackURLKitTests

#pragma mark - Parsing

- (void)testHandlerBlockCalled {
  [self performTestForParserWithURLScheme:kURLScheme
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:YES
                             forPathString:@"myAction"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testActionNotFound {
  [self performTestForParserWithURLScheme:kURLScheme
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:NO
                             forPathString:@"myOtherAction"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testInvalidURLScheme {
  [self performTestForParserWithURLScheme:kURLScheme
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:NO
                             forURLString:@"wrong://x-callback-url/myAction"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testInvalidHost {
  [self performTestForParserWithURLScheme:kURLScheme
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:NO
                             forURLString:@"myapp://wrong-host/myAction"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testRequiredParametersMissing {
  [self performTestForParserWithURLScheme:kURLScheme
                               withAction:@"myAction"
                       requiredParameters:@[@"subject"]
                           shouldBeCalled:NO
                             forPathString:@"myAction?text=mytext"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testRequiredParametersMissingWithErrorCallback {
  SBRCallbackParserMockDelegate *delegate = [SBRCallbackParserMockDelegate new];
  
  [self performTestForParserWithURLScheme:kURLScheme
                               withAction:@"myAction"
                       requiredParameters:@[@"subject"]
                           shouldBeCalled:NO
                             forPathString:@"myAction?text=mytext&x-error=otherapp%3A%2F%2Fx-callback-url%2Ferror"
                        successParameters:nil
                                 delegate:delegate];
  
  BOOL wasCalled = [delegate wasCallbackURLStringCalled:@"otherapp://x-callback-url/error?errorMessage=Missing%20parameters%20subject&errorCode=1"];
  STAssertTrue(wasCalled, @"Expected callback not called");
}

- (void)testRequiredParametersIsPresent {
  [self performTestForParserWithURLScheme:kURLScheme
                               withAction:@"myAction"
                       requiredParameters:@[@"subject"]
                           shouldBeCalled:YES
                             forPathString:@"myAction?text=mytext&subject=mysubject"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testSuccessCallbackWithSourceParameter {
  SBRCallbackParserMockDelegate *delegate = [SBRCallbackParserMockDelegate new];
  
  [self performTestForParserWithURLScheme:kURLScheme
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:YES
                             forPathString:@"myAction?x-success=otherapp%3A%2F%2Fx-callback-url%2Fcompleted%3Fname%3Dvalue"
                        successParameters:nil
                                 delegate:delegate];
  
  BOOL wasCalled = [delegate wasCallbackURLStringCalled:@"otherapp://x-callback-url/completed?name=value"];
  STAssertTrue(wasCalled, @"Expected callback not called");
}

- (void)testSuccessCallbackWithoutSourceParameter {
  SBRCallbackParserMockDelegate *delegate = [SBRCallbackParserMockDelegate new];
  
  [self performTestForParserWithURLScheme:kURLScheme
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:YES
                             forPathString:@"myAction?x-success=otherapp%3A%2F%2Fx-callback-url%2Fcompleted"
                        successParameters:nil
                                 delegate:delegate];
  
  BOOL wasCalled = [delegate wasCallbackURLStringCalled:@"otherapp://x-callback-url/completed"];
  STAssertTrue(wasCalled, @"Expected callback not called");
}

- (void)testSuccessCallbackWithSuccessParameters {
  SBRCallbackParserMockDelegate *delegate = [SBRCallbackParserMockDelegate new];
  
  [self performTestForParserWithURLScheme:kURLScheme
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:YES
                             forPathString:@"myAction?x-success=otherapp%3A%2F%2Fx-callback-url%2Fcompleted"
                        successParameters:@{@"name" : @"value"}
                                 delegate:delegate];
  
  BOOL wasCalled = [delegate wasCallbackURLStringCalled:@"otherapp://x-callback-url/completed?name=value"];
  STAssertTrue(wasCalled, @"Expected callback not called");
}

- (void)testCallbackURLForActionHandler {
  SBRCallbackParser *parser = [[SBRCallbackParser alloc] initWithURLScheme:kURLScheme];
  SBRCallbackActionHandler *handler = [parser addHandlerForActionName:@"myAction"
                                                         handlerBlock:^BOOL(NSDictionary *parameters, NSString *source, SBRCallbackActionHandlerCompletionBlock completion) { return YES; }];
  
  NSString *URLString = [[parser callbackURLForActionHandler:handler] absoluteString];
  NSString *expectedURLString = [NSString stringWithFormat:@"%@://x-callback-url/myAction", kURLScheme];
  STAssertTrue([URLString isEqualToString:expectedURLString], @"Callback URL for handler does not match");
}

#pragma mark - Triggering

- (void)testCanTriggerAction {
  SBRCallbackAction *action = [SBRCallbackAction actionWithURLScheme:kURLScheme name:@"postStatus"];
  STAssertTrue([action canTrigger], @"Should not be able to trigger action.");
}

- (void)testCanNotTriggerAction {
  SBRCallbackAction *action = [SBRCallbackAction actionWithURLScheme:@"otherapp" name:@"drawSomething"];
  STAssertFalse([action canTrigger], @"Should not be able to trigger action.");
}

- (void)testRegistersCallbackParameters {
  SBRCallbackAction *action = [SBRCallbackAction actionWithURLScheme:@"otherapp" name:@"drawSomething"];
  SBRCallbackParser *parser = [SBRCallbackParser parserWithURLScheme:kURLScheme];
  
  [action registerCallbacksWithParser:parser
                         successBlock:^(NSDictionary *parameters) {}
                         failureBlock:^(NSError *error) {}
                          cancelBlock:^{}];
  
  STAssertTrue([[action.parameters allKeys] containsObject:@"x-success"], @"Action should have x-success parameter.");  
  STAssertTrue([[action.parameters allKeys] containsObject:@"x-error"], @"Action should have x-error parameter.");
  STAssertTrue([[action.parameters allKeys] containsObject:@"x-cancel"], @"Action should have x-cancel parameter.");
}

#pragma mark - Helpers

- (void)performTestForParserWithURLScheme:(NSString *)URLScheme
                               withAction:(NSString *)action
                       requiredParameters:(NSArray *)requiredParameters
                           shouldBeCalled:(BOOL)shouldBeCalled
                            forPathString:(NSString *)pathString
                        successParameters:(NSDictionary *)successParameters
                                 delegate:(id<SBRCallbackParserDelegate>)delegate {
  NSString *URLString = [NSString stringWithFormat:@"%@://x-callback-url/%@", kURLScheme, pathString];
  [self performTestForParserWithURLScheme:URLScheme
                               withAction:action
                       requiredParameters:requiredParameters
                           shouldBeCalled:shouldBeCalled
                             forURLString:URLString
                        successParameters:successParameters
                                 delegate:delegate];
}

- (void)performTestForParserWithURLScheme:(NSString *)URLScheme
                               withAction:(NSString *)action
                       requiredParameters:(NSArray *)requiredParameters
                           shouldBeCalled:(BOOL)shouldBeCalled
                             forURLString:(NSString *)URLString
                        successParameters:(NSDictionary *)successParameters
                                 delegate:(id<SBRCallbackParserDelegate>)delegate {
  SBRCallbackParser *parser = [SBRCallbackParser parserWithURLScheme:URLScheme];
  parser.delegate = delegate;
  
  __block BOOL called = NO;
  [parser addHandlerForActionName:action requiredParameters:requiredParameters handlerBlock:^(NSDictionary *parameters, NSString *sourceApp, SBRCallbackActionHandlerCompletionBlock completion) {
    called = YES;
    
    completion(successParameters, nil, NO);
    
    return YES;
  }];
  
  NSURL *url = [NSURL URLWithString:URLString];
  BOOL handled = [parser handleURL:url];
  
  STAssertTrue(called == shouldBeCalled, (shouldBeCalled ? @"Handler block was not called." : @"Handler block was called when it shouldn't."));
  STAssertTrue(handled == shouldBeCalled, (shouldBeCalled ? @"URL was not handled." : @"URL was handled when it shouldn't."));
}

@end
