//
//  MPKFacebookCollection.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/8/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKFacebookCollection.h"

#import "MEAPhotoKit.h"
#import "MPKFacebook.h"

#import "FBSDKCoreKit.h"

NSString * const kFacebookGraphAPIAlbumsEndpoint = @"me/albums?fields=id,name,count,picture";
NSString * const kFacebookGraphAPIImagesEndpoint = @"/photos?fields=id,source,picture,width,height,created_time,images";

@interface MPKFacebookCollection()

@property (nonatomic, strong) NSString *facebookAlbumId;
@property (nonatomic, readonly) MPKFacebookSourceSession *localSourceSession;

@property (nonatomic, strong) MPKRemoteAsset *cover;

@end

@implementation MPKFacebookCollection

-(instancetype)initRootCollection
{
	self = [super init];
	
	if (self)
	{
		self.sourceSession = [[MPKFacebookSourceSession alloc] init];
		
		self.title = self.sourceSession.sourceTitle;
	}
	
	return self;
}

-(instancetype)initWithData:(NSDictionary *)data andSourceSession:(MPKFacebookSourceSession *)sourceSession
{
	NSString *title = [data objectForKey:@"name"];
	NSString *albumId = [data objectForKey:@"id"];
	
	self = [super initWithTitle:title];
	
	if (self)
	{
		self.facebookAlbumId = albumId;
		self.sourceSession = sourceSession;
		
		NSDictionary *cover = [data objectForKey:@"picture"][@"data"];
		NSString *url = cover[@"url"];
		if (url.length)
		{
			self.cover = [[MPKRemoteAsset alloc] initWithThumbnailUrl:url andFullResolutionUrl:url];
		}
	}
	
	return self;
}

-(MPKCollectionType)type
{
	return MPKCollectionTypeFacebook;
}

-(MPKFacebookSourceSession *)localSourceSession
{
	return (id)self.sourceSession;
}

-(MPKAsset *)coverAsset
{
	return self.cover;
}

#pragma mark - Loading


-(void)loadContentsCompletionHandler:(void (^)())completionHandler
{
	[super loadContentsCompletionHandler:completionHandler];
	
	if (self.facebookAlbumId == nil)
	{
		[self loadAlbumsWithGraphPath:kFacebookGraphAPIAlbumsEndpoint];
	}
	else if ([self.facebookAlbumId isEqual:@"TAGGED_PHOTOS"])
	{
		[self loadImagesWithGraphPath:@"me/photos?fields=id,name"];
	}
	else
	{
		NSString *graphPath = [NSString stringWithFormat:@"%@%@", self.facebookAlbumId, kFacebookGraphAPIImagesEndpoint];
		[self loadImagesWithGraphPath:graphPath];
	}
}



/*
 |--------------------------------------------------------------------------
 | Load Albums
 |--------------------------------------------------------------------------
 */
#pragma mark - Load Albums


-(void)loadAlbumsWithGraphPath:(NSString *)graphPath
{
	if ([self.sourceSession isSessionActive])
	{
		[[[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:nil]
		 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

			 if (!error)
			 {
				 NSArray *albums = result[@"data"];
				 if (albums)
				 {
					 for (int i = 0; i < [albums count]; i++)
					 {
						 NSDictionary *albumDict = [albums objectAtIndex:i];
						 
						 MPKFacebookCollection *collection = [[MPKFacebookCollection alloc] initWithData:albumDict andSourceSession:(id)self.sourceSession];;

						 [self addMPKCollection:collection];
					 }
				 }
				 
				 NSDictionary *paging = result[@"paging"];
				 if (paging)
				 {
					 NSDictionary *cursors = paging[@"cursors"];
					 if (cursors && cursors[@"after"])
					 {
						 NSString *afterString = [NSString stringWithFormat:@"%@&after=%@", kFacebookGraphAPIAlbumsEndpoint, cursors[@"after"]];
						 [self loadAlbumsWithGraphPath:afterString];
					 }
				 }
				 else
				 {
					 //Add Tagged Photos Collection
					 NSDictionary *tagged = @{@"name" : @"Tagged Photos", @"id" : @"TAGGED_PHOTOS"};
					 MPKFacebookCollection *collection = [[MPKFacebookCollection alloc] initWithData:tagged andSourceSession:(id)self.sourceSession];
//					 MPKAsset *cover = [MPKAsset ]
					 [self addMPKCollection:collection];
				 }
			 }
			 
			 else
			 {
				 //Handle error
//				 NSDictionary *errorDict = [MPKFacebookSourceSession FBErrorCodeDescription:error];
//				 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[errorDict objectForKey:@"title"]
//																	 message:[errorDict objectForKey:@"message"]
//																	delegate:nil
//														   cancelButtonTitle:@"OK"
//														   otherButtonTitles:nil];
//				 [alertView show];
//				 
//				 [[FBSession activeSession] closeAndClearTokenInformation];
			 }

			 
		 }];
	}
}





/*
 |--------------------------------------------------------------------------
 | Load Images
 |--------------------------------------------------------------------------
 */
#pragma mark - Load Images


- (void) loadImagesWithGraphPath:(NSString *) graphPath
{
    
    if ([self.sourceSession isSessionActive])
    {
        NSDictionary *params = nil;
        if ([self.facebookAlbumId isEqualToString:@"TAGGED_PHOTOS"]) {
            params = @{@"fields" : @"id,source,picture,width,height,created_time,images"};
        }
        
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:params]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             
             if (!error)
             {
                 NSArray *images = result[@"data"];
                 if (images)
                 {
                     for (int i = 0; i < [images count]; i++)
                     {
                         NSDictionary *imageDict = [images objectAtIndex:i];
                         
                         MPKFacebookAsset *asset = [[MPKFacebookAsset alloc] initWithFacebookJSON:imageDict];
                         [self addMPKAsset:asset];
                         NSLog(@"%d", i);
                     }
                 }
                 
                 
                 NSDictionary *paging = result[@"paging"];
                 if (paging)
                 {
                     NSDictionary *cursors = paging[@"cursors"];
                     if (cursors && cursors[@"after"])
                     {
                         NSString *afterString = [NSString stringWithFormat:@"%@%@&after=%@", self.facebookAlbumId, kFacebookGraphAPIImagesEndpoint, cursors[@"after"]];
                         
                         if ([self.facebookAlbumId isEqualToString:@"TAGGED_PHOTOS"]) {
                             afterString = [NSString stringWithFormat:@"me/photos?after=%@", cursors[@"after"]];
                         }
                         [self loadImagesWithGraphPath:afterString];
                     }
                 }
                 
             }
             else
             {
                 NSLog(@"E %@", error);
             }
             
             
         }];
    }
}

@end
