//
//  MPKFacebookSourceSession.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/8/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKSourceSession.h"

@interface MPKFacebookSourceSession : MPKSourceSession
@property (nonatomic, strong) NSString *displayEmail;

+ (NSDictionary *)FBErrorCodeDescription:(NSError*) error;

@end
