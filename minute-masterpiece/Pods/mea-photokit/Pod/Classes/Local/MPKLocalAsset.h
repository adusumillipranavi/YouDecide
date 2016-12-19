//
//  MPKLocalAsset.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/6/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKAsset.h"

@class PHAsset;
@class ALAsset;

@interface MPKLocalAsset : MPKAsset

@property (strong, nonatomic) PHAsset *phAsset;
@property (strong, nonatomic) ALAsset *alAsset;

@property (readonly, nonatomic) BOOL isCloud;

-(instancetype)initWithPHAsset:(PHAsset *)asset;
-(instancetype)initWithALAsset:(ALAsset *)asset;

@end
