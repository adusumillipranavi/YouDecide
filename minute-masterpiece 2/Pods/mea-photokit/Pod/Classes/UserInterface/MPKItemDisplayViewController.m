//
//  MPKItemDisplayViewController.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/6/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKItemDisplayViewController.h"
#import "MPKCore.h"

@interface MPKItemDisplayViewController()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) MPKCachingImageManager *cachingImageManager;
@end

@implementation MPKItemDisplayViewController

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	self.cachingImageManager = [[MPKCachingImageManager alloc] init];
	
	[self.cachingImageManager requestFullImageForAsset:self.asset resultHandler:^(UIImage *result) {
		[self.imageView setImage:result];
	}];
}

@end
