//
//  MPKCollection.m
//  mea-photokit
//
//  Created by Daniel Loomb on 9/22/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKCore.h"

@interface MPKCollection()

@property (strong, nonatomic) NSMutableArray *collections;
@property (strong, nonatomic) NSMutableArray *assets;

@property (strong, nonatomic) NSMutableArray *observers;

@end

@implementation MPKCollection


#pragma mark - Initializers

-(instancetype)initRootCollection
{
	[[NSException exceptionWithName:@"Call to Virtual Method"
							 reason:@"MPKCollection: The base class should never call this method, you must call it in a subclass"
						   userInfo:nil]raise];
	
	return nil;
}

-(id)init
{
	self = [super init];
	
	if (self)
	{
		self.collections = [NSMutableArray array];
		self.assets = [NSMutableArray array];
		self.observers = [NSMutableArray array];
	}
	
	return self;
}


-(instancetype)initWithTitle:(NSString *)title
{
	self = [self init];
	
	if (self)
	{
		self.title = title;
	}
	
	return self;
}

-(instancetype) initWithTypes:(MPKCollectionType)types
{
	self = [MPKCollectionFactory createCollectionGivenTypes:types];
	
	if (self)
	{
		NSArray *priorities = [MEAPhotoKit photoSourcePriorities];
		if (priorities.count != 0) {
			[self sortCollectionByPriority:priorities];
		}
	}
	
	
	return self;
}


-(void)dealloc
{
	self.loadCompletionHandler = nil;
}

-(void)sortCollectionByPriority:(NSArray *)priorities
{
	NSMutableArray *collections = [NSMutableArray array];
	
	for (NSInteger i = 0; i < priorities.count; i++)
	{
		MPKCollectionType type = [priorities[i] integerValue];
		
		MPKCollection *collection = [self firstCollectionOfType:type];
		
		if (collection) {
			[self.collections removeObject:collection];
			[collections addObject:collection];
		}
	}
	
	[collections addObjectsFromArray:self.collections];
	
	self.collections = collections;
}


#pragma mark - Readonly Properties

-(MPKCollectionType)type
{
	return MPKCollectionTypeRoot;
}

-(NSInteger)numberOfAll
{
	return self.collections.count + self.assets.count;
}

-(NSInteger)numberOfAssets
{
	return self.assets.count;
}

-(NSInteger)numberOfCollections
{
	return self.collections.count;
}

-(BOOL)isCollectionsSourceActive
{
	return [self.sourceSession isSessionActive];
}


#pragma mark - Adding Items

-(void)addMPKCollection:(MPKCollection *)collection
{
	[self.collections addObject:collection];
	[self notifyCollectionObserversOfCollectionAddition:collection];
}

-(void)addMPKAsset:(MPKAsset *)asset
{
	[self.assets addObject:asset];
	[self notifyCollectionObserversOfAssetAddition:asset];
}

-(void)addMPKAssets:(NSArray *)assets
{
	for (MPKAsset *asset in assets) {
		[self addMPKAsset:asset];
	}
}

-(void)insertMPKAsset:(MPKAsset *)asset atIndex:(NSUInteger)index
{
	[self.assets insertObject:asset atIndex:index];
}


#pragma mark - Getting Items

-(MPKCollection *)collectionAtIndex:(NSInteger)index
{
	if (index >= 0 && index < self.collections.count)
	{
		return self.collections[index];
	}
	
	return nil;
}

-(MPKCollection *)firstCollectionOfType:(MPKCollectionType)type
{
	for (MPKCollection *collection in self.collections) {
		if (collection.type == type) {
			return collection;
		}
	}
	
	return nil;
}

-(MPKAsset *)assetAtIndex:(NSInteger)index
{
	if (index >= 0 && index < self.assets.count)
	{
		return self.assets[index];
	}
	
	return nil;
}

-(NSUInteger)indexForAsset:(MPKAsset *)asset
{
	return [self.assets indexOfObject:asset];
}


-(MPKAsset *)firstAsset
{
	return [self.assets firstObject];
}

-(MPKAsset *)lastAsset
{
	return [self.assets lastObject];
}

-(MPKAsset *)coverAsset
{
	return nil;
}

#pragma mark - Manipulating Collection

-(void)setupLoadOperationCompletionHandler:(void (^)())completionHandler
{
	self.loadCompletionHandler = completionHandler;
}

-(void)loadContentsCompletionHandler:(void (^)())completionHandler
{
	[self setupLoadOperationCompletionHandler:completionHandler];
	
	self.assets = [NSMutableArray array];
	self.collections = [NSMutableArray array];
}

-(void)loadNewerContentsCompletionHandler:(void (^)())completionHandler
{
	[self setupLoadOperationCompletionHandler:completionHandler];
}

-(void)loadOlderContentsCompletionHandler:(void (^)())completionHandler
{
	[self setupLoadOperationCompletionHandler:completionHandler];	
}


-(void)loadComplete
{
	dispatch_async(dispatch_get_main_queue(), ^{
		
		if (self.loadCompletionHandler)
		{
			self.loadCompletionHandler();
		}
		
	});
}



/*
 |--------------------------------------------------------------------------
 | MPKCollectionObserverProtocol
 |--------------------------------------------------------------------------
 */
#pragma mark - MPKCollectionObserverProtocol

-(void)addCollectionObserver:(id<MPKCollectionObserverProtocol>)observer
{
	if (![self.observers containsObject:observer]) {
		[self.observers addObject:observer];
	}
}

-(void)removeCollectionObserver:(id<MPKCollectionObserverProtocol>)observer
{
	[self.observers removeObject:observer];
}


-(void)notifyCollectionObserversOfUpdate
{
	for (id<MPKCollectionObserverProtocol>observer in self.observers) {
		[observer collectionDidUpdate];
	}
}

-(void)notifyCollectionObserversOfAssetAddition:(MPKAsset *)asset
{
	for (id<MPKCollectionObserverProtocol>observer in self.observers) {
		[observer collectionAddedAsset:asset];
	}
}

-(void)notifyCollectionObserversOfCollectionAddition:(MPKCollection *)collection
{
	for (id<MPKCollectionObserverProtocol>observer in self.observers) {
		[observer collectionAddedCollection:collection];
	}
}

- (void)resetCollection
{
    self.collections = [NSMutableArray array];
    self.assets = [NSMutableArray array];
    self.observers = [NSMutableArray array];
}






@end
