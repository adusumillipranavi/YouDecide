//
//  MPKFlickrAsset.h
//  Pods
//
//  Created by Daniel Loomb on 1/16/15.
//
//

#import "MPKRemoteAsset.h"

@interface MPKFlickrAsset : MPKRemoteAsset

-(instancetype)initWithJSON:(NSDictionary *)json andThumbUrl:(NSURL *)thumbUrl;

@end
