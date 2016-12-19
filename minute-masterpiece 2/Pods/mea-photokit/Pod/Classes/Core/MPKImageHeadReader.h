//
//  MPKImageHeadReader.h
//  Pods
//
//  Created by Daniel Loomb on 11/7/16.
//
//

#import <Foundation/Foundation.h>

@interface MPKImageHeadReader : NSObject

- (void)read:(NSData *)data withCompletion:(void (^)(uint32_t width, uint32_t height, NSString *type))completion;

@end
