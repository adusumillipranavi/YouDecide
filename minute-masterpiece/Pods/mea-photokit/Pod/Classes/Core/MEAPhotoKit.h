//
//  MEAPhotoKit.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/6/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#ifndef _MEAPHOTOKIT_
	#define _MEAPHOTOKIT_


#endif /* _MEAPHOTOKIT_ */

#import <UIKit/UIKit.h>

typedef NSUInteger MPKCollectionType;

@class MPKCollection;
@protocol MPKAuthorizationProtocol;
@protocol MPKActivityIndicatorProtocol;

@interface MEAPhotoKit : NSObject

/**
 *  Sets up what sources will be available to the app
 *
 *  @param sources    A Bitmasked integer of the sources you want
 *  @param sourceKeys A dictionary containing the required information for your selected sources
 */
+(void)setupPhotoKitWithSources:(MPKCollectionType)sources andSourceKeys:(NSDictionary *)sourceKeys;



/**
 *  Sets what file extensions will be loaded from sources, defaults to JPG
 *
 *  @param extensions NSArray
 */
+(void)setAllowedExtensions:(NSArray *)extensions;
+(NSArray *)allowedExtensions;

+(void)setTintColor:(UIColor *)color;
+(UIColor *)tintColor;

+(void)setPhotoSourcePriority:(NSArray *)priorites;
+(NSArray *)photoSourcePriorities;

+(void)setAuthorizer:(id<MPKAuthorizationProtocol>)authorizer;
+(id<MPKAuthorizationProtocol>)authorizer;

+(void)setBlockingActivityIndicator:(id<MPKActivityIndicatorProtocol>)blockingActivityIndicator;
+(id<MPKActivityIndicatorProtocol>)blockingActivityIndicator;

+(NSBundle *)photoKitBundleIdentifier:(NSString *)identifier;
+(NSDictionary *)sourceKeys;
+(void)saveSourceKey:(NSDictionary *)sourceKeys;
+(UIImage *)imageNamed:(NSString *)imageName fromBundle:(NSString *)bundleName;
+(UIViewController *)rootViewController;
+(MPKCollectionType)activeSources;
+(MPKCollection *)rootCollection;


+(BOOL)handleApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
+(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end