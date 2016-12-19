//
//  MEAPhotoKit.m
//  Pods
//
//  Created by Daniel Loomb on 1/15/15.
//
//

#import "MEAPhotoKit.h"

#ifdef Pods_MPKFacebook_h
#import "MPKFacebook.h"
#endif

#ifdef Pods_MPKDropbox_h
#import "MPKDropbox.h"
#endif

#ifdef Pods_MPKFlickr_h
#import "MPKFlickr.h"
#endif

#ifdef Pods_MPKAmazon_h
#import "MPKAmazon.h"
#endif

NSString* const kSavedSourceKeysKey = @"com.meamobile.photokit.sourcekeys";
NSString* const kAllowedFileExtensionsKey = @"com.meamobile.photokit.file_extensions";
NSString* const kTintColor = @"com.meamobile.photokit.tint_color";
NSString* const kPrioritizedSources = @"com.meamobile.photokit.prioritized_sources";


@implementation MEAPhotoKit

static MPKCollectionType activeSources = 0;
static id<MPKAuthorizationProtocol> _authorizer;

+(void)setupPhotoKitWithSources:(MPKCollectionType)sources andSourceKeys:(NSDictionary *)sourceKeys
{
	[MEAPhotoKit saveSourceKey:sourceKeys];
	activeSources = sources;
}


+(void)setAllowedExtensions:(NSArray *)extensions
{
	[[NSUserDefaults standardUserDefaults] setObject:extensions forKey:kAllowedFileExtensionsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSArray *)allowedExtensions
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:kAllowedFileExtensionsKey] ?: @[@"jpeg", @"jpg"];
}


+(void)setTintColor:(UIColor *)color
{
	NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
	[[NSUserDefaults standardUserDefaults] setObject:colorData forKey:kTintColor];
}

+(UIColor *)tintColor
{
	NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:kTintColor];
	return [NSKeyedUnarchiver unarchiveObjectWithData:colorData] ?: [UIColor darkGrayColor];
}

+(void)setPhotoSourcePriority:(NSArray *)priorites
{
	[[NSUserDefaults standardUserDefaults] setObject:priorites forKey:kPrioritizedSources];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSArray *)photoSourcePriorities
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:kPrioritizedSources] ?: @[];
}


+(void)setAuthorizer:(id<MPKAuthorizationProtocol>)authorizer
{
	_authorizer = authorizer;
}

+(id<MPKAuthorizationProtocol>)authorizer
{
	if (_authorizer) {
		return _authorizer;
	}
	
#ifdef Pods_MPKUserInterface_h
	return [[MPKUserInterface sharedInstance] defaultAuthorizer];
#else
	[[NSException exceptionWithName:@"No Authorizer Set" reason:@"You must set an object that implements the MPKAuthorizationProtocol or add the MEAPhotokit/UserInterface subpod to use the default" userInfo:@{}] raise];
#endif
	
	return nil;
}

+(NSBundle *)photoKitBundleIdentifier:(NSString *)identifier
{
	return [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:identifier ofType:@"bundle"]];
}

+(NSDictionary *)sourceKeys
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:kSavedSourceKeysKey];
}

+(void)saveSourceKey:(NSDictionary *)sourceKeys
{
	[[NSUserDefaults standardUserDefaults] setObject:sourceKeys forKey:kSavedSourceKeysKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}



+(UIImage *)imageNamed:(NSString *)imageName fromBundle:(NSString *)bundleName
{
	NSString *imageIdentifier = [NSString stringWithFormat:@"%@/%@", [[self photoKitBundleIdentifier:bundleName] bundlePath], imageName];
	return [UIImage imageNamed:imageIdentifier];
}


+(UIViewController *)rootViewController
{
#ifndef Pods_MPKUserInterface_h
		[[NSException exceptionWithName:@"MissingUserInterfaceSubpodException" reason:@"You must include the MEAPhotokit/UserInterface subpod to call the rootViewController method." userInfo:@{}] raise];
#endif
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[MEAPhotoKit photoKitBundleIdentifier:@"mea-photokit-UserInterface"]];
	return storyboard.instantiateInitialViewController;
}

+(MPKCollectionType)activeSources
{
	return activeSources;
}

+ (MPKCollection *)rootCollection
{
	static MPKCollection *_rootCollection = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_rootCollection = [[MPKCollection alloc] initWithTypes:[MEAPhotoKit activeSources]];
	});
	return _rootCollection;
}




/*
 |--------------------------------------------------------------------------
 | AppDelegate Passthrough
 |--------------------------------------------------------------------------
 */
#pragma mark - AppDelegate Passthrough

+(BOOL)handleApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	BOOL wasHandled = NO;
 
#ifdef Pods_MPKFacebook_h
	if(wasHandled == NO)
	{
		wasHandled = [MPKFacebookSourceSession handleApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation];
	}
#endif
	
#ifdef Pods_MPKDropbox_h
	if (wasHandled == NO) // Dropbox
	{
		wasHandled = [MPKDropboxSourceSession handleOpenURL:url sourceApplication:sourceApplication];
	}
#endif
	
#ifdef Pods_MPKFlickr_h
	if (wasHandled == NO)
	{
		wasHandled = [MPKFlickrSourceSession handleOpenURL:url sourceApplication:sourceApplication];
	}
#endif
	
	
#ifdef Pods_MPKAmazon_h
	if (wasHandled == NO) {
		wasHandled = [MPKAmazonSourceSession handleOpenURL:url sourceApplication:sourceApplication];
	}
#endif
    
#ifdef Pods_MPKInstagram_h
    if (wasHandled == NO){
        wasHandled = [MPKInstagramSourceSession handleOpenURL:url sourceApplication:sourceApplication];
    }
#endif
	
	return wasHandled;
}

+(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	
#ifdef Pods_MPKFacebook_h
	[MPKFacebookSourceSession application:application didFinishLaunchingWithOptions:launchOptions];
#endif
	
	return YES;
}





@end
