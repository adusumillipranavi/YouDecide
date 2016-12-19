//
//  MPKCachingImageManager.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/6/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKCore.h"

#import <objc/runtime.h>

#ifdef Pods_MPKLocal_h
#import "MPKLocal.h"
#endif

#ifdef Pods_MPKDropbox_h
#import "MPKDropbox.h"
#endif

#ifdef Pods_MPKSanDisk_h
#import "MPKSanDisk.h"
#endif

@interface MPKCachingImageManager()

@property (strong, nonatomic) id dropboxCachingModule;
@property (strong, nonatomic) id localCachingModule;
@property (strong, nonatomic) id emojiCachingModule;
@property (strong, nonatomic) id sanDiskCachingModule;

@end

@implementation MPKCachingImageManager

/*
 |--------------------------------------------------------------------------
 | Singleton
 |--------------------------------------------------------------------------
 */
#pragma mark - Singleton

+ (id)defaultManager
{
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}


- (instancetype)init
{
	self = [super init];
	if (self)
	{
		[[NSFileManager defaultManager]createDirectoryAtPath:kImageCachePath withIntermediateDirectories:NO attributes:nil error:nil];
	}
	return self;
}


-(void)requestImageFromURL:(NSString *)urlString writeToPath:(NSString *)toPath resultHandler:(void (^)(UIImage *))resultHandler
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:toPath])
	{
		UIImage *image = [UIImage imageWithContentsOfFile:toPath];
		return resultHandler(image);
	}
	
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
		if (data) {
			if([data writeToFile:toPath atomically:NO]) {
				UIImage *image = [UIImage imageWithContentsOfFile:toPath];
				return resultHandler(image);
			}
		}
	});
}


#pragma mark - Thumbnail Request

-(void)requestThumbnailForAsset:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
	switch (asset.type)
	{
		case MPKAssetTypeLocal:
			[self attemptLocalThumbnailRequest:asset resultHandler:resultHandler];
			break;
			
		case MPKAssetTypeRemote:
			// fallthrough
		case MPKAssetTypeDropbox:
			
			if ([(MPKRemoteAsset *)asset thumbnailURLString])
			{
				[self requestImageFromURL:[(MPKRemoteAsset *)asset thumbnailURLString] writeToPath:[NSString stringWithFormat:@"%@thumb_%@", kImageCachePath, asset.assetIdentifier] resultHandler:resultHandler];
			}
			else if (asset.type == MPKAssetTypeDropbox)
			{
				[self attemptDropboxThumbnailRequest:asset resultHandler:resultHandler];
			}

			break;
			
		case MPKAssetTypeVideo:
			break;
			
        case MPKAssetTypeEmoji:
                [self attemptEmojuThumbnailRequest:asset resultHandler:resultHandler];
            break;

		case MPKAssetTypeSanDisk:
			[self attemptSanDiskThumbnailRequest:asset resultHandler:resultHandler];
			break;
	}
}

-(void)attemptEmojuThumbnailRequest:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
#ifdef Pods_MPKEmoji_h
    if(self.emojiCachingModule == nil)
    {
        self.emojiCachingModule = [[MPKEmojiCachingModule alloc] init];
    }
    MPKEmojiCachingModule *module = self.emojiCachingModule;
    [module requestThumbnailForAsset:asset resultHandler:resultHandler];
#endif
}

-(void)attemptLocalThumbnailRequest:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
#ifdef Pods_MPKLocal_h
	if(self.localCachingModule == nil){
		self.localCachingModule = [[MPKLocalCachingModule alloc] init];
	}
	
	MPKLocalCachingModule *module = self.localCachingModule;
	[module requestThumbnailForAsset:asset resultHandler:resultHandler];
#endif
}


-(void)attemptDropboxThumbnailRequest:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
#ifdef Pods_MPKDropbox_h
	
	if (self.dropboxCachingModule == nil) {
		self.dropboxCachingModule = [[MPKDropboxCachingModule alloc] init];
	}
	
	MPKDropboxCachingModule *module = self.dropboxCachingModule;
	[module requestThumbnailForAsset:asset resultHandler:resultHandler];
#endif
}

-(void)attemptSanDiskThumbnailRequest:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
#ifdef Pods_MPKSanDisk_h
	
	if (self.sanDiskCachingModule == nil) {
		self.sanDiskCachingModule = [[MPKSanDiskCachingModule alloc] init];
	}
	
	MPKSanDiskCachingModule *module = self.sanDiskCachingModule;
	[module requestThumbnailForAsset:asset resultHandler:resultHandler];
#endif
}


#pragma mark - Full Image Request

