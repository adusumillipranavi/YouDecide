//
//  MPKLocalCachingModule.h
//  Pods
//
//  Created by Daniel Loomb on 2/10/15.
//
//

#import <Foundation/Foundation.h>

@class MPKAsset;

@interface MPKLocalCachingModule : NSObject

-(void)requestThumbnailForAsset:(MPKAsset *)asset resultHandler:(void (^)(UIImage *result))resultHandler;

-(void)requestFullImageForAsset:(MPKAsset *)asset resultHandler:(void (^)(UIImage *result))resultHandler;

-(void)requestBytesizeForAsset:(MPKAsset *)asset resultHandler:(void (^)(int64_t))resultHandler;

@end
