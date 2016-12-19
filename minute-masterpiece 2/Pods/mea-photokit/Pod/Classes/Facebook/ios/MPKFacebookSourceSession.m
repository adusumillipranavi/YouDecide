//
//  MPKFacebookSourceSession.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/8/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKFacebookSourceSession.h"
#import "MEAPhotoKit.h"

#import "FBSDKCoreKit.h"
#import "FBSDKLoginKit.h"

NSString * const kFacebookName = @"com.meamobile.meaphotokit.facebook.name";
NSString * const kFacebookEmail = @"com.meamobile.meaphotokit.facebook.email";

@interface MPKFacebookSourceSession()

@property (nonatomic, strong) NSString *appId;

@end

@implementation MPKFacebookSourceSession


+ (NSDictionary *)FBErrorCodeDescription:(NSError*) error
{
	return nil;
//	NSMutableDictionary *errorDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Error", @"title", error.localizedDescription, @"message", nil];
//	switch(error.code){
//		case FBErrorInvalid :{
//			[errorDict setValue:@"FBErrorInvalid" forKey:@"title"];
//			[errorDict setValue:error.localizedDescription forKey:@"message"];
//			return errorDict;
//		}
//		case FBErrorOperationCancelled:{
//			[errorDict setValue:@"Cancelled Login" forKey:@"title"];
//			[errorDict setValue:@"Please login to Facebook to print your Facebook photos" forKey:@"message"];
//			return errorDict;
//		}
//		case FBErrorLoginFailedOrCancelled:{
//			
//			NSDictionary *userData = [error userInfo];
//			NSString *reason = userData[@"com.facebook.sdk:ErrorLoginFailedReason"];
//			if ([reason isEqualToString:@"com.facebook.sdk:UserLoginCancelled"])
//			{
//				return nil;
//			}
//			
//			[errorDict setValue:@"Login Failed" forKey:@"title"];
//			[errorDict setValue:@"Please try logging into Facebook again. Additionally, please check that you have allowed Printicular permission to access your Facebook photos (Settings>Privacy>Facebook)" forKey:@"message"];
//			return errorDict;
//		}
//		case FBErrorRequestConnectionApi:{
//			[errorDict setValue:@"Error" forKey:@"title"];
//			[errorDict setValue:@"There was an error logging into Facebook. Please try again later (FBErrorRequestConnectionApi)" forKey:@"message"];
//			return errorDict;
//		}case FBErrorProtocolMismatch:{
//			[errorDict setValue:@"Error" forKey:@"title"];
//			[errorDict setValue:@"There was an error logging into Facebook. Please try again later (FBErrorProtocolMismatch)" forKey:@"message"];
//			return errorDict;
//		}
//		case FBErrorHTTPError:{
//			[errorDict setValue:@"Error" forKey:@"title"];
//			[errorDict setValue:@"There was an error logging into Facebook. Please try again later (FBErrorHTTPError)" forKey:@"message"];
//			return errorDict;
//		}
//		case FBErrorNonTextMimeTypeReturned:{
//			[errorDict setValue:@"Error" forKey:@"title"];
//			[errorDict setValue:@"There was an error logging into Facebook. Please try again later (FBErrorNonTextMimeTypeReturned)" forKey:@"message"];
//			return errorDict;
//		}
//		default:
//			[errorDict setValue:@"Error" forKey:@"title"];
//			[errorDict setValue:@"An unknown error occured. Please try again later" forKey:@"message"];
//			return errorDict;
//	}
}


-(instancetype)init
{
	self = [super init];
	
	if (self)
	{
		self.sourceTitle = @"Facebook";
		self.sourceImage = [MEAPhotoKit imageNamed:@"facebook.png" fromBundle:@"mea-photokit-Facebook"];
		
		self.appId = self.sourceKeysDictionary[@"MPKFacebookAppId"];
		
        if (self.isSessionActive)
        {
            [self getFacebookUserInfoWithCompletion:^(BOOL activated, NSError *error) {
                if (error) {
                    [self endSessionWithCompletionHandler:nil];
                }
            }];
        }
	}
	
	return self;
}

