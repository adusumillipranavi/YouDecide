//
//  MPKRemoteAsset+DimensionRequest.m
//  Pods
//
//  Created by Daniel on 4/12/15.
//
//

#import "MPKRemoteAsset+DimensionRequest.h"
#import "MPKImageHeadReader.h"
#import <objc/runtime.h>

@interface MPKRemoteAsset () <NSURLConnectionDataDelegate>

@property (nonatomic, copy) void (^completionHandler)(NSError *error, NSDictionary *result);
@property (nonatomic, strong) NSURLConnection *connection;

@property (strong, nonatomic) MPKImageHeadReader *headerReader;

@end

@implementation MPKRemoteAsset (DimensionRequest)


/*
 |--------------------------------------------------------------------------
 | Entry / Exit
 |--------------------------------------------------------------------------
 */
#pragma mark - Entry / Exit


-(void)requestFullResolutionImageDimensionsWithCompletion:(void (^)(NSError *error, NSDictionary *result))completion {
	self.completionHandler = completion;
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.fullResolutionURLString]];
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
	[self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.connection start];
}

-(void)completeWithError:(NSError *)error
				 orWidth:(NSUInteger)width
			   andHeight:(NSUInteger)height
				  ofType:(NSString *)type {
	[self.connection cancel];

	if (self.completionHandler) {
		if (error) {
			NSLog(@"Dimension Request Error: %@", error);
			self.completionHandler(error, nil);
			return;
		}
		
		NSDictionary *result = @{
								 @"width" : @(width),
								 @"height" : @(height),
								 @"type" : type
								 };
		
		NSLog(@"Dimension Request Result: %@", result);
		
		self.completionHandler(nil, result);
	}
}




/*
 |--------------------------------------------------------------------------
 | Connection Handling
 |--------------------------------------------------------------------------
 */
#pragma mark - Connection Handling

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (self.completionHandler) {
		self.completionHandler(error, nil);
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.headerReader read:data withCompletion:^(uint32_t width, uint32_t height, NSString *type) {
		[self completeWithError:nil orWidth:width andHeight:height ofType:type];
	}];
}


/*
 |--------------------------------------------------------------------------
 | Properties
 |--------------------------------------------------------------------------
 */
#pragma mark - Properties

-(void)setCompletionHandler:(void (^)(NSError *, NSDictionary *))completionHandler
{
	objc_setAssociatedObject(self, @selector(completionHandler), completionHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)completionHandler
{
	return objc_getAssociatedObject(self, @selector(completionHandler));
}

-(void)setConnection:(NSURLConnection *)connection
{
	objc_setAssociatedObject(self, @selector(connection), connection, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSURLConnection *)connection
{
	return objc_getAssociatedObject(self, @selector(connection));
}

- (void)setHeaderReader:(MPKImageHeadReader *)headerReader {
	objc_setAssociatedObject(self, @selector(headerReader), headerReader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MPKImageHeadReader *)headerReader {
	return objc_getAssociatedObject(self, @selector(headerReader));
}


@end
