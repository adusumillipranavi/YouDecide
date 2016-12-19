//
//  MPKRemoteAsset+DimensionRequest.h
//  Pods
//
//  Created by Daniel on 4/12/15.
//
//

#import "MPKRemoteAsset.h"

@interface MPKRemoteAsset (DimensionRequest) 

-(void)requestFullResolutionImageDimensionsWithCompletion:(void (^)(NSError *error, NSDictionary *result))completion;

@end