-(BOOL)isSessionActive
{
	return [FBSDKAccessToken currentAccessToken];
}

-(void)getFacebookUserInfoWithCompletion:(MPKSourceSessionActivationCompletionHandler)completion
{
	[[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,name,email" parameters:nil]
	 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
		 if (!error)
		 {
			 self.displayName = result[@"name"];
             self.displayEmail = result[@"email"];
			 [[NSUserDefaults standardUserDefaults] setObject:self.displayName forKey:kFacebookName];
             [[NSUserDefaults standardUserDefaults] setObject:self.displayEmail forKey:kFacebookEmail];
			 completion(YES,nil);
		 }
		 else
		 {
			 NSLog(@"Facebook: Failed to get User info\nError = %@", error);
			 completion(NO,error);
		 }
  }];
	
}

-(void)activateSourceSessionWithCompletionHandler:(MPKSourceSessionActivationCompletionHandler)completionHandler
{
	[super activateSourceSessionWithCompletionHandler:completionHandler];
	
	FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
	[login logInWithReadPermissions:self.sourceKeysDictionary[@"MPKFacebookPermissions"] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
		if(error)
		{
            completionHandler(NO,error);
		}
		else if(result.isCancelled)
		{
			NSLog(@"login was cancelled");
		}
		else
		{
            [self getFacebookUserInfoWithCompletion:^(BOOL activated, NSError *error) {
                if (error) {
                    [self endSessionWithCompletionHandler:nil];
					completionHandler(NO,error);
                }
				else
				{
					completionHandler(YES,nil);
				}
            }];
		}
	}];
//	
//	FBSDKDeviceLoginViewController *controller = [[FBSDKDeviceLoginViewController alloc] init];
//	controller.readPermissions = self.sourceKeysDictionary[@"MPKFacebookPermissions"];
//	controller.delegate = self;
//	
//	UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
//	UIViewController *vc = ([window.rootViewController presentedViewController] ?: window.rootViewController);
//	[vc presentViewController:controller animated:YES completion:nil];
}

-(void)endSessionWithCompletionHandler:(void (^)())completionHandler
{
	[FBSDKAccessToken setCurrentAccessToken:nil];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kFacebookName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFacebookEmail];
    self.displayEmail = nil;
    
	[super endSessionWithCompletionHandler:completionHandler];
}




/*
 |--------------------------------------------------------------------------
 | FBSDKDeviceLoginViewControllerDelegate
 |--------------------------------------------------------------------------
 */
#pragma mark - FBSDKDeviceLoginViewControllerDelegate

//
//- (void)deviceLoginViewControllerDidCancel:(FBSDKDeviceLoginViewController *)viewController
//{
//	NSLog(@"MPKFacebook Login Cancelled");
//}
//
//- (void)deviceLoginViewControllerDidFinish:(FBSDKDeviceLoginViewController *)viewController
//{
//	if (self.activationCompletionHandler)
//	{
//		self.activationCompletionHandler(YES, nil);
//	}
//}
//
//- (void)deviceLoginViewControllerDidFail:(FBSDKDeviceLoginViewController *)viewController error:(NSError *)error
//{
//	if (self.activationCompletionHandler)
//	{
//		self.activationCompletionHandler(NO, error);
//	}
//}



/*
 |--------------------------------------------------------------------------
 | AppDelegate Passthrough
 |--------------------------------------------------------------------------
 */
#pragma mark - AppDelegate Passthrough

+(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[FBSDKApplicationDelegate sharedInstance] application:application
							 didFinishLaunchingWithOptions:launchOptions];
	return YES;
}


+(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	return [[FBSDKApplicationDelegate sharedInstance] application:application
														  openURL:url
												sourceApplication:sourceApplication
													   annotation:annotation
			];
}

+(BOOL)handleApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	return  [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}


@end
