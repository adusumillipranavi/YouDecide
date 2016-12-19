//
//  MPKHttpClient.h
//  Pods
//
//  Created by Daniel Loomb on 10/20/16.
//
//

#import <Foundation/Foundation.h>

@interface MPKHttpClient : NSObject

- (void)post:(NSString *)url parameters:(NSDictionary *)parameters completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion;
- (void)postFormData:(NSString *)url parameters:(NSDictionary *)parameters completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion;

@end
