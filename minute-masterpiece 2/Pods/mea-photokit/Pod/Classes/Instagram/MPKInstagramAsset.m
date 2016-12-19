//
//  MPKInstagramAsset.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/7/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKInstagramAsset.h"

@interface MPKInstagramAsset ()

@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;

@end

@implementation MPKInstagramAsset

-(instancetype)initWithInstagramJSON:(NSDictionary *)jsonDictionary
{
	self = [super init];
	
	if (self)
	{
		self.title = [jsonDictionary objectForKey:@"id"];
		NSDictionary *imageInfo = [jsonDictionary objectForKey:@"images"];
		NSDictionary *standardResInfo = [imageInfo objectForKey:@"standard_resolution"];
		
		self.fullResolutionURLString = [standardResInfo objectForKey:@"url"];
		self.width = [[standardResInfo objectForKey:@"width"] integerValue];
		self.height = [[standardResInfo objectForKey:@"height"] integerValue];
		
		self.thumbnailURLString = [[imageInfo objectForKey:@"thumbnail"] objectForKey:@"url"];
		self.timeStamp = (NSUInteger)[jsonDictionary[@"created_time"] integerValue];
	}
	
	return self;
}

-(NSUInteger)pixelWidth
{
	return self.width;
}

-(NSUInteger)pixelHeight
{
	return self.height;
}

@end
