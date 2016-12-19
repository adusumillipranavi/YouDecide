//
//  MPKLocalAsset.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/6/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKLocalAsset.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation MPKLocalAsset

-(instancetype)initWithPHAsset:(PHAsset *)asset
{
	self = [super init];
	
	if (self)
	{
		self.title = asset.localIdentifier;
		self.phAsset = asset;
		self.timeStamp = asset.creationDate.timeIntervalSince1970;
		
		[self setValue:@(asset.pixelWidth) forKey:@"width"];
		[self setValue:@(asset.pixelHeight) forKey:@"height"];
	}
	
	return self;
}

-(instancetype)initWithALAsset:(ALAsset *)asset
{
	self = [super init];
	
	if (self)
	{
		self.title = asset.defaultRepresentation.filename;
		self.alAsset = asset;
		
		NSDate *creationDate = [asset valueForProperty:ALAssetPropertyDate];
		self.timeStamp = creationDate.timeIntervalSince1970;
		
		CGSize dimensions = asset.defaultRepresentation.dimensions;
		[self setValue:@(dimensions.width) forKey:@"width"];
		[self setValue:@(dimensions.height) forKey:@"height"];
	}
	
	return self;
}

-(MPKAssetType)type
{
	return MPKAssetTypeLocal;
}

-(BOOL)isCloud
{
	return [self.phAsset.creationDate isKindOfClass:[NSClassFromString(@"__NSTaggedDate") class]];
}

//-(void)dealloc
//{
//	NSLog(@"LocalAssetDealloc");
//}

@end
