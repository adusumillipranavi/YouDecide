//
//  MPKLocalSourceSession.m
//  Pods
//
//  Created by Daniel Loomb on 2/13/15.
//
//

#import "MEAPhotoKit.h"
#import "MPKLocal.h"


#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MPKLocalSourceSession()

@end

@implementation MPKLocalSourceSession

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.sourceTitle = @"Local Photos";
		self.sourceImage = [MEAPhotoKit imageNamed:@"localphotos.png" fromBundle:@"mea-photokit-Local"];
	}
	return self;
}

-(BOOL)isSessionActive
{
	return NO;
}

-(void)activateSourceSessionWithCompletionHandler:(MPKSourceSessionActivationCompletionHandler)completionHandler
{
	if ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1))
	{
		[self requestPhotosAccessWithCompletionHandler:completionHandler];
	}
	else
	{
		[self requestAssetLibraryAccessWithCompletionHandler:completionHandler];
	}

}


-(NSError *)unauthroizedError
{
	return [NSError errorWithDomain:@"com.meamobile.errors"
							   code:301
						   userInfo:@{
									  NSLocalizedFailureReasonErrorKey : @"You must enable access to your photos. Please go to Settings > Privacy > Photos and enable this app.",
 									  NSLocalizedDescriptionKey : @"Photo Access Denied"
									  }];
}


/*
 |--------------------------------------------------------------------------
 | Access Requesting
 |--------------------------------------------------------------------------
 */
#pragma mark - Access Requesting


-(void)requestPhotosAccessWithCompletionHandler:(MPKSourceSessionActivationCompletionHandler)completionHandler
{
	[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if (status == PHAuthorizationStatusAuthorized)
			{
				completionHandler(YES, nil);
			}
			else
			{
				completionHandler(NO, [self unauthroizedError]);
			}
		});
	}];
}



-(void)requestAssetLibraryAccessWithCompletionHandler:(MPKSourceSessionActivationCompletionHandler)completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		
		//Loop until the user makes a decision
		while ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {}
		[self assetsLibraryAuthorizationWithCompletionHandler:completionHandler];
		
	});
	
	ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
	[lib assetForURL:[NSURL URLWithString:@""] resultBlock:nil failureBlock:nil];
}

-(void)assetsLibraryAuthorizationWithCompletionHandler:(MPKSourceSessionActivationCompletionHandler)completionHandler
{
	ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (status == ALAuthorizationStatusAuthorized)
		{
			completionHandler(YES, nil);
		}
		else
		{
			completionHandler(NO, [self unauthroizedError]);
		}
	});
}




@end
