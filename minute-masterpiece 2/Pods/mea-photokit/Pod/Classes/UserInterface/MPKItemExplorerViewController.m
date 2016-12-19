//
//  MPKAlbumsViewController.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/6/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKCore.h"
#import "MPKUserInterface.h"


NSString * const MPKItemExplorerAccountSettingsSegueIdentifier = @"ItemExplorerToAccounts";

@interface MPKItemExplorerViewController () <MPKCollectionObserverProtocol>

@property (nonatomic, strong) NSMutableArray *updatesQueue;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *collections;

@end

@implementation MPKItemExplorerViewController

+(MPKItemExplorerViewController *)rootItemExplorerWithSourceKeys:(NSDictionary *)sourcekeys
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[MEAPhotoKit photoKitBundleIdentifier:@"mea-photokit-UserInterface"]];
	MPKItemExplorerViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MPKItemExplorerViewControllerStoryboardIdentifier"];
	
	[MEAPhotoKit saveSourceKey:sourcekeys];
	
	return viewController;
}

#ifdef Pods_MPKVideo_h
-(MPKVideoItemExplorerViewController *)videoItemExplorerWithCollection:(MPKVideoCollection *)videoCollection
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[MEAPhotoKit photoKitBundleIdentifier:@"mea-photokit-UserInterface"]];
	MPKVideoItemExplorerViewController *itemExplorerViewController = [storyboard instantiateViewControllerWithIdentifier:@"MPKVideoItemExplorerViewControllerStoryboardIdentifier"];
	itemExplorerViewController.rootCollection = videoCollection;
	itemExplorerViewController.selectedAssetsArray = self.selectedAssetsArray;
	itemExplorerViewController.accountSettingsHidden = YES;
	itemExplorerViewController.pullToLoad = videoCollection.sourceSession.isRealoadable;
	
	return itemExplorerViewController;
}
#endif

-(MPKItemExplorerViewController *)explorerWithCollection:(MPKCollection *)collection
{
#ifdef Pods_MPKVideo_h
	if (collection.type == MPKCollectionTypeVideo) {
		return [self videoItemExplorerWithCollection:(id)collection];
	}
#endif
	
	//WARN: Uses RestorationId as StoryboardId, must be set in interface builder
	MPKItemExplorerViewController *itemExplorerViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.restorationIdentifier];
	itemExplorerViewController.rootCollection = collection;
	itemExplorerViewController.selectedAssetsArray = self.selectedAssetsArray;
	itemExplorerViewController.accountSettingsHidden = YES;
	itemExplorerViewController.pullToLoad = collection.sourceSession.isRealoadable;
	
	return itemExplorerViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.updatesQueue = [NSMutableArray array];
	self.assets = [NSMutableArray array];
	self.collections = [NSMutableArray array];
	
	[self.rootCollection addCollectionObserver:self];
	
	if (self.selectedAssetsArray == nil)
	{
		self.selectedAssetsArray = [NSMutableArray array];
	}
	
	if (self.pullToLoad)
	{
		[self setupPullToLoad];
	}

	self.cachingImageManager = [[MPKCachingImageManager alloc] init];
	
	if (self.rootCollection == nil)
	{
		self.rootCollection = [MEAPhotoKit rootCollection];
		for (NSUInteger i = 0; i < self.rootCollection.numberOfCollections; i++)
		{
			[self.collections addObject:[self.rootCollection collectionAtIndex:i]];
		}
		[self.collectionView reloadData];
	}
	else
	{
		self.title = self.rootCollection.title;
		
		[[MPKUserInterface sharedInstance] setNonIntrusiveActivityIndicatorVisible:YES];
		
		// If we are using public instagram, we don't want to use the default load. Search by tag instead
		if(self.rootCollection.type != MPKCollectionTypeInstagramPublic)
		{
			[self.rootCollection loadContentsCompletionHandler:^{
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.collectionView reloadData];
					
					[[MPKUserInterface sharedInstance] setNonIntrusiveActivityIndicatorVisible:NO];
					
					if (self.rootCollection.numberOfCollections == 0)
					{
						self.collectionView.scrollEnabled = YES;
					}
				});
			}];
		}
		
	}
	
	self.collectionView.allowsMultipleSelection = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.collectionView reloadData];
	[self.rootCollection addCollectionObserver:self];
}


-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.rootCollection removeCollectionObserver:self];
}


#pragma mark - View Controller Handling


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:MPKItemExplorerAccountSettingsSegueIdentifier])
	{
		MPKAccountsViewController *accountsViewController = segue.destinationViewController;
		
		NSMutableArray *sources = [[NSMutableArray alloc] init];
		
		for (NSInteger i = 0; i < [self.rootCollection numberOfCollections]; i ++)
		{
			MPKCollection *collection = [self.rootCollection collectionAtIndex:i];
			if (collection.sourceSession)
			{
				[sources addObject:collection.sourceSession];
			}
		}
		
		accountsViewController.sourceSessions = sources;
	}
}




#pragma mark - Pull To Reload


