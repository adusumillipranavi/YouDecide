//
//  MPKCollection.h
//  mea-photokit
//
//  Created by Daniel Loomb on 9/22/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKCore.h"

@class MPKAsset;
@class MPKCollection;
@class MPKSourceSession;

enum {
	MPKCollectionTypeRoot				= (1 << 0),
	MPKCollectionTypeLocal				= (1 << 1),
	MPKCollectionTypeInstagram			= (1 << 2),
	MPKCollectionTypeFacebook			= (1 << 3),
	MPKCollectionTypeDropbox			= (1 << 4),
	MPKCollectionTypeFlickr				= (1 << 5),
	MPKCollectionTypeGoogle				= (1 << 6),
	MPKCollectionTypeTwitter			= (1 << 7),
	MPKCollectionTypeDeviantArt			= (1 << 8),
	MPKCollectionTypePinterest			= (1 << 9),
	MPKCollectionTypeLive				= (1 << 10),
	MPKCollectionTypeVideo				= (1 << 11),
	MPKCollectionTypeAmazon				= (1 << 12),
	MPKCollectionTypeEmoji				= (1 << 13),
	MPKCollectionTypeInstagramPublic    = (1 << 14),
	MPKCollectionTypeSanDisk			= (1 << 15),
	MPKCollectionTypeAll				= 0xFFFFFFFFFFFFFFFF
};

typedef NSUInteger MPKCollectionType;



///------------------------------------------------
/// @name Protocol for Listening for Collection updates
///------------------------------------------------
@protocol MPKCollectionObserverProtocol <NSObject>

@optional

/**
 The Collection has finished a batch update operation
 */
-(void)collectionDidUpdate;

/**
 The Collection has added a single Asset
 */
-(void)collectionAddedAsset:(MPKAsset *)asset;

/**
 The Collection has added a single Collection
 */
-(void)collectionAddedCollection:(MPKCollection *)collection;

/**
 The Collection has completely finished its load cycle
 */
-(void)collectionDidFinishLoading:(MPKCollection *)collection;

@end


@interface MPKCollection : NSObject


///------------------------------------------------
/// @name Getting MPKCollection Information
///------------------------------------------------

/**
 The name of this collection
 */
@property (nonatomic, strong) NSString *title;

/**
 The count of all items in this collection, assets and other collections
 */
@property (nonatomic, readonly) NSInteger numberOfAll;

/**
 The count of other collecitons in this collection
 */
@property (nonatomic, readonly) NSInteger numberOfCollections;

/**
 The count of assets in this collection
 */
@property (nonatomic, readonly) NSInteger numberOfAssets;

@property (nonatomic, readonly) MPKCollectionType type;

@property (nonatomic, strong) MPKSourceSession *sourceSession;

@property (nonatomic, copy) void (^loadCompletionHandler)();

/**
 A convience property for whether or not this source is active
 */
@property (nonatomic, readonly) BOOL isCollectionsSourceActive;


///-----------------------------------------------------------
/// @name Creating and Initializing MPKCollection Objects
///-----------------------------------------------------------

/**
 Creates and returns a 'MPKCollection' object with given title;
 
 @param title What this collection will be named.
 
 @return The newly-initialized MPKCollection
 */
-(instancetype)initWithTitle:(NSString *)title;


-(instancetype)initWithTypes:(MPKCollectionType)types;


-(instancetype)initRootCollection;


///-----------------------------------------------------------
/// @name Adding items to this Collection
///-----------------------------------------------------------

/**
 Adds a MPKCollection object to this MPKCollecton's collection array.
 
 @param collection The MPKCollection object that will be added.
 */
-(void)addMPKCollection:(MPKCollection *)collection;


/**
 Adds a MPKAsset object to this MPKCollecton's assets array.
 
 @param asset The MPKAsset object that will be added.
 */
-(void)addMPKAsset:(MPKAsset *)asset;
-(void)addMPKAssets:(NSArray *)assets;
-(void)insertMPKAsset:(MPKAsset *)asset atIndex:(NSUInteger)index;


///-----------------------------------------------------------
/// @name Getting items in this Collection
///-----------------------------------------------------------

/**
 Gets a MPKCollection object from this MPKCollecton's collection array at the given index. If the index is out of bounds then nil is returned.
 
 @param index The index of the MPKCollection object that is to be returned.
 
 @return The MPKCollection object that was at the given index.
 */
-(MPKCollection *)collectionAtIndex:(NSInteger)index;

/**
 Gets the first MPKCollection object of the given type from this MPKCollecton's collection array. If a collection matching the type can not be found then nil is returned.
 
 @param index The type of the MPKCollection object that is to be returned.
 
 @return The MPKCollection object that matches the given type.
 */
-(MPKCollection *)firstCollectionOfType:(MPKCollectionType)type;

/**
 Gets a MPKAsset object from this MPKCollecton's assets array at the given index. If the index is out of bounds then nil is returned.
 
 @param index The index of the MPKAsset object that is to be returned.
 
 @return The MPKAsset object that was at the given index.
 */
-(MPKAsset *)assetAtIndex:(NSInteger)index;

/**
 Gets the index of an MPKAsset, and returns it.
 
 @param asset The MPKAsset you are looking for.
 
 @return NSUInteger The Index of the Asset or NSNotFound
 */
-(NSUInteger)indexForAsset:(MPKAsset *)asset;


/**
 Gets the first MPKAsset object in this collection
 
 @return The first MPKAsset object.
 */
-(MPKAsset *)firstAsset;


/**
 Gets the last MPKAsset object in this collection
 
 @return The last MPKAsset object.
 */
-(MPKAsset *)lastAsset;

/**
 Gets the MPKAsset object to be used as the Collecitons Cover image
 
 @return MPKAsset object.
 */
-(MPKAsset *)coverAsset;


-(void)loadContentsCompletionHandler:(void(^)())completionHandler;

-(void)loadNewerContentsCompletionHandler:(void(^)())completionHandler;

-(void)loadOlderContentsCompletionHandler:(void(^)())completionHandler;

-(void)loadComplete;

-(void)resetCollection;


///-----------------------------------------------------------
/// @name Working with the MPKCollectionObserverProtocol
///-----------------------------------------------------------

/**
 Add an Implementer of the Protocol to the Observers array
 
 @param observer The Impleneter of the MPKCollectionObserverProtocol
 */
-(void)addCollectionObserver:(id<MPKCollectionObserverProtocol>)observer;

/**
 Removes an Implementer of the Protocol to the Observers array
 
 @param observer The Impleneter of the MPKCollectionObserverProtocol
 */
-(void)removeCollectionObserver:(id<MPKCollectionObserverProtocol>)observer;


@end
