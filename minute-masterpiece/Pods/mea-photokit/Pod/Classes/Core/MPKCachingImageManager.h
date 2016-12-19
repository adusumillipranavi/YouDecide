//
//  MPKCachingImageManager.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/6/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MPKAsset;

#define kImageCachePath [NSString stringWithFormat:@"%@cache/", NSTemporaryDirectory()]

@interface MPKCachingImageManager : NSObject

///------------------------------------------------
/// @name Singleton
///------------------------------------------------

+(id)defaultManager;

///---------------------
/// @name Accessing Images
///---------------------

/**
 Finds the assets thumbnail image and returns it,
 
 @param asset The asset that contains the image info/locations
 
 @param resultHandler The block used to pass the image back the the caller
 */
-(void)requestThumbnailForAsset:(MPKAsset *)asset resultHandler:(void (^)(UIImage *result))resultHandler;


/**
 Finds the assets full resolution image and returns it,
 
 @param asset The asset that contains the image info/locations
 
 @param resultHandler The block used to pass the image back the the caller
 */
-(void)requestFullImageForAsset:(MPKAsset *)asset resultHandler:(void (^)(UIImage *result))resultHandler;


-(void)requestBytesizeForAsset:(MPKAsset *)asset resultHandler:(void (^)(int64_t bytesize))resultHandler;

@end
