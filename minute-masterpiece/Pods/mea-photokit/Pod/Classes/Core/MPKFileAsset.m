//
//  MPKFileAsset.m
//  Pods
//
//  Created by Daniel Loomb on 3/5/15.
//
//

#import "MPKFileAsset.h"

@implementation MPKFileAsset

- (instancetype)initFileLocation:(NSString *)location
{
    self = [super init];
    if (self)
    {
        self.imagePath = location;
        self.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    }
    return self;
}

-(MPKAssetType)type
{
    return MPKAssetTypeFile;
}

-(NSString *)assetIdentifier{
    return [NSString stringWithFormat:@"%@-%lu", NSStringFromClass([self class]), (unsigned long)self.timeStamp];
}

@end
