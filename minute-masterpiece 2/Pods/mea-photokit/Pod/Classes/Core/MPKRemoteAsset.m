//
//  MPKRemoteAsset.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/8/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKRemoteAsset.h"

@implementation MPKRemoteAsset

- (instancetype)initWithThumbnailUrl:(NSString *)thumbUrl andFullResolutionUrl:(NSString *)fullResolutionUrl
{
	self = [super init];
	if (self)
	{
		self.thumbnailURLString = thumbUrl;
		self.fullResolutionURLString = fullResolutionUrl;
		self.title = [fullResolutionUrl lastPathComponent];
	}
	return self;
}

-(MPKAssetType)type
{
	return MPKAssetTypeRemote;
}



@end
