# SBRXCallbackURLKit

Simple library that makes it easy to add x-callback-url support to your app.

## Installation

The easiest way is to use CocoaPods. Add the following to your Podfile.

	pod 'SBRXCallbackURLKit'

Then run the `pod install` command.

To manually install it, just copy the files in the subfolder SBRXCallbackURLKit to your Xcode project.

## Usage

You can use SBRXCallbackURLKit to parse incoming x-callback-url actions, trigger actions in other apps, or use both in combination, allowing for two way interactions within apps.

### Parse incoming actions

To support a new action in your app, you need to handle incoming URLs. For this you need an instance of SBRXCallbackParser. The easiest way is to use the shared instance of provided by its `sharedParser` method. If you use it this way, make sure to set your app's URL scheme in `application:didFinishLaunchingWithOptions:`:

	SBRCallbackParser *parser = [SBRCallbackParser sharedParser];
	[parser setURLScheme:@"myapp"];
	
	[parser addHandlerForActionName:@"myAction" handlerBlock:^BOOL(NSDictionary *parameters, NSString *source, SBRCallbackActionHandlerCompletionBlock completion) {
		NSLog(@"Action triggered with parameters: %@", parameters);

		// For two-way app communication, When you are ready to trigger the 
		// callbacks provided by the external app, call the completion 
		// block provided. This happens asynchronously for your to determine
		// when you are ready to make the callback. This callback can be omitted
		// if the action is not a two-way type action.
		completion(nil, nil, NO);
		
		// YES let's the parser know the action was handled, otherwise return NO
		return YES;
	}];

Then, in `application:openURL:sourceApplication:`, go ahead and use the parser to handle the incoming URLs.

	[[SBRXCallbackParser sharedParser] handleURL:url];
	
You can also choose to instantiate the parser in `application:openURL:sourceApplication:` and add the action handlers there. The advantage of using the shared parser is more evident when doing two-way communication using actions described in the next section.

### Trigger actions in other apps

It's really easy to trigger an action in another app:

	SBRCallbackAction *action = [SBRCallbackAction actionWithURLScheme:@"otherapp" name:@"otherAction" parameters:@{@"text": @"Some text"}];
	[action trigger];
	
To allow the other app to re-open your app when the action was successful, failed or cancelled you can easily register callbacks handlers with the shared parser described in the previous section:

	SBRCallbackParser *parser = [SBRCallbackParser sharedParser];
	[action registerWithParser:parser successBlock:^(NSDictionary *parameters) {
		NSLog(@"Action successful in the other app");
	} failureBlock:^(NSError *error) {
		NSLog(@"Action failed in the other app");
	} cancelBlock:^{
		NSLog(@"Action cancelled the in other app");
	}];

This will add the appropriate action handlers to the parser and execute them when `handleURL:` is called.