//
//  MPKLocalCollection.h
//  mea-photokit
//
//  Created by Daniel Loomb on 9/24/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKCollection.h"

@class ALAssetsGroup;
@class MPKLocalSourceSession;

@interface MPKLocalCollection : MPKCollection

-(instancetype)initWithALAssetsGroup:(ALAssetsGroup *)group andSourceSession:(MPKLocalSourceSession *)sourceSession;
-(instancetype)initWithFilteredAssetList:(NSArray *)assetList andTitle:(NSString *)title andSourceSession:(MPKLocalSourceSession *)sourceSession;

@end
