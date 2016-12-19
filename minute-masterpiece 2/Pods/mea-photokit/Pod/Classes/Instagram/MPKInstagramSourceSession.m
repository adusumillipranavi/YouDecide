//
//  MPKInstagramSourceSession.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/7/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MEAPhotoKit.h"
#import "MPKInstagram.h"
#import "MPKHttpClient.h"

#import <Instagram.h>

NSString * const kInstagramAccessToken = @"com.meamobile.meaphotokit.instagram.access_token";
NSString * const kInstagramUsername = @"com.meamobile.meaphotokit.instagram.username";

@interface MPKInstagramSourceSession()

@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *redirectUri;

@end

@implementation MPKInstagramSourceSession

-(instancetype)init
{
	self = [super init];
	
	if (self)
	{
		self.sourceTitle = @"Instagram";
		self.sourceImage = [MEAPhotoKit imageNamed:@"instagram.png" fromBundle:@"mea-photokit-Instagram"];
		
		self.clientId = self.sourceKeysDictionary[@"MPKInstagramClientId"];
		self.secret = self.sourceKeysDictionary[@"MPKInstagramSecret"];
		self.redirectUri = self.sourceKeysDictionary[@"MPKInstagramRedirectUri"];
		
		self.instagram = [[Instagram alloc] initWithClientId:self.clientId delegate:nil];
		[self.instagram setAccessToken:[[NSUserDefaults standardUserDefaults] stringForKey:kInstagramAccessToken]];
		
		self.displayName = [[NSUserDefaults standardUserDefaults] stringForKey:kInstagramUsername];
	}
	
	return self;
}

-(BOOL)isSessionActive
{
	return [self.instagram isSessionValid];
}

-(void)activateSourceSessionWithCompletionHandler:(MPKSourceSessionActivationCompletionHandler)completionHandler
{
	[super activateSourceSessionWithCompletionHandler:completionHandler];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   self.clientId, @"client_id",
									   @"code", @"response_type",
									   self.redirectUri, @"redirect_uri",
									   nil];
	
	NSString *loginDialogUrl = @"https://api.instagram.com/oauth/authorize";
	NSString *seralized = [IGRequest serializeURL:loginDialogUrl params:parameters];
	NSURL *url = [NSURL URLWithString:seralized];
	
	[[MEAPhotoKit authorizer] authorizeSource:self withUrl:url andCompletion:^(NSError *error, id result)
	 {
		 if (error) {
			 //Check if there is an error URL
			 if(error.userInfo[NSURLErrorFailingURLErrorKey]){
				 NSURL *errorURL = error.userInfo[NSURLErrorFailingURLErrorKey];
				 
				 //If the error url starts with "ig" or code is 401 (user cancelled) ignore it, otherwise raise error
				 if(![self attemptToExtractAndPostInstagramCode:errorURL] &&
					![[errorURL.scheme substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"ig"]
					&& error.code!=401){
					 completionHandler(NO, error);
				 }
				 
			 }else if (error.code!=401){
				 //Ignore code 401 = user cancelled (no need to display error)
				 completionHandler(NO, error);
			 }
		 }
		 
		 if ([result isKindOfClass:[NSURL class]]) {
			 [self attemptToExtractAndPostInstagramCode:result];
		 }
	 }];
	
}

-(void)endSessionWithCompletionHandler:(void (^)())completionHandler
{
	[self.instagram logout];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kInstagramAccessToken];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kInstagramUsername];
	
	[super endSessionWithCompletionHandler:completionHandler];
}

- (BOOL)attemptToExtractAndPostInstagramCode:(NSURL *)url {
	NSArray *items = [[NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO] queryItems];
	for (NSURLQueryItem *item in items) {
		if ([item.name isEqualToString:@"code"]) {
			[self postInstagramCodeForVerificationToken:item.value];
			return true;
		}
	}
	return false;
}

-(void)postInstagramCodeForVerificationToken:(NSString *)code
{
	NSDictionary *params = @{
							 @"client_id" : self.clientId,
							 @"client_secret" : self.secret,
							 @"grant_type" : @"authorization_code",
							 @"redirect_uri" : self.redirectUri,
							 @"code" : code,
							 };
	
	MPKHttpClient *client = [[MPKHttpClient alloc] init];
	
	[client postFormData:@"https://api.instagram.com/oauth/access_token" parameters:params completion:^(NSURLResponse *response, id responseObject, NSError *error) {
		if (self.activationCompletionHandler) {
			if (error) {
				NSLog(@"Error: %@", error);
				return self.activationCompletionHandler(NO, error);
			}
			
			NSLog(@"%@ %@", response, responseObject);
			self.displayName = responseObject[@"user"][@"username"];
			[[NSUserDefaults standardUserDefaults] setObject:self.displayName forKey:kInstagramUsername];
			
			[self.instagram setAccessToken:responseObject[@"access_token"]];
			[[NSUserDefaults standardUserDefaults] setObject:self.instagram.accessToken forKey:kInstagramAccessToken];
			self.activationCompletionHandler(YES, nil);
		}
	}];
}

+(BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication{
	if([[url.scheme substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"ig"]){
		NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] init];
		for (NSString *param in [url.query componentsSeparatedByString:@"&"]) {
			NSArray *elts = [param componentsSeparatedByString:@"="];
			if([elts count] < 2) continue;
			[queryParams setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
		}
		
		if([[MEAPhotoKit rootCollection] firstCollectionOfType:MPKCollectionTypeInstagram]){
			[(MPKInstagramSourceSession *)((id)[[MEAPhotoKit rootCollection] firstCollectionOfType:MPKCollectionTypeInstagram].sourceSession) postInstagramCodeForVerificationToken:queryParams[@"code"]];
		} else{
			return NO;
		}
		
		return YES;
	}
	return NO;
}



@end
