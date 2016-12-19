//
//  MPKFacebookAsset.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/8/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKFacebookAsset.h"

@interface MPKFacebookAsset ()
@end


@implementation MPKFacebookAsset

-(instancetype)initWithFacebookJSON:(NSDictionary *)jsonDictionary
{
	self = [super init];
	
	if (self)
	{
		NSMutableDictionary *orderedImageDicts = [NSMutableDictionary dictionary];
		for (NSDictionary *individualImageDict in jsonDictionary[@"images"])
		{
			[orderedImageDicts setObject:individualImageDict forKey:individualImageDict[@"width"]];
		}
		
		
		NSArray *orderKeys = [orderedImageDicts.allKeys sortedArrayUsingSelector:@selector(compare:)];
		
		NSDictionary *sourceDict = orderedImageDicts[[orderKeys lastObject]];
		//get the second image for thumbnail if available because of the higher res retina screens
		NSDictionary *thumbDict;
		if (orderKeys.count >= 3)
		{
			thumbDict = orderedImageDicts[[orderKeys objectAtIndex:2]];
		}
		else
		{
			thumbDict = orderedImageDicts[[orderKeys lastObject]];
		}
		
		
		self.fullResolutionURLString = [sourceDict objectForKey:@"source"];
		
		[self setValue:[sourceDict objectForKey:@"width"] forKey:@"width"];
		[self setValue:[sourceDict objectForKey:@"height"] forKey:@"height"];
		
		self.thumbnailURLString = [thumbDict objectForKey:@"source"];
		
        self.title = jsonDictionary[@"id"];
        
		NSString *createdTimeString = jsonDictionary[@"created_time"];
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
		NSDate *date = [df dateFromString:createdTimeString];
		self.timeStamp = date.timeIntervalSince1970;
	}
	
	return self;
}



@end
