//
//  MPKSourceSession.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/7/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class UIApplication;

/**
 The block to be used when a source session attempt activation
 
 @param activated A boolean flag on whether the attempt was successful
 @param error An error that will store infomation if the attempt failed
 
 */
typedef void (^MPKSourceSessionActivationCompletionHandler)(BOOL activated, NSError *error);

@interface MPKSourceSession : NSObject

@property (nonatomic, readonly) NSDictionary *sourceKeysDictionary;
@property (nonatomic, strong) NSString *sourceTitle;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic) BOOL isRealoadable;
@property (nonatomic, copy) MPKSourceSessionActivationCompletionHandler activationCompletionHandler;

+(BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
+(BOOL)handleApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
+(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

-(BOOL)isSessionActive;
-(void)activateSourceSessionWithCompletionHandler:(MPKSourceSessionActivationCompletionHandler)completionHandler;


/**
 Ends the current SourceSession.
 
 WARN: if overriden, call [super endSessionWithCompletionHandler:completionHandler] last so the final clean up can take place
 
 @param completionHandler The block to be called once the session has been succesfully ended
 */
-(void)endSessionWithCompletionHandler:(void(^)())completionHandler;

@end
