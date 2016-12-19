//
//  MPKAsset.h
//  mea-photokit
//
//  Created by Daniel Loomb on 9/22/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MPKAssetType)
{
	MPKAssetTypeLocal = 0,
	MPKAssetTypeRemote,
	MPKAssetTypeDropbox,
    MPKAssetTypeEmoji,
	MPKAssetTypeVideo,
	MPKAssetTypeFile,
	MPKAssetTypeSanDisk
};

@interface MPKAsset : NSObject

/**
 The name of this asset
 */
@property (nonatomic, strong) NSString *title;

/**
 The type given to this asset, used to determine what behaviours will be applied to it 
 */
@property (nonatomic, readonly) MPKAssetType type;

/**
 A unique identifier generated from this assets information
 */
@property (nonatomic, readonly) NSString *assetIdentifier;

/**
 The creation time of this Asset in seconds
 */
@property (nonatomic) NSUInteger timeStamp;

/**
 The width of the Asset in pixels
 */
@property (nonatomic, readonly) NSUInteger pixelWidth;

/**
 The height of the Asset in pixels
 */
@property (nonatomic, readonly) NSUInteger pixelHeight;

@end
