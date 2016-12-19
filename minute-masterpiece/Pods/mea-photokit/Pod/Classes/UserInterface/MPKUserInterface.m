//
//  MPKUserInterface.m
//  Pods
//
//  Created by Daniel on 20/11/15.
//
//

#import "MPKUserInterface.h"

//#import "MBProgressHUD.h"
#import "MPKCore.h"

@interface MPKUserInterface() <MPKAuthorizationProtocol>

//@property (strong, nonatomic) MBProgressHUD *blockingActivityIndicator;

@end

@implementation MPKUserInterface

+ (MPKUserInterface *)sharedInstance
{
	static MPKUserInterface *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

-(void)setNonIntrusiveActivityIndicatorVisible:(BOOL)visible
{
	if (self.nonIntrusiveActivityIndicator)
	{
		visible ? [self.nonIntrusiveActivityIndicator show] : [self.nonIntrusiveActivityIndicator hide];
		return;
	}
	
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(setNetworkActivityIndicatorVisible:)]) {
		UIApplication* application = [UIApplication sharedApplication];
		
		NSMethodSignature* signature = [[application class] instanceMethodSignatureForSelector: @selector( setNetworkActivityIndicatorVisible: )];
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: signature];
		[invocation setTarget: application];
		[invocation setSelector: @selector( setNetworkActivityIndicatorVisible: ) ];
		[invocation setArgument: &visible atIndex: 2];
		[invocation invoke];
	}
	
}


-(void)setBlockingActivityIndicatorVisible:(BOOL)visible
{
	if (self.blockingActivityIndicator)
	{
		visible ? [self.blockingActivityIndicator show] : [self.blockingActivityIndicator hide];
		return;
	}
	
//	if (visible) {
//		UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
//		UIViewController *vc = ([window.rootViewController presentedViewController] ?: window.rootViewController);
//		
//		self.blockingActivityIndicator = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
//		self.blockingActivityIndicator.labelText = @"Loading";
//	}
//	else if(self.blockingActivityIndicator) {
//		[self.blockingActivityIndicator hide:YES];
//		self.blockingActivityIndicator = nil;
//	}
	
}


/*
 |--------------------------------------------------------------------------
 | MPKAuthorizationProtocol
 |--------------------------------------------------------------------------
 */
#pragma mark - MPKAuthorizationProtocol


-(id<MPKAuthorizationProtocol>)defaultAuthorizer
{
	return self;
}

-(void)authorizeSource:(MPKSourceSession *)source withUrl:(NSURL *)url andCompletion:(void (^)(NSError *error, id result))completion
{
	UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
	UIViewController *vc = ([window.rootViewController presentedViewController] ?: window.rootViewController);
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[MEAPhotoKit photoKitBundleIdentifier:@"mea-photokit-UserInterface"]];
	UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"MPKLoginViewControllerStoryboardIdentifier"];
	navController.navigationBar.topItem.rightBarButtonItem.tintColor = [MEAPhotoKit tintColor];
	
	MPKLoginViewController *loginViewController = [navController.viewControllers firstObject];
	
	loginViewController.title = @"Login";
	
	[vc presentViewController:navController animated:YES completion:^{
		
		[loginViewController loadUrl:url completionHandler:^(NSError *error, NSURL *url) {
			completion(error, url);
		}];
	}];
}


@end