//
//  MPKInstagramAsset.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/7/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKRemoteAsset.h"
#import <UIKit/UIKit.h>

@interface MPKInstagramAsset : MPKRemoteAsset

-(instancetype)initWithInstagramJSON:(NSDictionary *)jsonDictionary;

@end
