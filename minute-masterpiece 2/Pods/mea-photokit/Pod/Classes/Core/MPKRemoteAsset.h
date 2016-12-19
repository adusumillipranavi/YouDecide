//
//  MPKRemoteAsset.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/8/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKAsset.h"

@interface MPKRemoteAsset : MPKAsset

@property (nonatomic, strong) NSString *thumbnailURLString;
@property (nonatomic, strong) NSString *fullResolutionURLString;

- (instancetype)initWithThumbnailUrl:(NSString *)thumbUrl andFullResolutionUrl:(NSString *)fullResolutionUrl;

@end
