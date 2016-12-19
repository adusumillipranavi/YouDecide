//
//  MPKUserInterface.h
//  Pods
//
//  Created by Daniel Loomb on 3/23/15.
//
//

#ifndef Pods_MPKUserInterface_h
#define Pods_MPKUserInterface_h

#import "MPKItemExplorerViewController.h"
#import "MPKItemDisplayViewController.h"
#import "MPKAccountsViewController.h"
#import "MPKCollectionCell.h"
#import "MPKAssetCell.h"

#import "MPKLoginViewController.h"

#endif

@protocol MPKAuthorizationProtocol;

@protocol MPKActivityIndicatorProtocol <NSObject>

@property (nonatomic, copy) void (^cancelledHandler)();

-(void)show;
-(void)hide;

@end

@interface MPKUserInterface : NSObject

@property (nonatomic, strong) id<MPKActivityIndicatorProtocol> nonIntrusiveActivityIndicator;
@property (nonatomic, strong) id<MPKActivityIndicatorProtocol> blockingActivityIndicator;

+(MPKUserInterface *)sharedInstance;

-(void)setNonIntrusiveActivityIndicatorVisible:(BOOL)visible;
-(void)setBlockingActivityIndicatorVisible:(BOOL)visible;

-(id<MPKAuthorizationProtocol>)defaultAuthorizer;
-(id<MPKActivityIndicatorProtocol>)defaultBlockingActivityIndicator;

@end
