//
//  MPKInstagramSourceSession.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/7/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKSourceSession.h"

@class Instagram;

@interface MPKInstagramSourceSession : MPKSourceSession

@property (nonatomic, strong) Instagram *instagram;
-(void)postInstagramCodeForVerificationToken:(NSString *)code;

@end
