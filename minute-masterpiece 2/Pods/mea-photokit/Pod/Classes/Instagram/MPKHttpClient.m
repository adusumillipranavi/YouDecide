//
//  MPKHttpClient.m
//  Pods
//
//  Created by Daniel Loomb on 10/20/16.
//
//

#import "MPKHttpClient.h"

@interface MPKCollection() <NSURLConnectionDelegate>

@end

@implementation MPKHttpClient

- (void)post:(NSString *)url parameters:(NSDictionary *)parameters completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion {
	// 1
	NSURL *u = [NSURL URLWithString:url];
	NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
 
	// 2
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:u];
	request.HTTPMethod = @"POST";
 
	// 3
	NSError *error = nil;
	NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
 
	if (!error) {
		// 4
		NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
																   fromData:data
														  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
															  if (error) {
																  completion(nil, nil, error);
															  } else {
																  id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
																  completion(response, error ? data : object, nil);
															  }
														  }];
		
		// 5
		[uploadTask resume];
	} else {
		completion(nil, nil, error);
	}
}


- (void)postFormData:(NSString *)url parameters:(NSDictionary *)parameters completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion {
	// 1
	NSURL *u = [NSURL URLWithString:url];
	NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
 
	// 2
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:u];
	request.HTTPMethod = @"POST";
 
	// 3
	NSString *data = @"";
	for (NSString *key in parameters) {
		if (data.length != 0) {
			data = [data stringByAppendingString:@"&"];
		}
		data = [data stringByAppendingFormat:@"%@=%@", key, parameters[key]];
	}
	request.HTTPBody = [data dataUsingEncoding:NSUTF8StringEncoding];
	
	// 4
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error) {
			completion(nil, nil, error);
		} else {
			id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
			completion(response, error ? data : object, nil);
		}
	}];
	
	// 5
	[task resume];
}



#pragma mark - Connection Delegate



@end
