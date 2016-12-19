//
//  MPKInstagramCollection.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/6/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKInstagramCollection.h"

#import "MEAPhotoKit.h"
#import "MPKInstagram.h"

#import <Instagram.h>

@interface MPKInstagramCollection() <IGRequestDelegate>

@property (nonatomic, readonly) MPKInstagramSourceSession *localSourceSession;
@property (nonatomic, copy) void (^loadCompletionHandler)();

@end

@implementation MPKInstagramCollection

-(instancetype)initRootCollection
{
	self = [super init];
	
	if (self)
	{
		self.sourceSession = [[MPKInstagramSourceSession alloc] init];
		self.title = self.sourceSession.sourceTitle;
	}
	
	return self;
}

-(void)dealloc
{
	self.loadCompletionHandler = nil;
}

-(MPKCollectionType)type
{
	return MPKCollectionTypeInstagram;
}

-(MPKInstagramSourceSession *)localSourceSession
{
	return (id)self.sourceSession;
}



#pragma mark - Loading

-(void)loadContentsCompletionHandler:(void (^)())completionHandler
{
	[super loadContentsCompletionHandler:completionHandler];
	
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self/media/recent/?count=20", @"method", nil];
	[self.localSourceSession.instagram requestWithParams:params delegate:self];
}



#pragma mark - Instagram Request Delegate

-(void)request:(IGRequest *)request didLoad:(id)result
{
	NSArray *jsonData = (NSArray*)[result objectForKey:@"data"];
	NSDictionary *pagination = [result objectForKey:@"pagination"];
	
	for (int i = 0; i < [jsonData count]; i++)
	{
		MPKInstagramAsset *asset = [[MPKInstagramAsset alloc] initWithInstagramJSON:[jsonData objectAtIndex:i]];
		
		[self addMPKAsset:asset];
	}
	
	
	if (pagination)
	{
		NSString *nextUrl = [pagination objectForKey:@"next_url"];
		NSInteger location = [nextUrl rangeOfString:@"user"].location;
		if (nextUrl && (location != NSNotFound))
		{
			NSString *splitUrl = [nextUrl substringFromIndex:location];
			NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:splitUrl, @"method", nil];
			[self.localSourceSession.instagram requestWithParams:params delegate:self];
		}
	}
}


@end
