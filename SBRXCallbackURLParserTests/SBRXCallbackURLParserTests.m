//
//  SBRXCallbackURLParserTests.m
//
//  Created by Sebastian Rehnby on 8/7/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SBRXCallbackURLParser.h"
#import "SBRXCallbackURLParserMockDelegate.h"

@interface SBRXCallbackURLParserTests : SenTestCase

@end

@implementation SBRXCallbackURLParserTests

- (void)testHandlerBlockCalled {
  [self performTestForParserWithURLScheme:@"myapp"
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:YES
                             forURLString:@"myapp://x-callback-url/myAction"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testActionNotFound {
  [self performTestForParserWithURLScheme:@"myapp"
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:NO
                             forURLString:@"myapp://x-callback-url/myOtherAction"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testInvalidURLScheme {
  [self performTestForParserWithURLScheme:@"myapp"
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:NO
                             forURLString:@"wrong://x-callback-url/myAction"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testInvalidHost {
  [self performTestForParserWithURLScheme:@"myapp"
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:NO
                             forURLString:@"myapp://wrong-host/myAction"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testRequiredParametersMissing {
  [self performTestForParserWithURLScheme:@"myapp"
                               withAction:@"myAction"
                       requiredParameters:@[@"subject"]
                           shouldBeCalled:NO
                             forURLString:@"myapp://x-callback-url/myAction?text=mytext"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testRequiredParametersMissingWithErrorCallback {
  SBRXCallbackURLParserMockDelegate *delegate = [SBRXCallbackURLParserMockDelegate new];
  
  [self performTestForParserWithURLScheme:@"myapp"
                               withAction:@"myAction"
                       requiredParameters:@[@"subject"]
                           shouldBeCalled:NO
                             forURLString:@"myapp://x-callback-url/myAction?text=mytext&x-error=otherapp%3A%2F%2Fx-callback-url%2Ferror"
                        successParameters:nil
                                 delegate:delegate];
  
  BOOL wasCalled = [delegate wasCallbackURLStringCalled:@"otherapp://x-callback-url/error?errorMessage=Missing%20parameters%20subject&errorCode=1"];
  STAssertTrue(wasCalled, @"Expected callback not called");
}

- (void)testRequiredParametersIsPresent {
  [self performTestForParserWithURLScheme:@"myapp"
                               withAction:@"myAction"
                       requiredParameters:@[@"subject"]
                           shouldBeCalled:YES
                             forURLString:@"myapp://x-callback-url/myAction?text=mytext&subject=mysubject"
                        successParameters:nil
                                 delegate:nil];
}

- (void)testSuccessCallbackWithSourceParameter {
  SBRXCallbackURLParserMockDelegate *delegate = [SBRXCallbackURLParserMockDelegate new];
  
  [self performTestForParserWithURLScheme:@"myapp"
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:YES
                             forURLString:@"myapp://x-callback-url/myAction?x-success=otherapp%3A%2F%2Fx-callback-url%2Fcompleted%3Fname%3Dvalue"
                        successParameters:nil
                                 delegate:delegate];
  
  BOOL wasCalled = [delegate wasCallbackURLStringCalled:@"otherapp://x-callback-url/completed?name=value"];
  STAssertTrue(wasCalled, @"Expected callback not called");
}

- (void)testSuccessCallbackWithoutSourceParameter {
  SBRXCallbackURLParserMockDelegate *delegate = [SBRXCallbackURLParserMockDelegate new];
  
  [self performTestForParserWithURLScheme:@"myapp"
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:YES
                             forURLString:@"myapp://x-callback-url/myAction?x-success=otherapp%3A%2F%2Fx-callback-url%2Fcompleted"
                        successParameters:nil
                                 delegate:delegate];
  
  BOOL wasCalled = [delegate wasCallbackURLStringCalled:@"otherapp://x-callback-url/completed"];
  STAssertTrue(wasCalled, @"Expected callback not called");
}

- (void)testSuccessCallbackWithSuccessParameters {
  SBRXCallbackURLParserMockDelegate *delegate = [SBRXCallbackURLParserMockDelegate new];
  
  [self performTestForParserWithURLScheme:@"myapp"
                               withAction:@"myAction"
                       requiredParameters:nil
                           shouldBeCalled:YES
                             forURLString:@"myapp://x-callback-url/myAction?x-success=otherapp%3A%2F%2Fx-callback-url%2Fcompleted"
                        successParameters:@{@"name" : @"value"}
                                 delegate:delegate];
  
  BOOL wasCalled = [delegate wasCallbackURLStringCalled:@"otherapp://x-callback-url/completed?name=value"];
  STAssertTrue(wasCalled, @"Expected callback not called");
}

#pragma mark - Helpers

- (void)performTestForParserWithURLScheme:(NSString *)URLScheme
                               withAction:(NSString *)action
                       requiredParameters:(NSArray *)requiredParameters
                           shouldBeCalled:(BOOL)shouldBeCalled
                             forURLString:(NSString *)URLString
                        successParameters:(NSDictionary *)successParameters
                                 delegate:(id<SBRXCallbackURLParserDelegate>)delegate {
  SBRXCallbackURLParser *parser = [SBRXCallbackURLParser parserWithURLScheme:URLScheme];
  parser.delegate = delegate;
  
  __block BOOL called = NO;
  [parser addActionWithName:action requiredParameters:requiredParameters handlerBlock:^(NSDictionary *parameters, NSString *sourceApp, SBRXCallbackURLActionCompletionBlock completion) {
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
