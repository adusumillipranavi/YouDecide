//
//  MPKAsset.m
//  mea-photokit
//
//  Created by Daniel Loomb on 9/22/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKAsset.h"

@interface MPKAsset()
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@end


@implementation MPKAsset

-(MPKAssetType)type
{
	[[NSException exceptionWithName:@"CallAbstractMethodException" reason:@"type was called on MPKAsset root class. This is not allowed. It should be implemented by a subclass" userInfo:nil] raise];
	
	return 0;
}

-(NSString *)assetIdentifier
{
	return [NSString stringWithFormat:@"%@-%@-%lu", NSStringFromClass([self class]), self.title, (unsigned long)self.timeStamp];
}

-(BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[MPKAsset class]])
	{
		MPKAsset *other = object;
		return [self.assetIdentifier isEqualToString:other.assetIdentifier];
	}
	return [super isEqual:object];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p, Identifier: %@, Size: %lux%lu>",
			NSStringFromClass([self class]), self, self.assetIdentifier, self.pixelWidth, self.pixelHeight];
}


-(NSUInteger)pixelWidth
{
	return [self.width integerValue];
}

-(NSUInteger)pixelHeight
{
	return [self.height integerValue];
}

@end
