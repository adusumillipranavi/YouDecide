//
//  MPKFlickrSourceSession.m
//  Pods
//
//  Created by Daniel Loomb on 1/16/15.
//
//

#import "MPKFlickrSourceSession.h"

#import "MPKCore.h"
#import "MPKUserInterface.h"


#import "ObjectiveFlickr.h"

NSString* const kSavedFlickrKey = @"com.meamobile.photokit.flickr.saved_api_key";
NSString* const kFlickrHandledUrl = @"com.meamobile.photokit.flickr.handled_url_notification";

//Session Data
NSString* const kFlickrSessionTokenKey = @"com.meamobile.photokit.flickr.session_token";
NSString* const kFlickrSessionSecretKey = @"com.meamobile.photokit.flickr.session_secret";
NSString* const kFlickrSessionUserNameKey = @"com.meamobile.photokit.flickr.session_username";
NSString* const kFlickrSessionFullNameKey = @"com.meamobile.photokit.flickr.session_fullname";
NSString* const kFlickrSessionNSIDKey = @"com.meamobile.photokit.flickr.session_nsid";


@interface MPKFlickrSourceSession() <OFFlickrAPIRequestDelegate>

@property (nonatomic, strong) MPKLoginViewController *loginViewController;
@property (nonatomic, strong) OFFlickrAPIRequest *flickrAuthRequest;

@end

@implementation MPKFlickrSourceSession


+(BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedFlickrKey];
	NSString *callbackUrl = [NSString stringWithFormat:@"fk%@://auth", apiKey];
	if (![[url absoluteString] hasPrefix:callbackUrl]) {
		return NO;
	}
	NSString *token = nil;
	NSString *verifier = nil;
	BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:callbackUrl], &token, &verifier);
	
	if (!result) {
		NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
		return NO;
	}
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kFlickrHandledUrl object:@{@"token":token, @"verifier": verifier}];
	
	return YES;
}




#pragma mark - LifeCycle

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.sourceTitle = @"Flickr";
		self.sourceImage = [MEAPhotoKit imageNamed:@"flickr.png" fromBundle:@"mea-photokit-Flickr"];
		
		self.apiKey = self.sourceKeysDictionary[@"MPKFlickrAPIKey"];
		self.apiSecret = self.sourceKeysDictionary[@"MPKFlickrSecret"];
		[[NSUserDefaults standardUserDefaults] setObject:self.apiKey forKey:kSavedFlickrKey];
		
		self.flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:self.apiKey sharedSecret:self.apiSecret];
		[self restoreSession];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flickrHandledUrlNotification:) name:kFlickrHandledUrl object:nil];
	}
	return self;
}

-(BOOL)isSessionActive
{
	return self.flickrContext.OAuthToken.length != 0;
}

-(NSString *)displayName
{
	return self.userName;
}

-(void)restoreSession
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	self.userName = [userDefaults objectForKey:kFlickrSessionUserNameKey];
	self.fullName = [userDefaults objectForKey:kFlickrSessionFullNameKey];
	self.NSID = [userDefaults objectForKey:kFlickrSessionNSIDKey];
	NSString *sessionToken = [userDefaults objectForKey:kFlickrSessionTokenKey];
	NSString *sessionSecret = [userDefaults objectForKey:kFlickrSessionSecretKey];
	
	if (sessionSecret && sessionToken)
	{
		self.flickrContext.OAuthToken = sessionToken;
		self.flickrContext.OAuthTokenSecret = sessionSecret;
	}
}

#pragma mark - Login

-(void)activateSourceSessionWithCompletionHandler:(MPKSourceSessionActivationCompletionHandler)completionHandler
{
	[super activateSourceSessionWithCompletionHandler:completionHandler];
	
	NSString *callbackUrl = [NSString stringWithFormat:@"fk%@://auth", self.apiKey];
	
	self.flickrAuthRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
	self.flickrAuthRequest.delegate = self;
	self.flickrAuthRequest.requestTimeoutInterval = 60.0;
	[self.flickrAuthRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:callbackUrl]];
}

-(void)endSessionWithCompletionHandler:(void (^)())completionHandler
{
	self.flickrContext.OAuthToken = nil;
	self.flickrContext.OAuthTokenSecret = nil;
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kFlickrSessionUserNameKey];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kFlickrSessionFullNameKey];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kFlickrSessionNSIDKey];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kFlickrSessionTokenKey];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kFlickrSessionSecretKey];
	
	[super endSessionWithCompletionHandler:completionHandler];
}

-(void)loginToFlickrWithRequestURL:(NSURL *)url
{
	UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
	UIViewController *vc = ([window.rootViewController presentedViewController] ?: window.rootViewController);
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[MEAPhotoKit photoKitBundleIdentifier:@"mea-photokit-UserInterface"]];
	UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"MPKLoginViewControllerStoryboardIdentifier"];
	navController.navigationBar.topItem.rightBarButtonItem.tintColor = [MEAPhotoKit tintColor];
	self.loginViewController = [navController.viewControllers firstObject];
	self.loginViewController.title = self.sourceTitle;
	
	[vc presentViewController:navController animated:YES completion:^{
		
		[self.loginViewController loadUrl:url completionHandler:^(NSError *error, NSURL *url) {
			if (error)
			{
				self.flickrContext.OAuthTokenSecret = nil;
				self.flickrContext.OAuthToken = nil;
			}
		}];
	}];

}


-(void)flickrHandledUrlNotification:(NSNotification *)notification
{
	NSDictionary *dict = notification.object;
	NSString *token = dict[@"token"];
	NSString *verifier = dict[@"verifier"];
	
	if (token && verifier)
	{
		self.flickrAuthRequest.sessionInfo = @"kGetAccessTokenStep";
		[self.flickrAuthRequest fetchOAuthAccessTokenWithRequestToken:token verifier:verifier];
	}
}


-(void)saveAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setObject:inAccessToken forKey:kFlickrSessionTokenKey];
	[userDefaults setObject:inSecret forKey:kFlickrSessionSecretKey];
	[userDefaults setObject:inUserName forKey:kFlickrSessionUserNameKey];
	[userDefaults setObject:inFullName forKey:kFlickrSessionFullNameKey];
	[userDefaults setObject:inNSID forKey:kFlickrSessionNSIDKey];
	[userDefaults synchronize];
	
	self.userName = inUserName;
	self.fullName = inFullName;
	self.NSID = inNSID;
	
	self.flickrContext.OAuthTokenSecret = inSecret;
	self.flickrContext.OAuthToken = inAccessToken;
}


#pragma mark - Flickr Request Delegate

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
	self.activationCompletionHandler(false, inError);
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret
{
	self.flickrContext.OAuthToken = inRequestToken;
	self.flickrContext.OAuthTokenSecret = inSecret;
	
	NSURL *flickrAuthUrl = [self.flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrReadPermission];
	[self loginToFlickrWithRequestURL:flickrAuthUrl];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
	[self saveAccessToken:inAccessToken secret:inSecret userFullName:inFullName userName:inUserName userNSID:inNSID];
	[self.loginViewController.navigationController dismissViewControllerAnimated:YES completion:^{
		self.activationCompletionHandler(YES, nil);
	}];
}


@end
