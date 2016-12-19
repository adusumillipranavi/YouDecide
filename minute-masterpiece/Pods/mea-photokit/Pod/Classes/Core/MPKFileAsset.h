//
//  MPKFileAsset.h
//  Pods
//
//  Created by Daniel Loomb on 3/5/15.
//
//

#import "MPKAsset.h"

@interface MPKFileAsset : MPKAsset

@property (nonatomic, strong) NSString *imagePath;

- (instancetype)initFileLocation:(NSString *)location;

@end
