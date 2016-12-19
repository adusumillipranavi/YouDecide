//
//  MPKLocalCollection.m
//  mea-photokit
//
//  Created by Daniel Loomb on 9/24/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKLocalCollection.h"

#import "MEAPhotoKit.h"
#import "MPKLocal.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MPKLocalCollection()

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) ALAssetsGroup *assetsGroup;

@property (strong, nonatomic) NSArray *assetsList;

@property (nonatomic) BOOL isRoot;

@end

@implementation MPKLocalCollection


#pragma mark - Initializers

-(instancetype)initRootCollection
{
	self = [super init];
	
	if (self)
	{
		self.title = @"Local Photos";
		self.sourceSession = [[MPKLocalSourceSession alloc] init];
		self.isRoot = YES;
	}
	
	return self;
}

-(instancetype)initWithALAssetsGroup:(ALAssetsGroup *)group andSourceSession:(MPKLocalSourceSession *)sourceSession
{
	self = [super init];
	
	if (self)
	{
		self.title = [group valueForProperty:ALAssetsGroupPropertyName];
		self.assetsGroup = group;
		self.sourceSession = sourceSession;	
//		[self iOS7LoadAssets:group];
	}
	
	return self;
}

-(instancetype)initWithFilteredAssetList:(NSArray *)assetList andTitle:(NSString *)title andSourceSession:(MPKLocalSourceSession *)sourceSession
{
	self = [super init];
	
	if (self)
	{
		self.title = title;
		self.assetsList = assetList;
		self.sourceSession = sourceSession;
//		[self iOS8LoadAssets:assetList];
	}
	
	return self;
}


#pragma mark - Readonly Properties

-(MPKCollectionType)type
{
	return MPKCollectionTypeLocal;
}


#pragma mark - Loading


-(void)loadRootCollection
{
	if ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1))
	{
		[self iOS8LoadAlbums];
	}
	else
	{
		[self iOS7LoadAlbums];
	}
}

-(void)loadContentsCompletionHandler:(void (^)())completionHandler
{
	[super loadContentsCompletionHandler:completionHandler];
	
	if (self.isRoot)
	{
		[self loadRootCollection];
	}
	else
	{
		if ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1))
		{
			[self iOS8LoadAssets:self.assetsList];
		}
		else
		{
			[self iOS7LoadAssets:self.assetsGroup];
		}
	}
}

-(void)iOS8LoadAlbums
{
	//All Photos
	PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
	allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
	PHFetchResult *allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
	if (allPhotos.count > 0) {
		MPKCollection *allCollection = [[MPKLocalCollection alloc] initWithFilteredAssetList:(id)allPhotos andTitle:@"All Photos" andSourceSession:(id)self.sourceSession];
		[self addMPKCollection:allCollection];
	}

	allPhotosOptions.sortDescriptors = nil;
	allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];

	//Smart Albums
	PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
	for (PHCollection *collection in smartAlbums) {
		if ([collection isKindOfClass:[PHAssetCollection class]]) {
			if ([collection.localizedTitle isEqualToString:@"All Photos"] == NO) {
				PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:allPhotosOptions];
				if (assetsFetchResult.count > 0) {
					MPKCollection *smartCollection = [[MPKLocalCollection alloc] initWithFilteredAssetList:(id)assetsFetchResult andTitle:collection.localizedTitle andSourceSession:(id)self.sourceSession];
					[self addMPKCollection:smartCollection];
				}

			}
		}
	}
	
	//User Albums
	PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
	for (PHCollection *collection in topLevelUserCollections) {
		if ([collection isKindOfClass:[PHAssetCollection class]]) {
			PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:allPhotosOptions];
			if (assetsFetchResult.count > 0) {
				MPKCollection *smartCollection = [[MPKLocalCollection alloc] initWithFilteredAssetList:(id)assetsFetchResult andTitle:collection.localizedTitle andSourceSession:(id)self.sourceSession];
				[self addMPKCollection:smartCollection];
			}
		}
	}
}



-(void)iOS7LoadAlbums
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		
		// Load Albums into assetGroups
		ALAssetsLibraryGroupsEnumerationResultsBlock assetGroupEnumerator = ^(ALAssetsGroup *group, BOOL *stop)
		{
			if(group != nil)
			{
				[self addMPKCollection:[[MPKLocalCollection alloc] initWithALAssetsGroup:group andSourceSession:(id)self.sourceSession]];
				
				[group numberOfAssets]; // load here so it does not block later..
			}
		};
		
		ALAssetsLibraryGroupsEnumerationResultsBlock assetGroupEnumeratorPassTwo = ^(ALAssetsGroup *group, BOOL *stop)
		{
			if(group != nil)
			{
				NSInteger numberOfAssets = [group numberOfAssets]; // load here so it does not block later..
				if (numberOfAssets > 0)
				{
					[self addMPKCollection:[[MPKLocalCollection alloc] initWithALAssetsGroup:group andSourceSession:(id)self.sourceSession]];
				}
				
			}
		};
		
		// Group Enumerator Failure Block
		ALAssetsLibraryAccessFailureBlock assetGroupEnumberatorFailure = ^(NSError *error)
		{
			[self loadComplete];
		};
		
		NSUInteger groupTypes = ALAssetsGroupSavedPhotos;
		
		self.assetsLibrary = [[ALAssetsLibrary alloc] init];
		
		[self.assetsLibrary enumerateGroupsWithTypes:groupTypes
										  usingBlock:assetGroupEnumerator
										failureBlock:assetGroupEnumberatorFailure];
		
		groupTypes = ALAssetsGroupPhotoStream | ALAssetsGroupAlbum | ALAssetsGroupLibrary;
		
		[self.assetsLibrary enumerateGroupsWithTypes:groupTypes
										  usingBlock:assetGroupEnumeratorPassTwo
										failureBlock:nil];
    });
	
}

-(void)iOS8LoadAssets:(NSArray *)assetList
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		for (int i = 0 ; i < assetList.count; i++)
		{
			MPKAsset *asset = [[MPKLocalAsset alloc] initWithPHAsset:assetList[i]];
			[self addMPKAsset:asset];
		}
	});
}

-(void)iOS7LoadAssets:(ALAssetsGroup *)assetsGroup
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		
		void (^assetEnumerator) (ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop)
		{
			if(result != nil)
			{
				
				if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
				{
					[self addMPKAsset:[[MPKLocalAsset alloc] initWithALAsset:result]];
				}
			}
		};
		
		
		[assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
	});
}

-(MPKAsset *)coverAsset
{
	if ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1))
	{
		if (self.assetsList.count) {
			MPKAsset *asset = [[MPKLocalAsset alloc] initWithPHAsset:[self.assetsList firstObject]];
			return asset;
		}
	}
	return nil;
}

@end
