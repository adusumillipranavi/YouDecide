//
//  MPKAlbumsViewController.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/6/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MPKCollection;
@class MPKSourceSessionManager;
@class MPKItemDisplayViewController;
@class MPKAsset;
@class MPKCachingImageManager;

extern NSString * const MPKItemExplorerForceRefreshNotification;
extern NSString * const MPKItemExplorerAccountSettingsSegueIdentifier;

typedef NS_ENUM(NSUInteger, MPKItemExplorerSection)
{
    MPKItemExplorerSectionCollections = 0,
    MPKItemExplorerSectionAssets,
    MPKItemExplorerSectionAccountSettings,
    MPKItemExplorerSectionCount
};


@interface MPKItemExplorerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

///------------------------------------------------
/// @name UI Element References
///------------------------------------------------

/**
 The Collection View used to display collections and assets
 */
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

/**
 The boolean that dictates whether or not this screen will show the account settings button
 */
@property (nonatomic) BOOL accountSettingsHidden;

/**
 The boolean that dictates whether or not this screen will have pull to load functionality
 */
@property (nonatomic) BOOL pullToLoad;

///------------------------------------------------
/// @name Data Storage Properties
///------------------------------------------------

/**
 The Collection that is currently displayed
 */
@property (strong, nonatomic) MPKCollection *rootCollection;

/**
 The array that holds all the selected assets.
 */
@property (nonatomic, weak) NSMutableArray *selectedAssetsArray;

@property (strong, nonatomic) MPKCachingImageManager *cachingImageManager;


+(MPKItemExplorerViewController *)rootItemExplorerWithSourceKeys:(NSDictionary *)sourcekeys;

-(MPKItemExplorerViewController *)explorerWithCollection:(MPKCollection *)collection;

-(BOOL)selectAsset:(MPKAsset *)asset;
-(void)deselectAsset:(MPKAsset *)asset;
-(BOOL)isAssetSelected:(MPKAsset *)asset;
-(NSUInteger)assetsCount;

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForCollectionAtIndexPath:(NSIndexPath *)indexPath;
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForAssetAtIndexPath:(NSIndexPath *)indexPath;

@end