-(void)setupPullToLoad
{
//	[self.collectionView addTopRefreshControlUsingBlock:^{
//		
//		[self handleTopPullLoad];
//		
//	} refreshControlPullType:(RefreshControlPullTypeInsensitive) refreshControlStatusType:(RefreshControlStatusTypeArrow)];
//	
//	[self.collectionView addBottomRefreshControlUsingBlock:^{
//		
//		[self handleBottomPullLoad];
//		
//	} refreshControlPullType:(RefreshControlPullTypeInsensitive) refreshControlStatusType:(RefreshControlStatusTypeArrow)];
}



-(void)handleTopPullLoad
{
	MPKCollection *collection = self.rootCollection;
	
//	[collection loadNewerContentsCompletionHandler:^{
//		[self.collectionView reloadData];
//		[self.collectionView topRefreshControlStopRefreshing];
//	}];
}

-(void)handleBottomPullLoad
{	
	MPKCollection *collection = self.rootCollection;
	
//	[collection loadOlderContentsCompletionHandler:^{
//		[self.collectionView reloadData];
//		[self.collectionView bottomRefreshControlStopRefreshing];
//	}];
}



#pragma mark - MPKAsset Handling

-(BOOL)selectAsset:(MPKAsset *)asset
{
	[self.selectedAssetsArray addObject:asset];
    return YES;
}

-(void)deselectAsset:(MPKAsset *)asset
{
	[self.selectedAssetsArray removeObject:asset];
}

-(BOOL)isAssetSelected:(MPKAsset *)asset
{
	return [self.selectedAssetsArray containsObject:asset];
}

-(NSUInteger)assetsCount
{
	return self.assets.count;
}


#pragma mark - CollectionView Implementation

-(void)didSelectCollectionAtIndex:(NSInteger)index
{
	MPKCollection *collection = [self.rootCollection collectionAtIndex:index];
	
	if ([collection isCollectionsSourceActive] == NO) // If the source is inactive, activate it
	{
		[collection.sourceSession activateSourceSessionWithCompletionHandler:^(BOOL activated, NSError *error) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				if (activated)
				{
					[self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
					
					[self.navigationController pushViewController:[self explorerWithCollection:collection] animated:YES];
				}
				else if(error)
				{
					UIAlertController *alert = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedFailureReason preferredStyle:UIAlertControllerStyleAlert];
					[alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
					[self presentViewController:alert animated:YES completion:nil];
				}
			});

		}];
	}
	
	else //Source is active, go to its contents
	{
		[self.navigationController pushViewController:[self explorerWithCollection:collection] animated:YES];
	}
}


