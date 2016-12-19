//
//  MPKFlickrCollection.m
//  Pods
//
//  Created by Daniel Loomb on 1/16/15.
//
//

#import "MPKFlickrCollection.h"

#import "MEAPhotoKit.h"
#import "MPKFlickr.h"
#import "ObjectiveFlickr.h"

@interface MPKFlickrCollection() <OFFlickrAPIRequestDelegate>

@property (nonatomic, readonly) MPKFlickrSourceSession *localSourceSession;
@property (nonatomic, strong) OFFlickrAPIRequest *flickrImageRequest;

@end

@implementation MPKFlickrCollection

- (instancetype)initRootCollection
{
	self = [super init];
	if (self)
	{
		self.sourceSession = [[MPKFlickrSourceSession alloc] init];
		self.title = self.sourceSession.sourceTitle;
	}
	return self;
}

-(MPKCollectionType)type
{
	return MPKCollectionTypeFlickr;
}

-(MPKFlickrSourceSession *)localSourceSession
{
	return (id)self.sourceSession;
}

-(void)loadContentsCompletionHandler:(void (^)())completionHandler
{
	[super loadContentsCompletionHandler:completionHandler];
	
	self.flickrImageRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.localSourceSession.flickrContext];
	self.flickrImageRequest.delegate = self;
	self.flickrImageRequest.requestTimeoutInterval = 60.0;
	
	//Load Pages starting at zero
	[self loadFlickrImagesAtPage:0];
}

-(void)loadFlickrImagesAtPage:(NSInteger)page
{
	[self.flickrImageRequest callAPIMethodWithGET:@"flickr.people.getPhotos"
										arguments:@{
													@"api_key" : self.localSourceSession.apiKey,
													@"user_id":@"me",
													@"extras":@"url_o,date_upload",
													@"page":[NSString stringWithFormat:@"%ld", (long)page]
													}];
}


#pragma mark - ObjectiveFlicker Delegate

-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
	NSInteger numberOfPages = [[inResponseDictionary valueForKeyPath:@"photos.pages"] integerValue];
	NSInteger currentPage = [[inResponseDictionary valueForKeyPath:@"photos.page"] integerValue];
	
	if (numberOfPages > currentPage)
	{
		[self loadFlickrImagesAtPage:currentPage + 1];
	}
	
	__block NSArray *photoDictionaries = [inResponseDictionary valueForKeyPath:@"photos.photo"];
	
	void (^loadBlock)() = ^{
		NSArray *validExtensions = [MEAPhotoKit allowedExtensions];
		
		for (NSDictionary *dict in photoDictionaries)
		{
			NSString *url = [dict objectForKey:@"url_o"];
			
			//Ignore image if it doesn't have a reference url
			if (url == nil) { continue; }
			
			NSString *extension = [[url pathExtension] lowercaseString];
			
			if ([validExtensions indexOfObject:extension] != NSNotFound)
			{
				NSURL *thumbUrl = [self.localSourceSession.flickrContext photoSourceURLFromDictionary:dict size:OFFlickrSmallSize];

				MPKFlickrAsset *asset = [[MPKFlickrAsset alloc] initWithJSON:dict andThumbUrl:thumbUrl];
				[self addMPKAsset:asset];
			}
		}
	};
	
	//Add Images From Request on different thread
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), loadBlock);
}

-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
	NSLog(@"Flickr: Error = %@", inError);
}

@end
