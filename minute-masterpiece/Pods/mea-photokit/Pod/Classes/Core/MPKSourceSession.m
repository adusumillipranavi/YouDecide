//
//  MPKSourceSession.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/7/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKSourceSession.h"
#import "MEAPhotoKit.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation MPKSourceSession

//+(BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
//{
//	return [[FBSDKApplicationDelegate sharedInstance] application:application
//														  openURL:url
//												sourceApplication:sourceApplication
//													   annotation:annotation
//			];}

+(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	return NO;
}

-(void)dealloc
{
	self.activationCompletionHandler = nil;
	NSLog(@"%@ dealloc", [self class]);
}

-(NSDictionary *)sourceKeysDictionary
{
	NSDictionary *keysDict = [MEAPhotoKit sourceKeys];
	
	return keysDict[NSStringFromClass([self class])];
}

-(BOOL)isSessionActive
{
	return NO;
}

-(void)activateSourceSessionWithCompletionHandler:(MPKSourceSessionActivationCompletionHandler)completionHandler
{
	self.activationCompletionHandler = completionHandler;
}

-(void)endSessionWithCompletionHandler:(void (^)())completionHandler
{
	self.displayName = nil;
	if (completionHandler)
	{
		completionHandler();
	}
}

@end
