//
//  MPKFacebookAsset.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/8/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKRemoteAsset.h"

@interface MPKFacebookAsset : MPKRemoteAsset

-(instancetype)initWithFacebookJSON:(NSDictionary *)jsonDictionary;

@end
