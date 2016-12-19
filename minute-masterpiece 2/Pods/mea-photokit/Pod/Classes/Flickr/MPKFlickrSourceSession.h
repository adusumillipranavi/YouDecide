//
//  MPKFlickrSourceSession.h
//  Pods
//
//  Created by Daniel Loomb on 1/16/15.
//
//

#import "MPKSourceSession.h"

@class OFFlickrAPIContext;

@interface MPKFlickrSourceSession : MPKSourceSession

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *NSID;

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *apiSecret;

@property (nonatomic, strong) OFFlickrAPIContext *flickrContext;

@end
