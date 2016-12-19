//
//  MPKFlickrAsset.m
//  Pods
//
//  Created by Daniel Loomb on 1/16/15.
//
//

#import "MPKFlickrAsset.h"

@interface MPKFlickrAsset()

@property (nonatomic, strong) NSDictionary *jsonData;

@end

@implementation MPKFlickrAsset

- (instancetype)initWithJSON:(NSDictionary *)json andThumbUrl:(NSURL *)thumbUrl
{
	self = [super init];
	if (self)
	{
		self.thumbnailURLString = thumbUrl.absoluteString;
		self.fullResolutionURLString = json[@"url_o"];
		self.title = self.fullResolutionURLString.lastPathComponent;
		self.timeStamp = (NSUInteger)[json[@"dateupload"] integerValue];
		self.jsonData = json;
	}
	return self;
}

-(NSUInteger)pixelWidth
{
	return [self.jsonData[@"width_o"] integerValue];
}

-(NSUInteger)pixelHeight
{
	return [self.jsonData[@"height_o"] integerValue];
}

@end