-(void)didSelectAssetAtIndex:(NSInteger)index
{
	MPKAsset *asset = [self.rootCollection assetAtIndex:index];
	
	MPKItemDisplayViewController *itemDisplayViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MPKItemDisplayViewControllerStoryboardIdentifier"];
	itemDisplayViewController.asset = asset;
	[self.navigationController pushViewController:itemDisplayViewController animated:YES];

}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	//Bool to Int
	return MPKItemExplorerSectionCount - self.accountSettingsHidden;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	if (section == 0)
	{
		return self.collections.count;
	}
	else if(section == 1)
	{
		return self.assets.count;
//		return self.rootCollection.numberOfAssets;
	}
	
	return 1;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewFlowLayout *flowLayout = (id)collectionViewLayout;
	
	UIEdgeInsets insets = [self collectionView:collectionView layout:flowLayout insetForSectionAtIndex:indexPath.section];
	
	CGFloat width = CGRectGetWidth(collectionView.frame) - insets.left - insets.right;
	
	if (indexPath.section == MPKItemExplorerSectionAssets)
	{
		//Ipad
		if (width > 500) {
			width = floorf((width - (flowLayout.minimumInteritemSpacing * 5.0f)) / 6.0f);
		}else{
			width = floorf((width - (flowLayout.minimumInteritemSpacing * 2.0f)) / 3.0f);
		}
		
		return CGSizeMake(width, width);
	}
	
	return CGSizeMake(width, 60);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
	if (section == MPKItemExplorerSectionCount - 1 - self.accountSettingsHidden)
	{
		return CGSizeMake(CGRectGetWidth(collectionView.frame), 100);
	}
	
	return CGSizeZero;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Footer" forIndexPath:indexPath];
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	if (section == MPKItemExplorerSectionCollections && self.rootCollection.numberOfCollections != 0)
	{
		return UIEdgeInsetsMake(0, 0, 5, 0);
	}
	
	if (section == MPKItemExplorerSectionAssets && self.rootCollection.numberOfAssets != 0)
	{
		return UIEdgeInsetsMake(5, 5, 5, 5);
	}
	
	if (section == MPKItemExplorerSectionAccountSettings && self.accountSettingsHidden == NO)
	{
		return UIEdgeInsetsMake(5, 0, 5, 0);
	}
	
	return UIEdgeInsetsZero;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	if (section == MPKItemExplorerSectionAssets)
	{
		return 5;
	}
	
	return 0;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		return [self collectionView:collectionView cellForCollectionAtIndexPath:indexPath];
	}
	else if(indexPath.section == 1)
	{
		return [self collectionView:collectionView cellForAssetAtIndexPath:indexPath];
	}

	return [collectionView dequeueReusableCellWithReuseIdentifier:@"AccountSettingsCell" forIndexPath:indexPath];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForCollectionAtIndexPath:(NSIndexPath *)indexPath
{
	MPKCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
	
	NSInteger currentTag = cell.tag + 1;
	cell.tag = currentTag;
	
	MPKCollection *collection = [self.rootCollection collectionAtIndex:indexPath.row];
	cell.labelMain.text = collection.title;
	[cell.imageView setImage:[MEAPhotoKit imageNamed:@"icon_120.png" fromBundle:@"mea-photokit-UserInterface"]];
	[cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
	cell.imageView.clipsToBounds = YES;
	
	[cell.labelSecondary setText:@""];
	if (self.rootCollection.type == MPKCollectionTypeRoot)
	{
		[cell.labelSecondary setText:collection.sourceSession.displayName];
	}
	
	MPKAsset *cover = [collection coverAsset];
	[cell.imageView setImage:collection.sourceSession.sourceImage];
	if (cover)
	{
		[self.cachingImageManager requestThumbnailForAsset:cover resultHandler:^(UIImage *result)
		{
			if (cell.tag == currentTag)
			{
				[cell.imageView setImage:result];
			}
		}];
	}
	
	return cell;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForAssetAtIndexPath:(NSIndexPath *)indexPath
{
	MPKAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
	
	NSInteger currentTag = cell.tag + 1;
	cell.tag = currentTag;
	
	MPKAsset *asset = [self.rootCollection assetAtIndex:indexPath.row];
	NSLog(@"Asset %@", asset);
	
	[cell.cellImageView setImage:[MEAPhotoKit imageNamed:@"icon_120.png" fromBundle:@"mea-photokit-UserInterface"]];
	[cell.cellImageView setContentMode:UIViewContentModeScaleAspectFill];
	
	BOOL selected = [self isAssetSelected:asset];
	[cell setSelected:selected];
	if (selected)
	{
		[collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:(UICollectionViewScrollPositionNone)];
	}
//	else
//	{
//		[collectionView deselectItemAtIndexPath:indexPath animated:NO];
//	}
	
	[self.cachingImageManager requestThumbnailForAsset:asset resultHandler:^(UIImage *result) {
		
		if (cell.tag == currentTag && result != nil)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[cell.cellImageView setImage:result];
			});
		}
	}];
	
	return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	//If selected row in Collections Section
	if (indexPath.section == 0)
	{
		[self didSelectCollectionAtIndex:indexPath.row];
	}
	else if(indexPath.section == 1)
	{
		[self didSelectAssetAtIndex:indexPath.item];
//		MPKAsset *asset = [self.rootCollection assetAtIndex:indexPath.item];
//		
//        if( ! [self selectAsset:asset] )
//        {
//            [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//        }
	}
	else
	{
		[self performSegueWithIdentifier:MPKItemExplorerAccountSettingsSegueIdentifier sender:self];
	}
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == MPKItemExplorerSectionAssets) {
		MPKAsset *asset = [self.rootCollection assetAtIndex:indexPath.item];
		if (asset) {
			[self deselectAsset:asset];
		}
	}
}




/*
 |--------------------------------------------------------------------------
 | MPKCollectionObserverProtocol
 |--------------------------------------------------------------------------
 */
#pragma mark - MPKCollectionObserverProtocol

-(void)kickUpdatesQueue
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.updatesQueue.count) {
			void (^update)() = self.updatesQueue[0];
			update();
        }else{
            [[MPKUserInterface sharedInstance] setNonIntrusiveActivityIndicatorVisible:NO];
        }
	});
}

-(void)collectionDidUpdate
{
	NSLog(@"Collection Update");
}

-(void)collectionAddedAsset:(MPKAsset *)asset
{
	__block MPKItemExplorerViewController *this = self;
	
	[self.updatesQueue addObject:^{
	
		NSUInteger index = this.assets.count;
		[this.assets addObject:asset];

		[this.collectionView insertItemsAtIndexPaths:@[
		   [NSIndexPath indexPathForItem:index inSection:MPKItemExplorerSectionAssets]
		]];
		
		[this.updatesQueue removeObjectAtIndex:0];
		[this kickUpdatesQueue];
	}];
	
	[self kickUpdatesQueue];
}

-(void)collectionAddedCollection:(MPKCollection *)collection
{
	__block MPKItemExplorerViewController *this = self;
	
	[self.updatesQueue addObject:^{
		
		NSUInteger index = this.collections.count;
		[this.collections addObject:collection];
		
		[this.collectionView insertItemsAtIndexPaths:@[
			[NSIndexPath indexPathForItem:index inSection:MPKItemExplorerSectionCollections]
		]];
		
		[this.updatesQueue removeObjectAtIndex:0];
		[this kickUpdatesQueue];
	}];
	
	[self kickUpdatesQueue];
}


@end