-(void)requestFullImageForAsset:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
	switch (asset.type)
	{
		case MPKAssetTypeLocal:
			[self attemptRequestForLocalFullResolutionImage:asset resultHandler:resultHandler];
			break;
			
		case MPKAssetTypeRemote:
			// fallthrough
		case MPKAssetTypeDropbox:
			[self requestImageFromURL:[(MPKRemoteAsset *)asset fullResolutionURLString] writeToPath:[NSString stringWithFormat:@"%@full_%@", kImageCachePath, asset.assetIdentifier] resultHandler:resultHandler];
			break;
			
		case MPKAssetTypeVideo:
		
		break;
			
        case MPKAssetTypeEmoji:
            [self attemptRequestForEmojiFullResolutionImage:asset resultHandler:resultHandler];
            break;
			
		case MPKAssetTypeSanDisk:
			[self attemptRequestForSanDiskFullResolutionImage:asset resultHandler:resultHandler];
			break;
	}
}

-(void)attemptRequestForEmojiFullResolutionImage:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
#ifdef Pods_MPKEmoji_h
    if(self.emojiCachingModule == nil)
    {
        self.emojiCachingModule = [[MPKEmojiCachingModule alloc] init];
    }
    MPKEmojiCachingModule *module = self.emojiCachingModule;
    [module requestFullImageForAsset:asset resultHandler:resultHandler];
#endif
}

-(void)attemptRequestForLocalFullResolutionImage:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
#ifdef Pods_MPKLocal_h
	if(self.localCachingModule == nil){
		self.localCachingModule = [[MPKLocalCachingModule alloc] init];
	}
	
	MPKLocalCachingModule *module = self.localCachingModule;
	[module requestFullImageForAsset:asset resultHandler:resultHandler];
#endif
}

-(void)attemptRequestForSanDiskFullResolutionImage:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
#ifdef Pods_MPKSanDisk_h
	if(self.sanDiskCachingModule == nil)
	{
		self.sanDiskCachingModule = [[MPKSanDiskCachingModule alloc] init];
	}
	MPKSanDiskCachingModule *module = self.sanDiskCachingModule;
	[module requestFullImageForAsset:asset resultHandler:resultHandler];
#endif
}






/*
 |--------------------------------------------------------------------------
 | Bytesize
 |--------------------------------------------------------------------------
 */
#pragma mark - Bytesize


-(void)requestBytesizeForAsset:(MPKAsset *)asset resultHandler:(void (^)(int64_t))resultHandler
{
	NSString *path = [NSString stringWithFormat:@"%@full_%@", kImageCachePath, asset.assetIdentifier];
	
	void (^returnCached)(UIImage *image) = ^void(UIImage *image)
	{
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
		int64_t bytesize = [attributes[NSFileSize] unsignedLongLongValue];
		resultHandler(bytesize);
	};
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		return returnCached(nil);
	}
	
	switch (asset.type)
	{
		case MPKAssetTypeLocal:
			[self attemptRequestForLocalBytesize:asset resultHandler:resultHandler];
			break;
			
		case MPKAssetTypeRemote:
			// fallthrough
		case MPKAssetTypeDropbox:
			[self requestImageFromURL:[(MPKRemoteAsset *)asset fullResolutionURLString] writeToPath:path resultHandler:nil];
			break;
			
		case MPKAssetTypeVideo:
			//not yet implemented
			break;
			
        case MPKAssetTypeEmoji:
            //not yet implemented
			break;
			
		case MPKAssetTypeSanDisk:
			[self attemptRequestForSanDiskBytesize:asset resultHandler:resultHandler];
			break;
	}
}



-(void)attemptRequestForLocalBytesize:(MPKAsset *)asset resultHandler:(void (^)(int64_t))resultHandler
{
#ifdef Pods_MPKLocal_h
	if(self.localCachingModule == nil){
		self.localCachingModule = [[MPKLocalCachingModule alloc] init];
	}
	
	MPKLocalCachingModule *module = self.localCachingModule;
	[module requestBytesizeForAsset:asset resultHandler:resultHandler];
#endif
}


-(void)attemptRequestForSanDiskBytesize:(MPKAsset *)asset resultHandler:(void (^)(int64_t))resultHandler
{
#ifdef Pods_MPKSanDisk_h
	if(self.sanDiskCachingModule == nil){
		self.sanDiskCachingModule = [[MPKSanDiskCachingModule alloc] init];
	}
	
	MPKSanDiskCachingModule *module = self.sanDiskCachingModule;
	[module requestBytesizeForAsset:asset resultHandler:resultHandler];
#endif
}





@end
